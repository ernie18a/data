//+------------------------------------------------------------------+
//|                                    TelegramTradeNotify_MT4.mq4   |
//|                     Copyright © 2026, Ngo The Hung (thehung21)   |
//|                        https://www.mql5.com/en/users/thehung21   |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property copyright "Copyright © 2026, Ngo The Hung (thehung21)"
#property link      "https://www.mql5.com/en/users/thehung21"
#property description "Utility EA: sends trade execution notifications to Telegram via Bot API (sendMessage)."

// ------------------------- Compatibility ---------------------------
// Some older MT4 builds don't define OP_BALANCE / OP_CREDIT constants.
// We define them here to avoid compile errors.
#ifndef OP_BALANCE
   #define OP_BALANCE 6
#endif
#ifndef OP_CREDIT
   #define OP_CREDIT 7
#endif

// ------------------------- Inputs ----------------------------------
input string InpBotToken           = "";      // Telegram bot token (e.g. 123456:ABC-DEF...)
input string InpChatId             = "";      // Chat ID or @channelusername (e.g. 12345678 or -100xxxxxxxxxx or @mychannel)
input bool   InpSendTestOnInit     = true;    // Send test message on init
input bool   InpNotifyBuySellOnly  = true;    // Notify only BUY/SELL executions (ignore pending/balance/credit/etc.)
input bool   InpDisableLinkPreview = true;    // Disable web page preview
input int    InpTimeoutMs          = 10000;   // WebRequest timeout (ms)
input string InpMsgPrefix          = "MT4";   // Message prefix

// ------------------------- Helpers ---------------------------------
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
         const int c = (int)bytes[i];
         if(c == 0) break;

         const bool unreserved =
            (c >= 'A' && c <= 'Z') ||
            (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') ||
            (c == '-') || (c == '_') || (c == '.') || (c == '~');

         if(unreserved)
            out += StringFormat("%c", c);
         else if(c == ' ')
            out += "%20";
         else
            out += StringFormat("%%%02X", c);
      }
      return out;
   }

   bool HttpGet(const string url, int &http_code, string &body, string &resp_headers) const
   {
      ResetLastError();

      char data[];           // empty for GET
      char response[];
      string headers = "";   // extra HTTP headers (optional)

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
      http_code_out      = -1;
      server_body_out    = "";

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

// ------------------------- Globals ---------------------------------
CTelegramNotifier g_tg;

int g_notified_open_tickets[];   // tickets notified as "opened"
int g_last_history_total = 0;

bool TicketInArray(const int ticket, const int &arr[])
{
   for(int i=0; i<ArraySize(arr); i++)
      if(arr[i] == ticket) return true;
   return false;
}

void ArrayAddTicket(int &arr[], const int ticket)
{
   const int n = ArraySize(arr);
   ArrayResize(arr, n+1);
   arr[n] = ticket;
}

void PrimeExistingOrders()
{
   // Prime open trades (avoid sending notifications for trades that were already open before EA start)
   ArrayResize(g_notified_open_tickets, 0);

   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;

      const int type = OrderType();
      if(type != OP_BUY && type != OP_SELL)
         continue;

      const int ticket = OrderTicket();
      if(!TicketInArray(ticket, g_notified_open_tickets))
         ArrayAddTicket(g_notified_open_tickets, ticket);
   }

   // Prime history counter (avoid sending notifications for already-closed orders)
   g_last_history_total = OrdersHistoryTotal();
}

string TypeToLabelOpen(const int type)
{
   if(type == OP_BUY)  return "BUY";
   if(type == OP_SELL) return "SELL";
   return "DEAL";
}

string TypeToLabelClose(const int type)
{
   // For a closing execution, direction is opposite to the original position type
   if(type == OP_BUY)  return "SELL";
   if(type == OP_SELL) return "BUY";

   if(type == OP_BALANCE) return "BALANCE";
   if(type == OP_CREDIT)  return "CREDIT";

   return "DEAL";
}

