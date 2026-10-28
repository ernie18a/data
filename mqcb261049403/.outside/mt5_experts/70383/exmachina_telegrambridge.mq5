//+------------------------------------------------------------------+
//|                                     ExMachina_TelegramBridge.mq5 |
//|                        Copyright 2026, ExMachina Trading Systems |
//|                       https://www.mql5.com/en/users/williammukam |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, ExMachina Trading Systems"
#property link        "https://www.mql5.com/en/users/williammukam"
#property version     "1.00"
#property description "ExMachina Telegram Bridge — Connect your trading account to Telegram."
#property description "Receive real-time notifications for new trades, closures, modifications,"
#property description "and periodic account summaries directly in your Telegram chat."
#property description " "
#property description "Setup: Create a bot via @BotFather, get your Chat ID via @userinfobot,"
#property description "then paste both values in the EA inputs."
#property description " "
#property description "— Precision before profit. —"

//--- Includes
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| ENUMS                                                            |
//+------------------------------------------------------------------+
enum ENUM_SUMMARY_INTERVAL
  {
   SUMMARY_OFF      = 0,   // Off
   SUMMARY_1H       = 1,   // Every 1 Hour
   SUMMARY_4H       = 4,   // Every 4 Hours
   SUMMARY_8H       = 8,   // Every 8 Hours
   SUMMARY_24H      = 24   // Every 24 Hours
  };

enum ENUM_MESSAGE_STYLE
  {
   STYLE_MINIMAL    = 0,   // Minimal (compact)
   STYLE_DETAILED   = 1,   // Detailed (full info)
   STYLE_EMOJI      = 2    // Emoji-rich
  };

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
//--- Telegram Configuration
input group           "═══ Telegram Configuration ═══"
input string          InpBotToken        = "";              // Bot Token (from @BotFather)
input string          InpChatID          = "";              // Chat ID (from @userinfobot)

//--- Notification Settings
input group           "═══ Notification Settings ═══"
input bool            InpNotifyOpen      = true;            // Notify on Trade Open
input bool            InpNotifyClose     = true;            // Notify on Trade Close
input bool            InpNotifyModify    = true;            // Notify on SL/TP Modify
input bool            InpNotifyPending   = true;            // Notify on Pending Orders
input bool            InpNotifyDeposit   = true;            // Notify on Deposit/Withdrawal

//--- Summary Reports
input group           "═══ Account Summary ═══"
input ENUM_SUMMARY_INTERVAL InpSummaryInterval = SUMMARY_4H; // Summary Report Interval
input bool            InpIncludeEquity   = true;            // Include Equity in Summary
input bool            InpIncludeDrawdown = true;            // Include Drawdown Info

//--- Display
input group           "═══ Display & Style ═══"
input ENUM_MESSAGE_STYLE InpStyle        = STYLE_EMOJI;     // Message Style
input bool            InpShowChart       = true;            // Show Dashboard on Chart
input color           InpDashColor       = C'8,10,18';      // Dashboard Background (CLR_BASE)
input color           InpTextColor       = C'200,205,215';   // Dashboard Text Color
input color           InpAccentColor     = C'0,180,220';     // Accent Color

//--- Filter
input group           "═══ Filters ═══"
input string          InpSymbolFilter    = "";              // Symbol Filter (empty = all, e.g. "EURUSD,XAUUSD")
input double          InpMinLotFilter    = 0.0;             // Min Lot Size to Notify (0 = all)
input long            InpMagicFilter     = -1;              // Magic Number Filter (-1 = all)

//+------------------------------------------------------------------+
//| CONSTANTS                                                        |
//+------------------------------------------------------------------+
#define EXSS_PREFIX       "EXTB_"
#define TELEGRAM_BASE_URL "https://api.telegram.org/bot"
#define MAX_RETRIES       3
#define RETRY_DELAY_MS    1000

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+
int       g_totalPositions   = 0;
int       g_totalOrders      = 0;
datetime  g_lastSummaryTime  = 0;
datetime  g_lastDealTime     = 0;
int       g_sentMessages     = 0;
int       g_failedMessages   = 0;
bool      g_isConnected      = false;
string    g_botName          = "";
double    g_startBalance     = 0;
double    g_dayHighEquity    = 0;
double    g_dayLowEquity     = 0;

//--- Deal tracking
struct DealInfo
  {
   ulong          ticket;
   datetime       time;
  };
DealInfo g_processedDeals[];

//--- Position SL/TP tracking (for modification detection)
struct PositionSLTP
  {
   ulong          ticket;
   double         sl;
   double         tp;
   string         symbol;
  };
