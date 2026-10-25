//+------------------------------------------------------------------+
//|                                        TelegramTradeNotify.mq5   |
//|                     Copyright © 2026, Ngo The Hung (thehung21)   |
//|                        https://www.mql5.com/en/users/thehung21   |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property copyright "Copyright © 2026, Ngo The Hung (thehung21)"
#property link      "https://www.mql5.com/en/users/thehung21"
#property description "Utility EA: sends trade execution notifications to Telegram via Bot API (sendMessage)."

// ------------------------- Inputs ----------------------------------
input string InpBotToken           = "";      // Telegram bot token (e.g. 123456:ABC-DEF...)
input string InpChatId             = "";      // Chat ID or @channelusername (e.g. 12345678 or -100xxxxxxxxxx or @mychannel)
input bool   InpSendTestOnInit     = true;    // Send test message on init
input bool   InpNotifyBuySellOnly  = true;    // Notify only BUY/SELL deals (ignore balance/credit/etc.)
input bool   InpDisableLinkPreview = true;    // Disable web page preview
input int    InpTimeoutMs          = 10000;   // WebRequest timeout (ms)
input string InpMsgPrefix          = "MT5";   // Message prefix

// ------------------------- Helpers --------------------------------
class CTelegramNotifier
{
private:
   string m_token;
   string m_chat;
   int    m_timeout;
   bool   m_disable_preview;

   // URL-encode UTF-8 bytes for query string
   string UrlEncodeUtf8(const string s) const
   {
      uchar bytes[];
      StringToCharArray(s, bytes, 0, WHOLE_ARRAY, CP_UTF8);

      string out = "";
      for(int i = 0; i < ArraySize(bytes); i++)
      {
         const uchar c = bytes[i];
         if(c == 0) break;

         const bool unreserved =
            (c >= 'A' && c <= 'Z') ||
            (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') ||
            (c == '-') || (c == '_') || (c == '.') || (c == '~');

         if(unreserved)
            out += StringFormat("%c", (int)c);   // ASCII-safe, no warning
         else if(c == ' ')
            out += "%20";
         else
            out += StringFormat("%%%02X", (int)c);
      }
      return out;
   }

   bool HttpGet(const string url, int &http_code, string &body, string &resp_headers) const
   {
      ResetLastError();

      uchar data[];           // empty for GET
      uchar response[];
      string headers = "";    // extra HTTP headers (optional)

      // MQL5 overload:
      // int WebRequest(const string method,const string url,const string headers,int timeout,
      //                const uchar& data[], uchar& result[], string& result_headers);
      http_code = WebRequest("GET", url, headers, m_timeout, data, response, resp_headers);

      if(http_code == -1)
      {
         const int err = GetLastError();
         body = StringFormat("WebRequest failed. err=%d", err);
         return false;
      }

      body = CharArrayToString(response, 0, -1, CP_UTF8);
      return true;
   }

public:
   void Configure(const string token, const string chat_id, const int timeout_ms, const bool disable_preview)
   {
      m_token           = token;
      m_chat            = chat_id;
      m_timeout         = timeout_ms;
      m_disable_preview = disable_preview;
   }

   bool IsConfigured() const
   {
      return (StringLen(m_token) > 0 && StringLen(m_chat) > 0);
   }

   bool SendText(const string text, int &http_code_out, string &server_body_out)
   {
      http_code_out   = -1;
      server_body_out = "";

      if(!IsConfigured())
      {
         server_body_out = "Telegram token/chat_id is empty.";
         return false;
      }

      const string base = "https://api.telegram.org/bot" + m_token + "/sendMessage";

      string url = base
         + "?chat_id=" + UrlEncodeUtf8(m_chat)
         + "&text="    + UrlEncodeUtf8(text);

      if(m_disable_preview)
         url += "&disable_web_page_preview=true";

      string resp_headers, body;
      int http_code;

      const bool ok = HttpGet(url, http_code, body, resp_headers);
      http_code_out   = http_code;
      server_body_out = body;

      return (ok && http_code == 200);
   }
};

// ------------------------- Globals --------------------------------
CTelegramNotifier g_tg;

// ------------------------- EA Events ------------------------------
int OnInit()
{
   g_tg.Configure(InpBotToken, InpChatId, InpTimeoutMs, InpDisableLinkPreview);

   if(!g_tg.IsConfigured())
   {
      Print("TelegramTradeNotify: Please set InpBotToken and InpChatId.");
      Print("Also add https://api.telegram.org to: Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL");
      return INIT_SUCCEEDED;
   }

   if(InpSendTestOnInit)
   {
      const string test = StringFormat("✅ %s: Test message from EA on %s (%s)",
                                       InpMsgPrefix, AccountInfoString(ACCOUNT_SERVER), _Symbol);

      int code; string body;
      const bool sent = g_tg.SendText(test, code, body);

      if(!sent)
      {
         PrintFormat("TelegramTradeNotify: test send failed. HTTP=%d, body=%s", code, body);
         Print("Hint: Enable WebRequest URL + check token/chat_id.");
      }
   }

   return INIT_SUCCEEDED;
}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   // only react to executed deals
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;

   if(!g_tg.IsConfigured())
      return;

   if(InpNotifyBuySellOnly)
   {
      if(trans.deal_type != DEAL_TYPE_BUY && trans.deal_type != DEAL_TYPE_SELL)
         return;
   }

   const string sym = (trans.symbol != NULL && StringLen(trans.symbol) > 0) ? trans.symbol : _Symbol;
   const int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

   string side = "DEAL";
   if(trans.deal_type == DEAL_TYPE_BUY)  side = "BUY";
   if(trans.deal_type == DEAL_TYPE_SELL) side = "SELL";

   const double price  = (trans.price  > 0.0 ? trans.price  : SymbolInfoDouble(sym, SYMBOL_BID));
   const double volume = (trans.volume > 0.0 ? trans.volume : 0.0);

   double profit = 0.0;
   if(trans.deal > 0)
   {
      const datetime to   = TimeCurrent() + 60;
      const datetime from = to - 86400 * 7;
      HistorySelect(from, to);

      ResetLastError();
      profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
   }

   string msg = "";
   msg += StringFormat("🔔 %s | %s\n", InpMsgPrefix, AccountInfoString(ACCOUNT_SERVER));
   msg += StringFormat("%s %s  %.2f lots @ %s\n", sym, side, volume, DoubleToString(price, digits));
   msg += StringFormat("Deal #%I64u | Profit: %.2f", trans.deal, profit);

   int http; string body;
   const bool sent = g_tg.SendText(msg, http, body);

   if(!sent)
      PrintFormat("TelegramTradeNotify: send failed. HTTP=%d, body=%s", http, body);
}
