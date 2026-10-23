//+------------------------------------------------------------------+
//|                                             TelegramNotifier.mq5 |
//|        Sends trade events and a daily summary to a Telegram chat |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Setup
// 1. In Telegram, create a bot with @BotFather and copy its token.
// 2. Send any message to the bot (or add it to your group / channel)
//    and find the chat ID, e.g. with @userinfobot.
// 3. MetaTrader 5: Tools > Options > Expert Advisors >
//    "Allow WebRequest for listed URL" > add https://api.telegram.org
// 4. Attach the EA to ONE chart and enter the token and the chat ID.
//
// The EA never trades on a live or demo account. Messages are queued
// and sent from the timer, so trade events are never delayed by the network.
// Keep the bot token private (do not share .set files that contain it).
//
// Preview mode: leave the token empty and the messages are only shown
// on the chart and in the journal - a quick way to try the EA.
//
// Strategy Tester: the EA opens and closes one small test trade a day
// (minimum lot, no SL/TP, closed after 4 hours) so you can see the
// messages in the journal. This never happens on a live or demo account.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.01"
#property description "Sends every opened and closed position, pending orders and an optional"
#property description "daily summary of the account to a Telegram chat. It never trades on an account."
#property description "Add https://api.telegram.org in Tools > Options > Expert Advisors > WebRequest."
#property description "Without a token it runs in preview mode: messages are shown on the chart only."
#property description "Strategy Tester only: one small test trade a day shows the messages in the journal."

#include <Trade\Trade.mqh>

input group "Telegram"
input string InpBotToken     = "";    // Bot token (from @BotFather, empty = preview mode)
input string InpChatId       = "";    // Chat ID (user, group or channel)
input string InpTitle        = "";    // Title of the messages (empty = account number)

input group "Messages"
input bool   InpOnStart      = true;  // When the EA starts
input bool   InpOnOpen       = true;  // Position opened
input bool   InpOnClose      = true;  // Position closed
input bool   InpOnPending    = true;  // Pending order placed / cancelled
input bool   InpOnModify     = false; // Stop loss / take profit changed
input bool   InpDailySummary = true;  // Daily summary
input int    InpSummaryHour  = 23;    // Summary at server hour (0-23)

input group "Filters"
input long   InpMagicFilter  = -1;    // Only this magic number (-1 = all)
input string InpSymbolFilter = "";    // Only this symbol (empty = all)

input group "Chart"
input bool   InpShowOnChart  = true;  // Show the status and the last messages on the chart
input int    InpChartLines   = 6;     // Number of messages shown on the chart

input group "Strategy Tester"
input bool   InpTesterDemo   = true;  // Tester only: one small test trade a day to show the messages

#define MAX_QUEUE    100
#define MAX_ATTEMPTS 5
#define DEMO_MAGIC         7350001   // magic number of the tester-only test trades
#define DEMO_HOLD_SECONDS  14400     // a test trade is closed after 4 hours
#define DEMO_PAUSE_SECONDS 86400     // one test trade a day