PositionSLTP g_positionSLTP[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   bool isTester = MQLInfoInteger(MQL_TESTER) != 0;

//--- Validate inputs (skip in Strategy Tester to pass Code Base validation)
   if(!isTester && InpBotToken == "" && InpChatID == "")
     {
      Print("ExMachina Telegram Bridge: ERROR — Bot Token and Chat ID are required.");
      Print("  → Get your Bot Token from @BotFather on Telegram");
      Print("  → Get your Chat ID from @userinfobot on Telegram");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(isTester)
     {
      Print("ExMachina Telegram Bridge: Running in Strategy Tester — Telegram disabled.");
      Print("  Attach to a live/demo chart for real notifications.");
      return(INIT_SUCCEEDED);
     }

//--- Allow WebRequest to Telegram API
   Print("ExMachina Telegram Bridge: Ensure https://api.telegram.org is added to");
   Print("  Tools → Options → Expert Advisors → Allow WebRequest for listed URL");

//--- Initialize state
   g_totalPositions  = PositionsTotal();
   g_totalOrders     = OrdersTotal();
   g_lastSummaryTime = TimeCurrent();
   g_startBalance    = AccountInfoDouble(ACCOUNT_BALANCE);
   g_dayHighEquity   = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayLowEquity    = g_dayHighEquity;

//--- Load recent deal history to avoid duplicate notifications on restart
   LoadRecentDeals();

//--- Snapshot current SL/TP for modification detection
   SnapshotPositionSLTP();

//--- Test connection
   g_isConnected = TestConnection();

   if(g_isConnected)
     {
      string initMsg = BuildInitMessage();
      SendTelegram(initMsg);
     }
   else
     {
      Print("ExMachina Telegram Bridge: WARNING — Could not connect to Telegram.");
      Print("  → Check your Bot Token and internet connection.");
      Print("  → Ensure https://api.telegram.org is in allowed WebRequest URLs.");
     }

//--- Create dashboard
   if(InpShowChart)
      CreateDashboard();

//--- Timer for summaries (every 60 seconds check)
   EventSetTimer(60);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Send shutdown message
   if(g_isConnected && reason != REASON_CHARTCHANGE)
     {
      string msg = GetEmoji("off") + " *ExMachina Telegram Bridge* — Disconnected\n";
      msg += "Reason: " + DeInitReasonToString(reason) + "\n";
      msg += GetEmoji("stats") + " Session: " + IntegerToString(g_sentMessages) + " messages sent";
      SendTelegram(msg);
     }

//--- Cleanup chart objects
   ObjectsDeleteAll(0, EXSS_PREFIX);

//--- Kill timer
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Update equity tracking
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > g_dayHighEquity) g_dayHighEquity = equity;
   if(equity < g_dayLowEquity)  g_dayLowEquity  = equity;

//--- Check for new deals (trades opened/closed)
   CheckDeals();

//--- Check for position changes
   CheckPositionChanges();

//--- Check for order changes
   CheckOrderChanges();

//--- Update dashboard
   if(InpShowChart)
      UpdateDashboard();
  }

//+------------------------------------------------------------------+
//| Timer function — periodic summaries                              |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(InpSummaryInterval == SUMMARY_OFF)
      return;

   datetime now = TimeCurrent();
   int intervalSec = InpSummaryInterval * 3600;

   if(now - g_lastSummaryTime >= intervalSec)
     {
      string summary = BuildSummaryMessage();
      if(SendTelegram(summary))
         g_lastSummaryTime = now;
     }
  }

//+------------------------------------------------------------------+
//| Trade transaction handler                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- Process deal additions (most reliable for trade events)
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      ProcessDeal(trans.deal);
     }
  }

//+------------------------------------------------------------------+
//| DEAL PROCESSING                                                  |
//+------------------------------------------------------------------+
void ProcessDeal(ulong dealTicket)
  {
   if(dealTicket == 0) return;
   if(IsDealProcessed(dealTicket)) return;

//--- Select deal from history
   if(!HistoryDealSelect(dealTicket))
     {
      //--- May need to request history first
      datetime from = TimeCurrent() - 300; // last 5 minutes
      HistorySelect(from, TimeCurrent());
      if(!HistoryDealSelect(dealTicket))
         return;
     }

   ENUM_DEAL_ENTRY entry  = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
   ENUM_DEAL_TYPE  type   = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
   string symbol          = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
   double volume           = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
   double price            = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
   double profit           = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
   double commission       = HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
   double swap             = HistoryDealGetDouble(dealTicket, DEAL_SWAP);
   long   magic            = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
   string comment          = HistoryDealGetString(dealTicket, DEAL_COMMENT);

//--- Apply filters
   if(!PassesFilter(symbol, volume, magic))
      return;

   string msg = "";

//--- Determine deal type
   switch(entry)
     {
      case DEAL_ENTRY_IN:
         if(!InpNotifyOpen) return;
         msg = BuildTradeOpenMessage(symbol, type, volume, price, magic, comment, dealTicket);
         break;

      case DEAL_ENTRY_OUT:
      case DEAL_ENTRY_OUT_BY:
         if(!InpNotifyClose) return;
         msg = BuildTradeCloseMessage(symbol, type, volume, price, profit, commission, swap, magic, comment, dealTicket);
         break;

      case DEAL_ENTRY_INOUT:
         if(!InpNotifyOpen) return;
         msg = BuildTradeReverseMessage(symbol, type, volume, price, profit, magic, dealTicket);
         break;

      default:
        {
         //--- Check for balance operations (deposit/withdrawal)
         if(type == DEAL_TYPE_BALANCE && InpNotifyDeposit)
           {
            msg = BuildBalanceMessage(profit);
           }
         else
            return;
        }
     }

   if(msg != "")
     {
      SendTelegram(msg);
      MarkDealProcessed(dealTicket);
     }
  }