void SendOpenNotify()
{
   // Notify only executed market orders (BUY/SELL). Pending orders are not executions.
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;

      const int type = OrderType();
      if(type != OP_BUY && type != OP_SELL)
         continue;

      const int ticket = OrderTicket();
      if(TicketInArray(ticket, g_notified_open_tickets))
         continue;

      const string sym = OrderSymbol();
      int digits = (int)MarketInfo(sym, MODE_DIGITS);
      if(digits <= 0 || digits > 8) digits = 2;
      const double price = OrderOpenPrice();
      const double lots  = OrderLots();

      string msg = "";
      msg += StringFormat("🔔 %s | %s\n", InpMsgPrefix, AccountServer());
      msg += StringFormat("%s %s  %.2f lots @ %s\n", sym, TypeToLabelOpen(type), lots, DoubleToString(price, digits));
      msg += StringFormat("Ticket #%d | Profit: %.2f", ticket, 0.0);

      int http; string body;
      const bool sent = g_tg.SendText(msg, http, body);
      if(!sent)
         PrintFormat("TelegramTradeNotify_MT4: send failed. HTTP=%d, body=%s", http, body);

      ArrayAddTicket(g_notified_open_tickets, ticket);
   }
}

void SendCloseNotify()
{
   const int hist_total = OrdersHistoryTotal();
   if(hist_total <= g_last_history_total)
      return;

   // New history records appended to the end
   for(int i=g_last_history_total; i<hist_total; i++)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;

      const int type = OrderType();

      if(InpNotifyBuySellOnly)
      {
         if(type != OP_BUY && type != OP_SELL)
            continue;
      }
      else
      {
         // Still ignore pending orders in history
         if(type==OP_BUYLIMIT || type==OP_SELLLIMIT || type==OP_BUYSTOP || type==OP_SELLSTOP)
            continue;
      }

      string sym = OrderSymbol();
      if(StringLen(sym) == 0) sym = AccountCurrency();

      int digits = (int)MarketInfo(sym, MODE_DIGITS);
      if(digits <= 0 || digits > 8) digits = 2;

      const int ticket = OrderTicket();
      const double price = (type==OP_BALANCE || type==OP_CREDIT) ? 0.0 : OrderClosePrice();
      const double lots  = (type==OP_BALANCE || type==OP_CREDIT) ? 0.0 : OrderLots();

      double profit = 0.0;
      if(type==OP_BALANCE || type==OP_CREDIT)
         profit = OrderProfit();
      else
         profit = OrderProfit() + OrderSwap() + OrderCommission();

      string msg = "";
      msg += StringFormat("🔔 %s | %s\n", InpMsgPrefix, AccountServer());
      msg += StringFormat("%s %s  %.2f lots @ %s\n", sym, TypeToLabelClose(type), lots, DoubleToString(price, digits));
      msg += StringFormat("Ticket #%d | Profit: %.2f", ticket, profit);

      int http; string body;
      const bool sent = g_tg.SendText(msg, http, body);
      if(!sent)
         PrintFormat("TelegramTradeNotify_MT4: send failed. HTTP=%d, body=%s", http, body);
   }

   g_last_history_total = hist_total;
}

void CheckTrades()
{
   if(!g_tg.IsConfigured())
      return;

   SendOpenNotify();
   SendCloseNotify();
}

// ------------------------- EA Events --------------------------------
int OnInit()
{
   g_tg.Configure(InpBotToken, InpChatId, InpTimeoutMs, InpDisableLinkPreview);

   PrimeExistingOrders();

   if(!g_tg.IsConfigured())
   {
      Print("TelegramTradeNotify_MT4: Please set InpBotToken and InpChatId.");
      Print("Also add https://api.telegram.org to: Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL");
      EventSetTimer(1);
      return(INIT_SUCCEEDED);
   }

   if(InpSendTestOnInit)
   {
      const string test = StringFormat("📩 %s: Test message from EA on %s (%s)", InpMsgPrefix, AccountServer(), Symbol());

      int code; string body;
      const bool sent = g_tg.SendText(test, code, body);

      if(!sent)
      {
         PrintFormat("TelegramTradeNotify_MT4: test send failed. HTTP=%d, body=%s", code, body);
         Print("Hint: Enable WebRequest URL + check token/chat_id.");
      }
   }

   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

void OnTick()
{
   CheckTrades();
}

void OnTimer()
{
   CheckTrades();
}

void OnTrade()
{
   CheckTrades();
}
//+------------------------------------------------------------------+