string g_queue[];
int    g_attempts[];
string g_recent[];                      // last messages, newest first
long   g_lastSummaryDay = -1;
bool   g_urlWarned      = false;
bool   g_preview        = false;        // no token: show the messages, send nothing
int    g_sent           = 0;
string g_lastError      = "";
CTrade   g_trade;                      // tester-only test trades
datetime g_demoLastOpen = 0;
int      g_demoCount    = 0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSummaryHour < 0 || InpSummaryHour > 23)
     {
      Print("Telegram Notifier: the summary hour must be 0-23.");
      return INIT_PARAMETERS_INCORRECT;
     }
   g_preview = (InpBotToken == "" || MQLInfoInteger(MQL_TESTER));
   if(g_preview)
      Print("Telegram Notifier: preview mode - messages are shown on the chart and in the journal, nothing is sent.");
   else
      if(StringLen(InpBotToken) < 20 || StringLen(InpChatId) == 0)
        {
         Print("Telegram Notifier: check the bot token and enter the chat ID (or leave the token empty for preview mode).");
         return INIT_PARAMETERS_INCORRECT;
        }

   // no summary for a day whose summary hour has already passed
   datetime now = TimeTradeServer();
   MqlDateTime t;
   TimeToStruct(now, t);
   long today = (long)now / 86400;
   g_lastSummaryDay = (t.hour >= InpSummaryHour) ? today : today - 1;

   // the queue is sent every second; the Strategy Tester sends nothing,
   // so there a slower timer keeps long tests fast
   EventSetTimer(MQLInfoInteger(MQL_TESTER) ? 60 : 1);
   if(MQLInfoInteger(MQL_TESTER) && InpTesterDemo)
     {
      g_trade.SetExpertMagicNumber(DEMO_MAGIC);
      g_trade.SetTypeFillingBySymbol(_Symbol);
      Print("Telegram Notifier: Strategy Tester - one small test trade a day shows the messages in the journal.");
     }
   if(InpOnStart)
      Enqueue(StringFormat("notifier started on %s. Balance %s, equity %s %s.",
                           AccountInfoString(ACCOUNT_SERVER),
                           DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2),
                           DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2),
                           AccountInfoString(ACCOUNT_CURRENCY)));
   ShowStatus();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(ArraySize(g_queue) > 0)
      PrintFormat("Telegram Notifier: %d unsent message(s) discarded.", ArraySize(g_queue));
   if(InpShowOnChart)
      Comment("");
  }

//+------------------------------------------------------------------+
//| New tick                                                         |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(InpTesterDemo && MQLInfoInteger(MQL_TESTER))
      TesterDemoTrade();
  }

//+------------------------------------------------------------------+
//| Timer: daily summary and sending of the queue                    |
//+------------------------------------------------------------------+
void OnTimer()
  {
   CheckDailySummary();

   int sent = 0;
   while(ArraySize(g_queue) > 0 && sent < 5)
     {
      if(Send(g_queue[0]))
        {
         RemoveFirst();
         sent++;
         continue;
        }
      g_attempts[0]++;
      if(g_attempts[0] >= MAX_ATTEMPTS)
        {
         Print("Telegram Notifier: message dropped after ", MAX_ATTEMPTS, " attempts: ", g_queue[0]);
         RemoveFirst();
        }
      break;                                    // try again in a second
     }
   ShowStatus();
  }

//+------------------------------------------------------------------+
//| Trade events: deals, pending orders, SL/TP changes               |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   switch(trans.type)
     {
      case TRADE_TRANSACTION_DEAL_ADD:
         OnDeal(trans.deal);
         break;
      case TRADE_TRANSACTION_ORDER_ADD:
         if(InpOnPending && IsPending(trans.order_type))
            OnPendingPlaced(trans);
         break;
      case TRADE_TRANSACTION_ORDER_DELETE:
         if(InpOnPending && IsPending(trans.order_type) &&
            (trans.order_state == ORDER_STATE_CANCELED || trans.order_state == ORDER_STATE_EXPIRED))
            OnPendingRemoved(trans);
         break;
      case TRADE_TRANSACTION_POSITION:
         if(InpOnModify)
            OnPositionModified(trans);
         break;
      default:
         break;
     }
  }