//+------------------------------------------------------------------+
//| CHECK DEALS — fallback for OnTradeTransaction                    |
//+------------------------------------------------------------------+
void CheckDeals()
  {
   static datetime lastCheck = 0;
   datetime now = TimeCurrent();

   if(now - lastCheck < 2) return; // check every 2 seconds max
   lastCheck = now;

   datetime from = (g_lastDealTime > 0) ? g_lastDealTime : now - 60;
   HistorySelect(from, now + 86400);

   int totalDeals = HistoryDealsTotal();
   for(int i = totalDeals - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      if(dealTime <= g_lastDealTime) continue;

      ProcessDeal(ticket);

      if(dealTime > g_lastDealTime)
         g_lastDealTime = dealTime;
     }
  }

//+------------------------------------------------------------------+
//| CHECK POSITION CHANGES (SL/TP modifications)                     |
//+------------------------------------------------------------------+
void CheckPositionChanges()
  {
   int current = PositionsTotal();

   for(int i = current - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      double sl     = PositionGetDouble(POSITION_SL);
      double tp     = PositionGetDouble(POSITION_TP);
      long   magic  = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);

      //--- Find in snapshot
      int idx = FindPositionSnapshot(ticket);

      if(idx >= 0)
        {
         //--- Check for SL/TP change
         bool slChanged = NormalizeDouble(sl - g_positionSLTP[idx].sl, 8) != 0;
         bool tpChanged = NormalizeDouble(tp - g_positionSLTP[idx].tp, 8) != 0;

         if((slChanged || tpChanged) && InpNotifyModify)
           {
            if(PassesFilter(symbol, volume, magic))
              {
               string msg = BuildModifyMessage(symbol, ticket, 
                               g_positionSLTP[idx].sl, sl,
                               g_positionSLTP[idx].tp, tp);
               SendTelegram(msg);
              }
           }

         //--- Update snapshot
         g_positionSLTP[idx].sl = sl;
         g_positionSLTP[idx].tp = tp;
        }
      else
        {
         //--- New position not in snapshot — add it
         int size = ArraySize(g_positionSLTP);
         ArrayResize(g_positionSLTP, size + 1);
         g_positionSLTP[size].ticket = ticket;
         g_positionSLTP[size].sl     = sl;
         g_positionSLTP[size].tp     = tp;
         g_positionSLTP[size].symbol = symbol;
        }
     }

   //--- Remove closed positions from snapshot
   CleanupPositionSnapshot();

   g_totalPositions = current;
  }