//+------------------------------------------------------------------+
//| Opened / closed positions                                        |
//+------------------------------------------------------------------+
void OnDeal(const ulong deal)
  {
   if(deal == 0 || !HistoryDealSelect(deal))
      return;
   long type = HistoryDealGetInteger(deal, DEAL_TYPE);
   if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
      return;

   long   entry  = HistoryDealGetInteger(deal, DEAL_ENTRY);
   long   reason = HistoryDealGetInteger(deal, DEAL_REASON);
   long   magic  = HistoryDealGetInteger(deal, DEAL_MAGIC);
   long   posId  = HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   string symbol = HistoryDealGetString(deal, DEAL_SYMBOL);
   double volume = HistoryDealGetDouble(deal, DEAL_VOLUME);
   double price  = HistoryDealGetDouble(deal, DEAL_PRICE);
   double pnl    = HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_SWAP)
                   + HistoryDealGetDouble(deal, DEAL_COMMISSION) + HistoryDealGetDouble(deal, DEAL_FEE);

   // a position closed by hand or by SL/TP may carry another magic: use the opening deal
   if(entry != DEAL_ENTRY_IN && InpMagicFilter >= 0)
      magic = OpeningMagic(posId, magic);
   if(!Matches(symbol, magic))
      return;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(entry == DEAL_ENTRY_IN)
     {
      if(!InpOnOpen)
         return;
      string text = StringFormat("OPEN %s %s %s at %s",
                                 type == DEAL_TYPE_BUY ? "BUY" : "SELL",
                                 DoubleToString(volume, 2), symbol, DoubleToString(price, digits));
      if(PositionSelectByTicket((ulong)posId))
         text += " | SL " + PriceText(PositionGetDouble(POSITION_SL), digits)
                 + ", TP " + PriceText(PositionGetDouble(POSITION_TP), digits);
      Enqueue(text + OriginText(reason, magic));
      return;
     }

   if(!InpOnClose)
      return;
   // a SELL deal closes a BUY position and the other way round
   string side = (type == DEAL_TYPE_SELL) ? "BUY" : "SELL";
   string word = (entry == DEAL_ENTRY_INOUT) ? "REVERSE" : "CLOSE";
   Enqueue(StringFormat("%s %s %s %s at %s | P/L %s%s %s%s",
                        word, side, DoubleToString(volume, 2), symbol, DoubleToString(price, digits),
                        pnl >= 0 ? "+" : "", DoubleToString(pnl, 2), AccountInfoString(ACCOUNT_CURRENCY),
                        CloseReasonText(reason)));
  }

//+------------------------------------------------------------------+
//| Pending order placed                                             |
//+------------------------------------------------------------------+
void OnPendingPlaced(const MqlTradeTransaction &trans)
  {
   long magic = 0;
   if(OrderSelect(trans.order))
      magic = OrderGetInteger(ORDER_MAGIC);
   if(!Matches(trans.symbol, magic))
      return;
   int digits = (int)SymbolInfoInteger(trans.symbol, SYMBOL_DIGITS);
   Enqueue(StringFormat("PENDING %s %s %s at %s | SL %s, TP %s",
                        OrderTypeText(trans.order_type), DoubleToString(trans.volume, 2), trans.symbol,
                        DoubleToString(trans.price, digits),
                        PriceText(trans.price_sl, digits), PriceText(trans.price_tp, digits)));
  }

//+------------------------------------------------------------------+
//| Pending order cancelled or expired                               |
//+------------------------------------------------------------------+
void OnPendingRemoved(const MqlTradeTransaction &trans)
  {
   long magic = 0;
   if(HistoryOrderSelect(trans.order))
      magic = HistoryOrderGetInteger(trans.order, ORDER_MAGIC);
   if(!Matches(trans.symbol, magic))
      return;
   int digits = (int)SymbolInfoInteger(trans.symbol, SYMBOL_DIGITS);
   Enqueue(StringFormat("%s %s %s at %s",
                        trans.order_state == ORDER_STATE_EXPIRED ? "EXPIRED" : "CANCELLED",
                        OrderTypeText(trans.order_type), trans.symbol, DoubleToString(trans.price, digits)));
  }

//+------------------------------------------------------------------+
//| Stop loss / take profit of a position changed                    |
//+------------------------------------------------------------------+
void OnPositionModified(const MqlTradeTransaction &trans)
  {
   long magic = 0;
   if(PositionSelectByTicket(trans.position))
      magic = PositionGetInteger(POSITION_MAGIC);
   if(!Matches(trans.symbol, magic))
      return;
   int digits = (int)SymbolInfoInteger(trans.symbol, SYMBOL_DIGITS);
   Enqueue(StringFormat("MODIFY %s #%I64u | SL %s, TP %s",
                        trans.symbol, trans.position,
                        PriceText(trans.price_sl, digits), PriceText(trans.price_tp, digits)));
  }

//+------------------------------------------------------------------+
//| Strategy Tester only: one small test trade a day, so the         |
//| messages can be seen in the journal. Never runs on an account.   |
//+------------------------------------------------------------------+
void TesterDemoTrade()
  {
   if(!MQLInfoInteger(MQL_TESTER))
      return;
   datetime now = TimeCurrent();
   // close the test position after the holding time
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || PositionGetInteger(POSITION_MAGIC) != DEMO_MAGIC)
         continue;
      if(now - (datetime)PositionGetInteger(POSITION_TIME) >= DEMO_HOLD_SECONDS)
         g_trade.PositionClose(ticket);
      return;
     }
   if(g_demoLastOpen > 0 && now - g_demoLastOpen < DEMO_PAUSE_SECONDS)
      return;
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
      return;
   // minimum lot, and only when the free margin is clearly enough
   bool            buy    = (g_demoCount % 2 == 0);
   ENUM_ORDER_TYPE type   = buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double          volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double          price  = SymbolInfoDouble(_Symbol, buy ? SYMBOL_ASK : SYMBOL_BID);
   double          margin = 0.0;
   if(volume <= 0.0 || price <= 0.0 || !OrderCalcMargin(type, _Symbol, volume, price, margin) ||
      margin * 2.0 > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
      return;
   g_demoLastOpen = now;                   // also after a failed attempt: next try tomorrow
   g_demoCount++;
   if(buy)
      g_trade.Buy(volume, _Symbol, price, 0.0, 0.0, "tester demo");
   else
      g_trade.Sell(volume, _Symbol, price, 0.0, 0.0, "tester demo");
  }

//+------------------------------------------------------------------+
//| Daily summary                                                    |
//+------------------------------------------------------------------+
void CheckDailySummary()
  {
   if(!InpDailySummary)
      return;
   datetime now = TimeTradeServer();
   MqlDateTime t;
   TimeToStruct(now, t);
   long today = (long)now / 86400;
   if(t.hour < InpSummaryHour || today == g_lastSummaryDay)
      return;
   g_lastSummaryDay = today;
   Enqueue(BuildSummary((datetime)(today * 86400), now));
  }

//+------------------------------------------------------------------+
//| Text of the daily summary                                        |
//+------------------------------------------------------------------+
string BuildSummary(const datetime from, const datetime to)
  {
   int    closed = 0, won = 0, lost = 0;
   double net    = 0.0;
   if(HistorySelect(from, to + 60))
     {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
        {
         ulong deal = HistoryDealGetTicket(i);
         if(deal == 0)
            continue;
         long type = HistoryDealGetInteger(deal, DEAL_TYPE);
         if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
            continue;
         if(!Matches(HistoryDealGetString(deal, DEAL_SYMBOL), HistoryDealGetInteger(deal, DEAL_MAGIC)))
            continue;
         double pnl = HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_SWAP)
                      + HistoryDealGetDouble(deal, DEAL_COMMISSION) + HistoryDealGetDouble(deal, DEAL_FEE);
         net += pnl;
         long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
         if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
           {
            closed++;
            if(pnl > 0)
               won++;
            else
               if(pnl < 0)
                  lost++;
           }
        }
     }

   int    open     = 0;
   double floating = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0)
         continue;
      if(!Matches(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
         continue;
      open++;
      floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }

   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   return StringFormat("DAILY SUMMARY %s\nClosed trades: %d (won %d, lost %d)\nClosed P/L: %s%s %s\n"
                       "Open positions: %d, floating %s%s %s\nBalance %s, equity %s %s",
                       TimeToString(from, TIME_DATE), closed, won, lost,
                       net >= 0 ? "+" : "", DoubleToString(net, 2), cur,
                       open, floating >= 0 ? "+" : "", DoubleToString(floating, 2), cur,
                       DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2),
                       DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2), cur);
  }