//+------------------------------------------------------------------+
//| Find position in snapshot by ticket                              |
//+------------------------------------------------------------------+
int FindPositionSnapshot(ulong ticket)
  {
   for(int i = ArraySize(g_positionSLTP) - 1; i >= 0; i--)
     {
      if(g_positionSLTP[i].ticket == ticket)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Remove closed positions from snapshot                            |
//+------------------------------------------------------------------+
void CleanupPositionSnapshot()
  {
   for(int i = ArraySize(g_positionSLTP) - 1; i >= 0; i--)
     {
      bool found = false;
      for(int j = PositionsTotal() - 1; j >= 0; j--)
        {
         if(PositionGetTicket(j) == g_positionSLTP[i].ticket)
           { found = true; break; }
        }
      if(!found)
        {
         //--- Remove by shifting
         int last = ArraySize(g_positionSLTP) - 1;
         if(i < last)
            g_positionSLTP[i] = g_positionSLTP[last];
         ArrayResize(g_positionSLTP, last);
        }
     }
  }

//+------------------------------------------------------------------+
//| Snapshot current positions SL/TP                                 |
//+------------------------------------------------------------------+
void SnapshotPositionSLTP()
  {
   int total = PositionsTotal();
   ArrayResize(g_positionSLTP, total);

   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;

      g_positionSLTP[i].ticket = ticket;
      g_positionSLTP[i].sl     = PositionGetDouble(POSITION_SL);
      g_positionSLTP[i].tp     = PositionGetDouble(POSITION_TP);
      g_positionSLTP[i].symbol = PositionGetString(POSITION_SYMBOL);
     }
  }

//+------------------------------------------------------------------+
//| Build SL/TP modification message                                 |
//+------------------------------------------------------------------+
string BuildModifyMessage(string symbol, ulong ticket, 
                           double oldSL, double newSL,
                           double oldTP, double newTP)
  {
   string msg = GetEmoji("modify") + " *SL/TP MODIFIED*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("symbol") + " Symbol: *" + symbol + "*\n";
   msg += GetEmoji("ticket") + " Position #" + IntegerToString(ticket) + "\n";

   if(NormalizeDouble(oldSL - newSL, 8) != 0)
     {
      msg += GetEmoji("sl") + " SL: " + FormatPrice(symbol, oldSL) + " → " + FormatPrice(symbol, newSL) + "\n";
     }
   if(NormalizeDouble(oldTP - newTP, 8) != 0)
     {
      msg += GetEmoji("tp") + " TP: " + FormatPrice(symbol, oldTP) + " → " + FormatPrice(symbol, newTP) + "\n";
     }

   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
//| CHECK ORDER CHANGES (pending orders)                             |
//+------------------------------------------------------------------+
void CheckOrderChanges()
  {
   int current = OrdersTotal();

   if(current != g_totalOrders)
     {
      if(current > g_totalOrders && InpNotifyPending)
        {
         //--- New pending order(s)
         for(int i = current - 1; i >= 0; i--)
           {
            ulong ticket = OrderGetTicket(i);
            if(ticket == 0) continue;

            string symbol = OrderGetString(ORDER_SYMBOL);
            double volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            double price  = OrderGetDouble(ORDER_PRICE_OPEN);
            long   magic  = OrderGetInteger(ORDER_MAGIC);
            ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);

            if(!PassesFilter(symbol, volume, magic)) continue;

            string msg = BuildPendingOrderMessage(symbol, orderType, volume, price, magic, ticket);
            SendTelegram(msg);
           }
        }
      g_totalOrders = current;
     }
  }

//+------------------------------------------------------------------+
//| MESSAGE BUILDERS                                                 |
//+------------------------------------------------------------------+
string BuildInitMessage()
  {
   string msg = GetEmoji("rocket") + " *ExMachina Telegram Bridge* — Connected\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("account") + " Account: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n";
   msg += GetEmoji("server") + " Server: " + AccountInfoString(ACCOUNT_SERVER) + "\n";
   msg += GetEmoji("balance") + " Balance: " + FormatMoney(AccountInfoDouble(ACCOUNT_BALANCE)) + "\n";
   msg += GetEmoji("equity") + " Equity: " + FormatMoney(AccountInfoDouble(ACCOUNT_EQUITY)) + "\n";
   msg += GetEmoji("chart") + " Open Positions: " + IntegerToString(PositionsTotal()) + "\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += "_Precision before profit._";
   return msg;
  }

//+------------------------------------------------------------------+
string BuildTradeOpenMessage(string symbol, ENUM_DEAL_TYPE type, double volume,
                              double price, long magic, string comment, ulong ticket)
  {
   string direction = (type == DEAL_TYPE_BUY) ? "BUY" : "SELL";
   string dirEmoji  = (type == DEAL_TYPE_BUY) ? GetEmoji("buy") : GetEmoji("sell");

   string msg = dirEmoji + " *TRADE OPENED*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";

   if(InpStyle == STYLE_MINIMAL)
     {
      msg += symbol + " | " + direction + " | " + DoubleToString(volume, 2) + " lots @ " + FormatPrice(symbol, price) + "\n";
     }
   else
     {
      msg += GetEmoji("symbol") + " Symbol: *" + symbol + "*\n";
      msg += GetEmoji("dir") + " Direction: *" + direction + "*\n";
      msg += GetEmoji("lot") + " Volume: " + DoubleToString(volume, 2) + " lots\n";
      msg += GetEmoji("price") + " Price: " + FormatPrice(symbol, price) + "\n";

      if(magic > 0)
         msg += GetEmoji("magic") + " Magic: " + IntegerToString(magic) + "\n";
      if(comment != "")
         msg += GetEmoji("comment") + " Comment: " + comment + "\n";

      msg += GetEmoji("ticket") + " Deal #" + IntegerToString(ticket) + "\n";

      //--- Add SL/TP if position exists
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(PositionGetSymbol(i) == symbol)
           {
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            if(sl > 0) msg += GetEmoji("sl") + " SL: " + FormatPrice(symbol, sl) + "\n";
            if(tp > 0) msg += GetEmoji("tp") + " TP: " + FormatPrice(symbol, tp) + "\n";
            break;
           }
        }
     }

   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
string BuildTradeCloseMessage(string symbol, ENUM_DEAL_TYPE type, double volume,
                               double price, double profit, double commission,
                               double swap, long magic, string comment, ulong ticket)
  {
   double netProfit = profit + commission + swap;
   string profitEmoji = (netProfit >= 0) ? GetEmoji("win") : GetEmoji("loss");
   string direction   = (type == DEAL_TYPE_BUY) ? "BUY (close SELL)" : "SELL (close BUY)";

   string msg = profitEmoji + " *TRADE CLOSED*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";

   if(InpStyle == STYLE_MINIMAL)
     {
      msg += symbol + " | " + DoubleToString(volume, 2) + " lots @ " + FormatPrice(symbol, price);
      msg += " | P/L: " + FormatMoney(netProfit) + "\n";
     }
   else
     {
      msg += GetEmoji("symbol") + " Symbol: *" + symbol + "*\n";
      msg += GetEmoji("dir") + " Close: " + direction + "\n";
      msg += GetEmoji("lot") + " Volume: " + DoubleToString(volume, 2) + " lots\n";
      msg += GetEmoji("price") + " Price: " + FormatPrice(symbol, price) + "\n";
      msg += "───────────────────\n";
      msg += GetEmoji("profit") + " Gross P/L: " + FormatMoney(profit) + "\n";

      if(commission != 0)
         msg += GetEmoji("fee") + " Commission: " + FormatMoney(commission) + "\n";
      if(swap != 0)
         msg += GetEmoji("fee") + " Swap: " + FormatMoney(swap) + "\n";

      msg += "*" + GetEmoji("net") + " Net P/L: " + FormatMoney(netProfit) + "*\n";

      if(magic > 0)
         msg += GetEmoji("magic") + " Magic: " + IntegerToString(magic) + "\n";

      msg += GetEmoji("ticket") + " Deal #" + IntegerToString(ticket) + "\n";
     }

   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";

   //--- Add running account state
   msg += GetEmoji("balance") + " Balance: " + FormatMoney(AccountInfoDouble(ACCOUNT_BALANCE)) + "\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
string BuildTradeReverseMessage(string symbol, ENUM_DEAL_TYPE type, double volume,
                                 double price, double profit, long magic, ulong ticket)
  {
   string direction = (type == DEAL_TYPE_BUY) ? "BUY (reversal)" : "SELL (reversal)";

   string msg = GetEmoji("reverse") + " *POSITION REVERSED*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("symbol") + " Symbol: *" + symbol + "*\n";
   msg += GetEmoji("dir") + " New Direction: " + direction + "\n";
   msg += GetEmoji("lot") + " Volume: " + DoubleToString(volume, 2) + " lots\n";
   msg += GetEmoji("price") + " Price: " + FormatPrice(symbol, price) + "\n";
   msg += GetEmoji("profit") + " Closed P/L: " + FormatMoney(profit) + "\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
string BuildPendingOrderMessage(string symbol, ENUM_ORDER_TYPE orderType, double volume,
                                 double price, long magic, ulong ticket)
  {
   string typeStr = OrderTypeToString(orderType);

   string msg = GetEmoji("pending") + " *PENDING ORDER PLACED*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("symbol") + " Symbol: *" + symbol + "*\n";
   msg += GetEmoji("dir") + " Type: " + typeStr + "\n";
   msg += GetEmoji("lot") + " Volume: " + DoubleToString(volume, 2) + " lots\n";
   msg += GetEmoji("price") + " Price: " + FormatPrice(symbol, price) + "\n";

   if(magic > 0)
      msg += GetEmoji("magic") + " Magic: " + IntegerToString(magic) + "\n";

   msg += GetEmoji("ticket") + " Order #" + IntegerToString(ticket) + "\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
string BuildBalanceMessage(double amount)
  {
   bool isDeposit = (amount >= 0);
   string emoji = isDeposit ? GetEmoji("deposit") : GetEmoji("withdraw");
   string action = isDeposit ? "DEPOSIT" : "WITHDRAWAL";

   string msg = emoji + " *" + action + "*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("balance") + " Amount: " + FormatMoney(MathAbs(amount)) + "\n";
   msg += GetEmoji("equity") + " New Balance: " + FormatMoney(AccountInfoDouble(ACCOUNT_BALANCE)) + "\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   return msg;
  }

//+------------------------------------------------------------------+
string BuildSummaryMessage()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double margin  = AccountInfoDouble(ACCOUNT_MARGIN);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double profitSession = balance - g_startBalance;

   string msg = GetEmoji("stats") + " *ACCOUNT SUMMARY*\n";
   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("balance") + " Balance: " + FormatMoney(balance) + "\n";

   if(InpIncludeEquity)
     {
      msg += GetEmoji("equity") + " Equity: " + FormatMoney(equity) + "\n";
      msg += GetEmoji("margin") + " Free Margin: " + FormatMoney(freeMargin) + "\n";
     }

   msg += GetEmoji("chart") + " Open Positions: " + IntegerToString(PositionsTotal()) + "\n";

   //--- Floating P/L
   double floatingPL = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)))
         floatingPL += PositionGetDouble(POSITION_PROFIT)
                     + PositionGetDouble(POSITION_SWAP);
     }
   msg += GetEmoji("profit") + " Floating P/L: " + FormatMoney(floatingPL) + "\n";
   msg += GetEmoji("net") + " Session P/L: " + FormatMoney(profitSession) + "\n";

   if(InpIncludeDrawdown)
     {
      msg += "───────────────────\n";
      msg += GetEmoji("high") + " Day High Equity: " + FormatMoney(g_dayHighEquity) + "\n";
      msg += GetEmoji("low") + " Day Low Equity: " + FormatMoney(g_dayLowEquity) + "\n";

      if(g_dayHighEquity > 0)
        {
         double dd = (g_dayHighEquity - g_dayLowEquity) / g_dayHighEquity * 100.0;
         msg += GetEmoji("dd") + " Day Drawdown: " + DoubleToString(dd, 2) + "%\n";
        }
     }

   msg += "━━━━━━━━━━━━━━━━━━━━━━\n";
   msg += GetEmoji("time") + " " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   msg += "\n_Precision before profit._";
   return msg;
  }