//+------------------------------------------------------------------+
//| Queue and sending                                                |
//+------------------------------------------------------------------+
void Enqueue(const string text)
  {
   string message = Title() + ": " + text;
   AddRecent(text);
   if(g_preview)
     {
      Print("Telegram (preview, not sent): ", message);
      return;
     }
   int n = ArraySize(g_queue);
   if(n >= MAX_QUEUE)
     {
      Print("Telegram Notifier: queue full, message dropped: ", message);
      return;
     }
   ArrayResize(g_queue, n + 1);
   ArrayResize(g_attempts, n + 1);
   g_queue[n]    = message;
   g_attempts[n] = 0;
  }

//+------------------------------------------------------------------+
//| Remove the first message of the queue                            |
//+------------------------------------------------------------------+
void RemoveFirst()
  {
   ArrayRemove(g_queue, 0, 1);
   ArrayRemove(g_attempts, 0, 1);
  }

//+------------------------------------------------------------------+
//| Keep the newest messages for the chart (newest first)            |
//+------------------------------------------------------------------+
void AddRecent(const string text)
  {
   int keep = (InpChartLines > 0) ? InpChartLines : 0;
   if(keep == 0)
      return;
   string line = TimeToString(TimeCurrent(), TIME_MINUTES) + "  " + text;
   StringReplace(line, "\n", " / ");
   int n = ArraySize(g_recent);
   ArrayResize(g_recent, (n < keep) ? n + 1 : keep);
   for(int i = ArraySize(g_recent) - 1; i > 0; i--)
      g_recent[i] = g_recent[i - 1];
   g_recent[0] = line;
  }

//+------------------------------------------------------------------+
//| Status and the last messages as a chart comment                  |
//+------------------------------------------------------------------+
void ShowStatus()
  {
   if(!InpShowOnChart || (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)))
      return;
   string text = "Telegram Trade Notifier\n";
   if(g_preview)
      text += "PREVIEW MODE - no bot token, nothing is sent to Telegram\n";
   else
      text += StringFormat("Sent: %d   waiting: %d\n", g_sent, ArraySize(g_queue));
   if(g_lastError != "")
      text += "Last error: " + g_lastError + "\n";
   text += "\n";
   int n = ArraySize(g_recent);
   if(n == 0)
      text += "No messages yet";
   for(int i = 0; i < n; i++)
      text += g_recent[i] + "\n";
   Comment(text);
  }

//+------------------------------------------------------------------+
//| true = done (sent, or a permanent error that a retry cannot fix) |
//+------------------------------------------------------------------+
bool Send(const string text)
  {
   string url  = "https://api.telegram.org/bot" + InpBotToken + "/sendMessage";
   string body = "chat_id=" + UrlEncode(InpChatId) + "&disable_web_page_preview=true&text=" + UrlEncode(text);

   char   data[];
   char   result[];
   string resultHeaders;
   int    len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if(len > 0)
      ArrayResize(data, len - 1);              // drop the terminating zero

   ResetLastError();
   int code = WebRequest("POST", url, "Content-Type: application/x-www-form-urlencoded\r\n",
                         5000, data, result, resultHeaders);
   if(code == -1)
     {
      int err = GetLastError();
      if(err == 4014)
        {
         if(!g_urlWarned)
           {
            Print("Telegram Notifier: add https://api.telegram.org in Tools > Options > Expert Advisors > Allow WebRequest for listed URL.");
            g_urlWarned = true;
           }
        }
      else
         PrintFormat("Telegram Notifier: WebRequest failed, error %d", err);
      g_lastError = (err == 4014) ? "WebRequest not allowed for api.telegram.org" : StringFormat("WebRequest error %d", err);
      return false;
     }
   if(code == 200)
     {
      g_sent++;
      g_lastError = "";
      return true;
     }

   PrintFormat("Telegram Notifier: Telegram answered %d: %s", code, CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8));
   g_lastError = StringFormat("Telegram answered %d (see the Experts journal)", code);
   // 429 = too many requests, 5xx = server problem: retry. Other errors (wrong token / chat ID) will not fix themselves.
   return (code != 429 && code < 500);
  }