//+------------------------------------------------------------------+
//| TELEGRAM SEND FUNCTION                                           |
//+------------------------------------------------------------------+
bool SendTelegram(string message)
  {
   if(InpBotToken == "" || InpChatID == "")
      return false;

   //--- Build URL
   string url = TELEGRAM_BASE_URL + InpBotToken + "/sendMessage";

   //--- URL-encode the message
   string encoded = UrlEncode(message);

   //--- Build POST body
   string postData = "chat_id=" + InpChatID
                   + "&text=" + encoded
                   + "&parse_mode=Markdown"
                   + "&disable_web_page_preview=true";

   //--- Retry loop
   for(int attempt = 0; attempt < MAX_RETRIES; attempt++)
     {
      char   post[];
      char   result[];
      string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
      string resultHeaders;

      StringToCharArray(postData, post, 0, WHOLE_ARRAY, CP_UTF8);
      // Remove null terminator
      ArrayResize(post, ArraySize(post) - 1);

      int timeout = 5000;
      int res = WebRequest("POST", url, headers, timeout, post, result, resultHeaders);

      if(res == 200)
        {
         g_sentMessages++;
         return true;
        }
      else if(res == -1)
        {
         int err = GetLastError();
         Print("ExMachina TG Bridge: WebRequest error ", err,
               " — Ensure https://api.telegram.org is in allowed URLs");
         if(attempt < MAX_RETRIES - 1)
            Sleep(RETRY_DELAY_MS);
        }
      else
        {
         string response = CharArrayToString(result);
         Print("ExMachina TG Bridge: HTTP ", res, " — ", response);

         //--- If rate limited (HTTP 429), wait longer
         if(res == 429)
           {
            Sleep(RETRY_DELAY_MS * 3);
            continue;
           }

         if(attempt < MAX_RETRIES - 1)
            Sleep(RETRY_DELAY_MS);
        }
     }

   g_failedMessages++;
   return false;
  }

//+------------------------------------------------------------------+
//| TEST CONNECTION                                                  |
//+------------------------------------------------------------------+
bool TestConnection()
  {
   string url = TELEGRAM_BASE_URL + InpBotToken + "/getMe";

   char   post[];
   char   result[];
   string resultHeaders;

   int res = WebRequest("GET", url, "", 5000, post, result, resultHeaders);

   if(res == 200)
     {
      string response = CharArrayToString(result);
      //--- Try to extract bot name
      int namePos = StringFind(response, "\"first_name\":\"");
      if(namePos >= 0)
        {
         int start = namePos + 14;
         int end   = StringFind(response, "\"", start);
         if(end > start)
            g_botName = StringSubstr(response, start, end - start);
        }
      Print("ExMachina TG Bridge: Connected to bot @", g_botName);
      return true;
     }

   Print("ExMachina TG Bridge: Connection test failed (HTTP ", res, ")");
   return false;
  }

//+------------------------------------------------------------------+
//| FILTER                                                           |
//+------------------------------------------------------------------+
bool PassesFilter(string symbol, double volume, long magic)
  {
//--- Symbol filter
   if(InpSymbolFilter != "")
     {
      if(StringFind(InpSymbolFilter, symbol) < 0)
         return false;
     }

//--- Lot filter
   if(InpMinLotFilter > 0 && volume < InpMinLotFilter)
      return false;

//--- Magic filter
   if(InpMagicFilter >= 0 && magic != InpMagicFilter)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| DEAL TRACKING (avoid duplicates)                                 |
//+------------------------------------------------------------------+
bool IsDealProcessed(ulong ticket)
  {
   for(int i = ArraySize(g_processedDeals) - 1; i >= 0; i--)
     {
      if(g_processedDeals[i].ticket == ticket)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
void MarkDealProcessed(ulong ticket)
  {
   int size = ArraySize(g_processedDeals);
   ArrayResize(g_processedDeals, size + 1);
   g_processedDeals[size].ticket = ticket;
   g_processedDeals[size].time   = TimeCurrent();

//--- Cleanup old entries (keep last 500)
   if(ArraySize(g_processedDeals) > 500)
     {
      int excess = ArraySize(g_processedDeals) - 500;
      for(int i = 0; i < ArraySize(g_processedDeals) - excess; i++)
         g_processedDeals[i] = g_processedDeals[i + excess];
      ArrayResize(g_processedDeals, 500);
     }
  }

//+------------------------------------------------------------------+
void LoadRecentDeals()
  {
   datetime from = TimeCurrent() - 3600; // Last hour
   HistorySelect(from, TimeCurrent());

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
         MarkDealProcessed(ticket);
     }

   if(total > 0)
      g_lastDealTime = (datetime)HistoryDealGetInteger(
                          HistoryDealGetTicket(total - 1), DEAL_TIME);
  }

//+------------------------------------------------------------------+
//| DASHBOARD                                                        |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   int x = 10, y = 30;
   int width = 260, height = 120;

//--- Background
   CreateRectLabel(EXSS_PREFIX + "bg", x, y, width, height, InpDashColor);

//--- Title
   CreateLabel(EXSS_PREFIX + "title", x + 10, y + 8,
               "EXMACHINA TELEGRAM BRIDGE", InpAccentColor, 8, true);

//--- Status
   CreateLabel(EXSS_PREFIX + "status", x + 10, y + 28,
               "Status: " + (g_isConnected ? "CONNECTED" : "DISCONNECTED"),
               g_isConnected ? clrLime : clrRed, 8, false);

//--- Bot name
   CreateLabel(EXSS_PREFIX + "bot", x + 10, y + 48,
               "Bot: @" + (g_botName != "" ? g_botName : "N/A"),
               InpTextColor, 8, false);

//--- Messages counter
   CreateLabel(EXSS_PREFIX + "msgs", x + 10, y + 68,
               "Sent: 0 | Failed: 0",
               InpTextColor, 8, false);

//--- Tagline
   CreateLabel(EXSS_PREFIX + "tag", x + 10, y + 93,
               "Precision before profit.", InpAccentColor, 7, false);
  }

//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   ObjectSetString(0, EXSS_PREFIX + "status", OBJPROP_TEXT,
                   "Status: " + (g_isConnected ? "CONNECTED" : "DISCONNECTED"));
   ObjectSetInteger(0, EXSS_PREFIX + "status", OBJPROP_COLOR,
                    g_isConnected ? clrLime : clrRed);

   ObjectSetString(0, EXSS_PREFIX + "msgs", OBJPROP_TEXT,
                   "Sent: " + IntegerToString(g_sentMessages) +
                   " | Failed: " + IntegerToString(g_failedMessages));
  }