//+------------------------------------------------------------------+
//| Percent-encoding of a UTF-8 string for the request body          |
//+------------------------------------------------------------------+
string UrlEncode(const string text)
  {
   uchar bytes[];
   int   n   = StringToCharArray(text, bytes, 0, WHOLE_ARRAY, CP_UTF8);
   string out = "";
   for(int i = 0; i < n; i++)
     {
      uchar c = bytes[i];
      if(c == 0)
         break;
      if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') ||
         c == '-' || c == '_' || c == '.' || c == '~')
         out += CharToString(c);
      else
         out += StringFormat("%%%02X", c);
     }
   return out;
  }

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
string Title()
  {
   if(InpTitle != "")
      return InpTitle;
   return StringFormat("Account %I64d", AccountInfoInteger(ACCOUNT_LOGIN));
  }

//+------------------------------------------------------------------+
//| True if the trade passes the magic number / symbol filters       |
//+------------------------------------------------------------------+
bool Matches(const string symbol, const long magic)
  {
   if(InpSymbolFilter != "" && symbol != InpSymbolFilter)
      return false;
   if(InpMagicFilter >= 0 && magic != InpMagicFilter)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Magic number of the deal that opened the position                |
//+------------------------------------------------------------------+
long OpeningMagic(const long positionId, const long fallback)
  {
   if(positionId <= 0 || !HistorySelectByPosition(positionId))
      return fallback;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal > 0 && HistoryDealGetInteger(deal, DEAL_ENTRY) == DEAL_ENTRY_IN)
         return HistoryDealGetInteger(deal, DEAL_MAGIC);
     }
   return fallback;
  }

//+------------------------------------------------------------------+
//| True for pending order types                                     |
//+------------------------------------------------------------------+
bool IsPending(const ENUM_ORDER_TYPE type)
  {
   return (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT ||
           type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP ||
           type == ORDER_TYPE_BUY_STOP_LIMIT || type == ORDER_TYPE_SELL_STOP_LIMIT);
  }

//+------------------------------------------------------------------+
//| Readable order type                                              |
//+------------------------------------------------------------------+
string OrderTypeText(const ENUM_ORDER_TYPE type)
  {
   switch(type)
     {
      case ORDER_TYPE_BUY_LIMIT:
         return "BUY LIMIT";
      case ORDER_TYPE_SELL_LIMIT:
         return "SELL LIMIT";
      case ORDER_TYPE_BUY_STOP:
         return "BUY STOP";
      case ORDER_TYPE_SELL_STOP:
         return "SELL STOP";
      case ORDER_TYPE_BUY_STOP_LIMIT:
         return "BUY STOP LIMIT";
      case ORDER_TYPE_SELL_STOP_LIMIT:
         return "SELL STOP LIMIT";
      default:
         break;
     }
   return EnumToString(type);
  }

//+------------------------------------------------------------------+
//| Price text, or 'none' for an empty price                         |
//+------------------------------------------------------------------+
string PriceText(const double price, const int digits)
  {
   return (price > 0) ? DoubleToString(price, digits) : "none";
  }

//+------------------------------------------------------------------+
//| Who opened the position: EA, manual, mobile or web               |
//+------------------------------------------------------------------+
string OriginText(const long reason, const long magic)
  {
   if(reason == DEAL_REASON_EXPERT)
      return StringFormat(" | EA, magic %I64d", magic);
   if(reason == DEAL_REASON_MOBILE)
      return " | mobile";
   if(reason == DEAL_REASON_WEB)
      return " | web";
   if(reason == DEAL_REASON_CLIENT)
      return " | manual";
   return "";
  }

//+------------------------------------------------------------------+
//| Why the position was closed: SL, TP or stop out                  |
//+------------------------------------------------------------------+
string CloseReasonText(const long reason)
  {
   if(reason == DEAL_REASON_SL)
      return " | stop loss";
   if(reason == DEAL_REASON_TP)
      return " | take profit";
   if(reason == DEAL_REASON_SO)
      return " | STOP OUT";
   return "";
  }
//+------------------------------------------------------------------+