//+------------------------------------------------------------------+
//| CHART OBJECT HELPERS                                             |
//+------------------------------------------------------------------+
void CreateRectLabel(string name, int x, int y, int w, int h, color clr)
  {
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, InpAccentColor);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr,
                 int fontSize, bool bold)
  {
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS                                                |
//+------------------------------------------------------------------+
string GetEmoji(string key)
  {
   if(InpStyle != STYLE_EMOJI && InpStyle != STYLE_DETAILED)
      return "";

   if(key == "rocket")   return "\xF0\x9F\x9A\x80 ";
   if(key == "buy")      return "\xF0\x9F\x9F\xA2 ";  // green circle
   if(key == "sell")     return "\xF0\x9F\x94\xB4 ";  // red circle
   if(key == "win")      return "\xE2\x9C\x85 ";       // check
   if(key == "loss")     return "\xE2\x9D\x8C ";       // cross
   if(key == "stats")    return "\xF0\x9F\x93\x8A ";
   if(key == "balance")  return "\xF0\x9F\x92\xB0 ";
   if(key == "equity")   return "\xF0\x9F\x92\x8E ";
   if(key == "chart")    return "\xF0\x9F\x93\x88 ";
   if(key == "profit")   return "\xF0\x9F\x92\xB5 ";
   if(key == "symbol")   return "\xF0\x9F\x8E\xAF ";
   if(key == "dir")      return "\xE2\x86\x94\xEF\xB8\x8F ";
   if(key == "lot")      return "\xF0\x9F\x93\xA6 ";
   if(key == "price")    return "\xF0\x9F\x92\xB2 ";
   if(key == "sl")       return "\xF0\x9F\x9B\x91 ";
   if(key == "tp")       return "\xF0\x9F\x8E\xAF ";
   if(key == "magic")    return "\xF0\x9F\x94\xA7 ";
   if(key == "comment")  return "\xF0\x9F\x92\xAC ";
   if(key == "ticket")   return "\xF0\x9F\x8E\xAB ";
   if(key == "net")      return "\xF0\x9F\x92\xAF ";
   if(key == "fee")      return "\xF0\x9F\x92\xB8 ";
   if(key == "time")     return "\xF0\x9F\x95\x90 ";
   if(key == "account")  return "\xF0\x9F\x91\xA4 ";
   if(key == "server")   return "\xF0\x9F\x96\xA5 ";
   if(key == "pending")  return "\xE2\x8F\xB3 ";
   if(key == "reverse")  return "\xF0\x9F\x94\x84 ";
   if(key == "deposit")  return "\xE2\xAC\x86\xEF\xB8\x8F ";
   if(key == "withdraw") return "\xE2\xAC\x87\xEF\xB8\x8F ";
   if(key == "margin")   return "\xF0\x9F\x8F\xA6 ";
   if(key == "high")     return "\xF0\x9F\x94\xBA ";
   if(key == "low")      return "\xF0\x9F\x94\xBB ";
   if(key == "dd")       return "\xE2\x9A\xA0\xEF\xB8\x8F ";
   if(key == "off")      return "\xF0\x9F\x94\xB4 ";
   if(key == "modify")   return "\xE2\x9C\x8F\xEF\xB8\x8F ";  // pencil

   return "";
  }

//+------------------------------------------------------------------+
string FormatMoney(double value)
  {
   string currency = AccountInfoString(ACCOUNT_CURRENCY);
   string sign = (value >= 0) ? "" : "-";
   double abs_val = MathAbs(value);

   return sign + "$" + DoubleToString(abs_val, 2) + " " + currency;
  }

//+------------------------------------------------------------------+
string FormatPrice(string symbol, double price)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return DoubleToString(price, digits);
  }

//+------------------------------------------------------------------+
string OrderTypeToString(ENUM_ORDER_TYPE type)
  {
   switch(type)
     {
      case ORDER_TYPE_BUY_LIMIT:       return "Buy Limit";
      case ORDER_TYPE_SELL_LIMIT:      return "Sell Limit";
      case ORDER_TYPE_BUY_STOP:        return "Buy Stop";
      case ORDER_TYPE_SELL_STOP:       return "Sell Stop";
      case ORDER_TYPE_BUY_STOP_LIMIT:  return "Buy Stop Limit";
      case ORDER_TYPE_SELL_STOP_LIMIT: return "Sell Stop Limit";
      default:                         return "Unknown";
     }
  }

//+------------------------------------------------------------------+
string DeInitReasonToString(int reason)
  {
   switch(reason)
     {
      case REASON_PROGRAM:     return "EA stopped";
      case REASON_REMOVE:      return "EA removed";
      case REASON_RECOMPILE:   return "Recompiled";
      case REASON_CHARTCHANGE: return "Chart changed";
      case REASON_CHARTCLOSE:  return "Chart closed";
      case REASON_PARAMETERS:  return "Parameters changed";
      case REASON_ACCOUNT:     return "Account changed";
      case REASON_TEMPLATE:    return "Template applied";
      case REASON_INITFAILED:  return "Init failed";
      case REASON_CLOSE:       return "Terminal closed";
      default:                 return "Unknown (" + IntegerToString(reason) + ")";
     }
  }

//+------------------------------------------------------------------+
//| URL ENCODING                                                     |
//+------------------------------------------------------------------+
string UrlEncode(string text)
  {
   string result = "";
   uchar  src[];
   int    len = StringToCharArray(text, src, 0, WHOLE_ARRAY, CP_UTF8) - 1;

   for(int i = 0; i < len; i++)
     {
      uchar ch = src[i];

      if((ch >= 'A' && ch <= 'Z') ||
         (ch >= 'a' && ch <= 'z') ||
         (ch >= '0' && ch <= '9') ||
         ch == '-' || ch == '_' || ch == '.' || ch == '~')
        {
         result += CharToString(ch);
        }
      else
        {
         result += "%" + StringFormat("%02X", ch);
        }
     }

   return result;
  }

//+------------------------------------------------------------------+
