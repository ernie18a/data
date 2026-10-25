//+------------------------------------------------------------------+
//|                                              ASQ_RiskGuard.mq5   |
//|                              Copyright 2026, AlgoSphere Quant    |
//|                        https://www.mql5.com/en/users/robin2.0    |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, AlgoSphere Quant"
#property link        "https://www.mql5.com/en/users/robin2.0"
#property version     "2.00"
#property description "ASQ RiskGuard v2 — Professional risk management EA"
#property description "Equity & daily DD protection, trailing max drawdown,"
#property description "session filter, spread guard, risk scoring, visual dashboard."
#property description "AlgoSphere Quant — Precision before profit."

//+------------------------------------------------------------------+
//| Includes                                                          |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Enums                                                             |
//+------------------------------------------------------------------+
enum ENUM_CLOSE_METHOD
  {
   CLOSE_ALL_POSITIONS = 0,    // Close all positions
   CLOSE_LOSING_ONLY   = 1,    // Close losing positions only
   CLOSE_LARGEST_LOSS  = 2     // Close largest loser first
  };

enum ENUM_LOT_MODE
  {
   LOT_FIXED           = 0,    // Fixed lot size
   LOT_RISK_PERCENT    = 1,    // Risk % of balance per trade
   LOT_RISK_MONEY      = 2     // Risk fixed $ amount per trade
  };

enum ENUM_DD_MODE
  {
   DD_PERCENT          = 0,    // Drawdown as % of balance
   DD_MONEY            = 1     // Drawdown as fixed $ amount
  };

enum ENUM_DD_BASE
  {
   DD_FROM_BALANCE     = 0,    // From current balance
   DD_FROM_PEAK        = 1     // From peak equity (trailing)
  };

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
input group              "═══════ EQUITY PROTECTION ═══════"
input bool      InpEnableEquityStop    = true;           // Enable equity stop
input ENUM_DD_MODE InpDDMode           = DD_PERCENT;     // Drawdown calculation mode
input double    InpMaxDrawdownPct      = 5.0;            // Max drawdown % (if DD_PERCENT)
input double    InpMaxDrawdownMoney    = 500.0;          // Max drawdown $ (if DD_MONEY)
input ENUM_DD_BASE InpDDBase           = DD_FROM_BALANCE;// Drawdown measured from
input ENUM_CLOSE_METHOD InpCloseMethod = CLOSE_ALL_POSITIONS; // Close method when triggered

input group              "═══════ DAILY LOSS LIMIT ═══════"
input bool      InpEnableDailyLimit    = true;           // Enable daily loss limit
input ENUM_DD_MODE InpDailyMode        = DD_PERCENT;     // Daily limit mode
input double    InpDailyLimitPct       = 3.0;            // Daily loss limit % (if DD_PERCENT)
input double    InpDailyLimitMoney     = 300.0;          // Daily loss limit $ (if DD_MONEY)
input bool      InpDisableTradingDaily = true;           // Disable trading after daily limit hit

input group              "═══════ SESSION FILTER ═══════"
input bool      InpEnableSessionFilter = false;          // Enable session-based blocking
input string    InpSessionStart        = "08:00";        // Allowed session start (server time)
input string    InpSessionEnd          = "20:00";        // Allowed session end (server time)
input bool      InpCloseOutsideSession = false;          // Close positions outside session

input group              "═══════ SPREAD GUARD ═══════"
input bool      InpEnableSpreadGuard   = false;          // Enable spread guard
input int       InpMaxSpreadPoints     = 30;             // Max allowed spread (points)

input group              "═══════ AUTO LOT SIZING ═══════"
input ENUM_LOT_MODE InpLotMode         = LOT_RISK_PERCENT; // Lot sizing mode
input double    InpFixedLot            = 0.01;           // Fixed lot size
input double    InpRiskPercent         = 1.0;            // Risk % per trade
input double    InpRiskMoney           = 100.0;          // Risk $ per trade
input int       InpDefaultSLPoints     = 200;            // Default SL for lot calc (points)

input group              "═══════ POSITION LIMITS ═══════"
input int       InpMaxOpenPositions    = 5;              // Max simultaneous positions (0=off)
input double    InpMaxTotalLots        = 1.0;            // Max total lot exposure (0=off)
input int       InpMaxOrdersPerDay     = 10;             // Max orders per day (0=off)

input group              "═══════ ALERTS ═══════"
input bool      InpAlertPopup          = true;           // Popup alert
input bool      InpAlertSound          = true;           // Sound alert
input string    InpAlertSoundFile      = "alert.wav";    // Alert sound file
input bool      InpAlertPush           = false;          // Push notification
input bool      InpAlertEmail          = false;          // Email alert
input int       InpWarningPct          = 80;             // Warning at % of limit (0=off)

input group              "═══════ DASHBOARD ═══════"
input bool      InpShowDashboard       = true;           // Show on-chart dashboard
input int       InpDashX               = 15;             // Dashboard X position
input int       InpDashY               = 25;             // Dashboard Y position
input int       InpFontSize            = 9;              // Dashboard font size
input color     InpAccentColor         = C'0,150,255';   // Accent color (brand)
input color     InpSafeColor           = C'0,200,120';   // Safe status color
input color     InpWarningColor        = C'255,180,0';   // Warning status color
input color     InpDangerColor         = C'240,50,70';   // Danger status color
input color     InpTextColor           = C'175,180,192'; // Normal text color
input color     InpDimColor            = C'70,75,90';    // Dim/secondary text
input color     InpBgColor             = C'12,14,22';    // Background panel color
input color     InpBorderColor         = C'28,32,48';    // Border color

input group              "═══════ ADVANCED ═══════"
input int       InpMagicFilter         = 0;              // Magic number filter (0=all EAs)
input bool      InpProtectPendings     = true;           // Also delete pending orders on trigger
input int       InpCooldownSeconds     = 5;              // Cooldown between close attempts
input bool      InpLogToFile           = true;           // Log events to file

//+------------------------------------------------------------------+
//| Constants                                                         |
//+------------------------------------------------------------------+
const string OBJ_PREFIX   = "ASQ_RG_";
const string EA_TAG       = "ASQ RiskGuard";
const string EA_VERSION   = "2.0";
const string LOG_FILENAME = "ASQ_RiskGuard_Log.csv";
const int    EQUITY_HISTORY_SIZE = 60;

//+------------------------------------------------------------------+
//| Global variables                                                   |
//+------------------------------------------------------------------+
CTrade         g_trade;
CPositionInfo  g_pos;
CAccountInfo   g_account;

double   g_startBalance      = 0;
double   g_dayStartEquity    = 0;
double   g_peakEquity        = 0;
datetime g_currentDay        = 0;
int      g_ordersToday       = 0;
bool     g_dailyLimitHit     = false;
bool     g_equityStopHit     = false;
datetime g_lastCloseAttempt  = 0;
int      g_logHandle         = INVALID_HANDLE;
int      g_sessionStartMin   = 480;
int      g_sessionEndMin     = 1200;

//--- equity history ring buffer
double   g_equityHist[];
int      g_eqHistIdx         = 0;
bool     g_eqHistFull        = false;
double   g_eqHistMin         = 0;
double   g_eqHistMax         = 0;
datetime g_lastEqSample      = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_startBalance   = g_account.Balance();
   g_dayStartEquity = g_account.Equity();
   g_peakEquity     = g_account.Equity();
   g_currentDay     = GetDayStart(TimeCurrent());
   g_ordersToday    = 0;
   g_dailyLimitHit  = false;
   g_equityStopHit  = false;

//--- auto-detect filling mode
   AutoDetectFilling();
   g_trade.SetExpertMagicNumber(0);
   g_trade.SetDeviationInPoints(20);

//--- parse session times
   g_sessionStartMin = ParseTimeToMinutes(InpSessionStart);
   g_sessionEndMin   = ParseTimeToMinutes(InpSessionEnd);

//--- initialize equity history buffer
   ArrayResize(g_equityHist, EQUITY_HISTORY_SIZE);
   ArrayInitialize(g_equityHist, g_account.Equity());
   g_eqHistIdx  = 0;
   g_eqHistFull = false;

//--- open log file
   if(InpLogToFile)
     {
      g_logHandle = FileOpen(LOG_FILENAME, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ',');
      if(g_logHandle != INVALID_HANDLE)
        {
         FileWrite(g_logHandle, "Timestamp", "Event", "Equity", "Balance",
                   "Drawdown%", "DailyPnL", "RiskScore", "OpenPositions", "Details");
         LogEvent("INIT", "RiskGuard v" + EA_VERSION + " started");
        }
     }

   if(InpShowDashboard)
      CreateDashboard();

   PrintFormat("%s v%s initialized | Balance: %.2f | Equity: %.2f | Fill: auto",
               EA_TAG, EA_VERSION, g_startBalance, g_dayStartEquity);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, OBJ_PREFIX);

   if(g_logHandle != INVALID_HANDLE)
     {
      LogEvent("DEINIT", "RiskGuard stopped");
      FileClose(g_logHandle);
      g_logHandle = INVALID_HANDLE;
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for new day
   CheckNewDay();

//--- update peak equity (for trailing DD)
   double equity = g_account.Equity();
   if(equity > g_peakEquity)
      g_peakEquity = equity;

//--- sample equity for mini-chart (every 10 seconds)
   if(TimeCurrent() - g_lastEqSample >= 10)
     {
      SampleEquity(equity);
      g_lastEqSample = TimeCurrent();
     }

//--- session filter: close positions outside session if configured
   if(InpEnableSessionFilter && InpCloseOutsideSession)
     {
      if(!IsInSession() && CountOpenPositions() > 0)
        {
         LogEvent("SESSION_CLOSE", "Closing positions — outside session window");
         CloseAllPositions();
        }
     }

//--- run protection checks
   if(InpEnableEquityStop && !g_equityStopHit)
      CheckEquityStop(equity);

   if(InpEnableDailyLimit && !g_dailyLimitHit)
      CheckDailyLimit(equity);

//--- update dashboard
   if(InpShowDashboard)
      UpdateDashboard(equity);
  }

//+------------------------------------------------------------------+
//| Check for new trading day                                          |
//+------------------------------------------------------------------+
void CheckNewDay()
  {
   datetime today = GetDayStart(TimeCurrent());
   if(today != g_currentDay)
     {
      g_currentDay     = today;
      g_dayStartEquity = g_account.Equity();
      g_ordersToday    = 0;
      g_dailyLimitHit  = false;

      //--- only reset peak if drawdown is from balance (not trailing)
      if(InpDDBase == DD_FROM_BALANCE)
         g_peakEquity = g_account.Equity();

      LogEvent("NEW_DAY", StringFormat("Day reset. Equity: %.2f | Peak: %.2f",
               g_dayStartEquity, g_peakEquity));
     }
  }

//+------------------------------------------------------------------+
//| Check equity stop protection                                       |
//+------------------------------------------------------------------+
void CheckEquityStop(const double equity)
  {
   double refValue  = (InpDDBase == DD_FROM_PEAK) ? g_peakEquity : g_account.Balance();
   double drawdown  = refValue - equity;
   double ddPct     = (refValue > 0) ? (drawdown / refValue) * 100.0 : 0;

   double threshold = 0;
   double current   = 0;
   bool   triggered = false;

   if(InpDDMode == DD_PERCENT)
     {
      threshold = InpMaxDrawdownPct;
      current   = ddPct;
      triggered = (ddPct >= InpMaxDrawdownPct);
     }
   else
     {
      threshold = InpMaxDrawdownMoney;
      current   = drawdown;
      triggered = (drawdown >= InpMaxDrawdownMoney);
     }

//--- warning check
   if(InpWarningPct > 0 && !triggered)
     {
      double warningLevel = threshold * InpWarningPct / 100.0;
      if(current >= warningLevel)
        {
         static datetime lastWarning = 0;
         if(TimeCurrent() - lastWarning > 60)
           {
            string msg = StringFormat("%s | Drawdown at %.1f%% of limit",
                                      EA_TAG, (current / threshold) * 100);
            FireAlert(msg);
            lastWarning = TimeCurrent();
           }
        }
     }

//--- trigger equity stop
   if(triggered)
     {
      g_equityStopHit = true;
      string baseStr = (InpDDBase == DD_FROM_PEAK) ? "peak" : "balance";
      string msg = StringFormat("%s | EQUITY STOP! DD: %.2f%% (%.2f$) from %s",
                                EA_TAG, ddPct, drawdown, baseStr);
      FireAlert(msg);
      LogEvent("EQUITY_STOP", msg);
      ExecuteCloseMethod();
     }
  }

//+------------------------------------------------------------------+
//| Check daily loss limit                                             |
//+------------------------------------------------------------------+
void CheckDailyLimit(const double equity)
  {
   double dailyPnL   = equity - g_dayStartEquity;
   double dailyLoss  = (dailyPnL < 0) ? MathAbs(dailyPnL) : 0;
   double dailyPct   = (g_dayStartEquity > 0) ? (dailyLoss / g_dayStartEquity) * 100.0 : 0;

   double threshold = 0;
   double current   = 0;
   bool   triggered = false;

   if(InpDailyMode == DD_PERCENT)
     {
      threshold = InpDailyLimitPct;
      current   = dailyPct;
      triggered = (dailyPct >= InpDailyLimitPct && dailyPnL < 0);
     }
   else
     {
      threshold = InpDailyLimitMoney;
      current   = dailyLoss;
      triggered = (dailyLoss >= InpDailyLimitMoney && dailyPnL < 0);
     }

//--- warning check
   if(InpWarningPct > 0 && !triggered && dailyPnL < 0)
     {
      double warningLevel = threshold * InpWarningPct / 100.0;
      if(current >= warningLevel)
        {
         static datetime lastDailyWarn = 0;
         if(TimeCurrent() - lastDailyWarn > 60)
           {
            string msg = StringFormat("%s | Daily loss at %.1f%% of limit",
                                      EA_TAG, (current / threshold) * 100);
            FireAlert(msg);
            lastDailyWarn = TimeCurrent();
           }
        }
     }

//--- trigger daily limit
   if(triggered)
     {
      g_dailyLimitHit = true;
      string msg = StringFormat("%s | DAILY LIMIT! Loss: %.2f%% (%.2f$)",
                                EA_TAG, dailyPct, dailyLoss);
      FireAlert(msg);
      LogEvent("DAILY_LIMIT", msg);
      ExecuteCloseMethod();
     }
  }

//+------------------------------------------------------------------+
//| Execute the configured close method                                |
//+------------------------------------------------------------------+
void ExecuteCloseMethod()
  {
   if(TimeCurrent() - g_lastCloseAttempt < InpCooldownSeconds)
      return;
   g_lastCloseAttempt = TimeCurrent();

   switch(InpCloseMethod)
     {
      case CLOSE_ALL_POSITIONS:  CloseAllPositions();    break;
      case CLOSE_LOSING_ONLY:    CloseLosingPositions(); break;
      case CLOSE_LARGEST_LOSS:   CloseLargestLoser();    break;
     }

   if(InpProtectPendings)
      DeleteAllPendings();
  }

//+------------------------------------------------------------------+
//| Close all open positions                                           |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!g_pos.SelectByIndex(i)) continue;
      if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;

      ulong ticket = g_pos.Ticket();
      if(!g_trade.PositionClose(ticket, 20))
         PrintFormat("%s: Failed to close #%I64u. Error: %d", EA_TAG, ticket, GetLastError());
      else
         LogEvent("CLOSE", StringFormat("Closed #%I64u P&L: %.2f", ticket, g_pos.Profit()));
     }
  }

//+------------------------------------------------------------------+
//| Close only losing positions                                        |
//+------------------------------------------------------------------+
void CloseLosingPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!g_pos.SelectByIndex(i)) continue;
      if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;

      double profit = g_pos.Profit() + g_pos.Swap() + g_pos.Commission();
      if(profit < 0)
        {
         ulong ticket = g_pos.Ticket();
         if(!g_trade.PositionClose(ticket, 20))
            PrintFormat("%s: Failed to close #%I64u. Error: %d", EA_TAG, ticket, GetLastError());
         else
            LogEvent("CLOSE_LOSER", StringFormat("Closed loser #%I64u P&L: %.2f", ticket, profit));
        }
     }
  }

//+------------------------------------------------------------------+
//| Close the single largest losing position                           |
//+------------------------------------------------------------------+
void CloseLargestLoser()
  {
   double worstPnL  = 0;
   ulong  worstTick = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(!g_pos.SelectByIndex(i)) continue;
      if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;

      double pnl = g_pos.Profit() + g_pos.Swap() + g_pos.Commission();
      if(pnl < worstPnL)
        {
         worstPnL  = pnl;
         worstTick = g_pos.Ticket();
        }
     }

   if(worstTick > 0)
     {
      if(!g_trade.PositionClose(worstTick, 20))
         PrintFormat("%s: Failed to close #%I64u. Error: %d", EA_TAG, worstTick, GetLastError());
      else
         LogEvent("CLOSE_WORST", StringFormat("Closed worst #%I64u P&L: %.2f", worstTick, worstPnL));
     }
  }

//+------------------------------------------------------------------+
//| Delete all pending orders                                          |
//+------------------------------------------------------------------+
void DeleteAllPendings()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(InpMagicFilter > 0 && OrderGetInteger(ORDER_MAGIC) != InpMagicFilter) continue;

      if(!g_trade.OrderDelete(ticket))
         PrintFormat("%s: Failed to delete pending #%I64u. Error: %d", EA_TAG, ticket, GetLastError());
      else
         LogEvent("DELETE_PENDING", StringFormat("Deleted pending #%I64u", ticket));
     }
  }

//+------------------------------------------------------------------+
//| Calculate optimal lot size based on risk parameters                |
//+------------------------------------------------------------------+
double CalculateLotSize(const string symbol, const int slPoints)
  {
   if(InpLotMode == LOT_FIXED)
      return NormalizeLot(symbol, InpFixedLot);

   double balance   = g_account.Balance();
   double riskMoney = (InpLotMode == LOT_RISK_PERCENT)
                      ? balance * InpRiskPercent / 100.0
                      : InpRiskMoney;

   int sl = (slPoints > 0) ? slPoints : InpDefaultSLPoints;
   if(sl <= 0) sl = 100;

   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double pointVal  = SymbolInfoDouble(symbol, SYMBOL_POINT);

   if(tickValue <= 0 || tickSize <= 0 || pointVal <= 0)
      return NormalizeLot(symbol, InpFixedLot);

   double valuePerPoint = tickValue * (pointVal / tickSize);
   return NormalizeLot(symbol, riskMoney / (sl * valuePerPoint));
  }

//+------------------------------------------------------------------+
//| Normalize lot to broker constraints                                |
//+------------------------------------------------------------------+
double NormalizeLot(const string symbol, double lot)
  {
   double minLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(lotStep <= 0) lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);

   return NormalizeDouble(lot, (int)MathCeil(-MathLog10(lotStep)));
  }

//+------------------------------------------------------------------+
//| Check if new trade is allowed by all guards                        |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(g_equityStopHit)
     { PrintFormat("%s: Blocked — equity stop active.", EA_TAG); return false; }

   if(g_dailyLimitHit && InpDisableTradingDaily)
     { PrintFormat("%s: Blocked — daily limit active.", EA_TAG); return false; }

   if(InpEnableSessionFilter && !IsInSession())
     { PrintFormat("%s: Blocked — outside session %s-%s.", EA_TAG, InpSessionStart, InpSessionEnd); return false; }

   if(InpEnableSpreadGuard)
     {
      int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread > InpMaxSpreadPoints)
        { PrintFormat("%s: Blocked — spread %d > %d.", EA_TAG, spread, InpMaxSpreadPoints); return false; }
     }

   if(InpMaxOpenPositions > 0 && CountOpenPositions() >= InpMaxOpenPositions)
     { PrintFormat("%s: Blocked — max positions reached.", EA_TAG); return false; }

   if(InpMaxTotalLots > 0 && GetTotalLots() >= InpMaxTotalLots)
     { PrintFormat("%s: Blocked — max lot exposure reached.", EA_TAG); return false; }

   if(InpMaxOrdersPerDay > 0 && g_ordersToday >= InpMaxOrdersPerDay)
     { PrintFormat("%s: Blocked — max daily orders reached.", EA_TAG); return false; }

   return true;
  }

//+------------------------------------------------------------------+
//| Compute composite risk score 0–100 (0=safe, 100=critical)          |
//+------------------------------------------------------------------+
int ComputeRiskScore(const double equity)
  {
   double score  = 0;
   double weight = 0;

//--- drawdown component (40%)
   double refVal   = (InpDDBase == DD_FROM_PEAK) ? g_peakEquity : g_account.Balance();
   double ddPct    = (refVal > 0) ? ((refVal - equity) / refVal) * 100.0 : 0;
   double ddLimit  = (InpDDMode == DD_PERCENT) ? InpMaxDrawdownPct : 100.0;
   double ddRatio  = (ddLimit > 0) ? MathMin(MathMax(ddPct,0) / ddLimit * 100.0, 100.0) : 0;
   score += ddRatio * 0.40;
   weight += 0.40;

//--- daily loss component (30%)
   if(InpEnableDailyLimit)
     {
      double dailyPnL  = equity - g_dayStartEquity;
      double dailyLoss = (dailyPnL < 0) ? MathAbs(dailyPnL) : 0;
      double dayPct    = (g_dayStartEquity > 0) ? (dailyLoss / g_dayStartEquity) * 100.0 : 0;
      double dayLimit  = (InpDailyMode == DD_PERCENT) ? InpDailyLimitPct : 100.0;
      double dayRatio  = (dayLimit > 0) ? MathMin(dayPct / dayLimit * 100.0, 100.0) : 0;
      score += dayRatio * 0.30;
      weight += 0.30;
     }

//--- exposure component (20%)
   if(InpMaxOpenPositions > 0 || InpMaxTotalLots > 0)
     {
      double expRatio = 0;
      if(InpMaxOpenPositions > 0)
         expRatio = MathMax(expRatio, (double)CountOpenPositions() / InpMaxOpenPositions * 100.0);
      if(InpMaxTotalLots > 0)
         expRatio = MathMax(expRatio, GetTotalLots() / InpMaxTotalLots * 100.0);
      score += MathMin(expRatio, 100.0) * 0.20;
      weight += 0.20;
     }

//--- spread component (10%)
   if(InpEnableSpreadGuard && InpMaxSpreadPoints > 0)
     {
      int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double spRatio = MathMin((double)spread / InpMaxSpreadPoints * 100.0, 100.0);
      score += spRatio * 0.10;
      weight += 0.10;
     }

   return (weight > 0) ? (int)MathRound(score / weight) : 0;
  }

//+------------------------------------------------------------------+
//| Session filter                                                     |
//+------------------------------------------------------------------+
bool IsInSession()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int nowMin = dt.hour * 60 + dt.min;

   if(g_sessionStartMin <= g_sessionEndMin)
      return (nowMin >= g_sessionStartMin && nowMin < g_sessionEndMin);
   else
      return (nowMin >= g_sessionStartMin || nowMin < g_sessionEndMin);
  }

int ParseTimeToMinutes(const string timeStr)
  {
   int sep = StringFind(timeStr, ":");
   if(sep < 0) return 0;
   int h = (int)StringToInteger(StringSubstr(timeStr, 0, sep));
   int m = (int)StringToInteger(StringSubstr(timeStr, sep + 1));
   return h * 60 + m;
  }

//+------------------------------------------------------------------+
//| Sample equity into ring buffer                                     |
//+------------------------------------------------------------------+
void SampleEquity(const double equity)
  {
   g_equityHist[g_eqHistIdx] = equity;
   g_eqHistIdx++;
   if(g_eqHistIdx >= EQUITY_HISTORY_SIZE)
     {
      g_eqHistIdx = 0;
      g_eqHistFull = true;
     }

   int count = g_eqHistFull ? EQUITY_HISTORY_SIZE : g_eqHistIdx;
   g_eqHistMin = g_equityHist[0];
   g_eqHistMax = g_equityHist[0];
   for(int i = 1; i < count; i++)
     {
      if(g_equityHist[i] < g_eqHistMin) g_eqHistMin = g_equityHist[i];
      if(g_equityHist[i] > g_eqHistMax) g_eqHistMax = g_equityHist[i];
     }
  }

//+------------------------------------------------------------------+
//| Utility functions                                                  |
//+------------------------------------------------------------------+
int CountOpenPositions()
  {
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     { if(!g_pos.SelectByIndex(i)) continue;
       if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;
       count++; }
   return count;
  }

double GetTotalLots()
  {
   double lots = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     { if(!g_pos.SelectByIndex(i)) continue;
       if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;
       lots += g_pos.Volume(); }
   return lots;
  }

double GetFloatingPnL()
  {
   double pnl = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     { if(!g_pos.SelectByIndex(i)) continue;
       if(InpMagicFilter > 0 && g_pos.Magic() != InpMagicFilter) continue;
       pnl += g_pos.Profit() + g_pos.Swap() + g_pos.Commission(); }
   return pnl;
  }

datetime GetDayStart(datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   return StructToTime(dt);
  }

void AutoDetectFilling()
  {
   long fillMode = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((fillMode & SYMBOL_FILLING_FOK) != 0)
      g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if((fillMode & SYMBOL_FILLING_IOC) != 0)
      g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
  }

//+------------------------------------------------------------------+
//| Alerts                                                             |
//+------------------------------------------------------------------+
void FireAlert(const string message)
  {
   Print(message);
   if(InpAlertPopup)  Alert(message);
   if(InpAlertSound)  PlaySound(InpAlertSoundFile);
   if(InpAlertPush)   SendNotification(message);
   if(InpAlertEmail)  SendMail(EA_TAG + " v" + EA_VERSION, message);
  }

//+------------------------------------------------------------------+
//| Log event to CSV file                                              |
//+------------------------------------------------------------------+
void LogEvent(const string eventType, const string details)
  {
   if(g_logHandle == INVALID_HANDLE) return;

   double equity  = g_account.Equity();
   double balance = g_account.Balance();
   double ddPct   = (balance > 0) ? ((balance - equity) / balance) * 100.0 : 0;
   double dailyPnL = equity - g_dayStartEquity;

   FileWrite(g_logHandle,
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             eventType,
             DoubleToString(equity, 2),
             DoubleToString(balance, 2),
             DoubleToString(ddPct, 2),
             DoubleToString(dailyPnL, 2),
             IntegerToString(ComputeRiskScore(equity)),
             IntegerToString(CountOpenPositions()),
             details);
   FileFlush(g_logHandle);
  }

//+------------------------------------------------------------------+
//| Visual helpers                                                     |
//+------------------------------------------------------------------+
string BuildProgressBar(double pct, int width)
  {
   if(pct < 0) pct = 0;
   if(pct > 100) pct = 100;
   int filled = (int)MathRound(pct / 100.0 * width);
   string bar = "";
   for(int i = 0; i < width; i++)
      bar += (i < filled) ? CharToString(0xDB) : CharToString(0xB0);
   return bar;
  }

string BuildEquitySparkline(int width)
  {
   int count = g_eqHistFull ? EQUITY_HISTORY_SIZE : g_eqHistIdx;
   if(count < 2) return "----------------";

   string blocks[8];
   blocks[0] = "_"; blocks[1] = "."; blocks[2] = "-";  blocks[3] = "=";
   blocks[4] = "+"; blocks[5] = "#"; blocks[6] = "@";  blocks[7] = "M";

   double range = g_eqHistMax - g_eqHistMin;
   if(range <= 0) range = 1;

   string spark = "";
   for(int i = 0; i < width; i++)
     {
      int srcIdx;
      if(g_eqHistFull)
         srcIdx = (g_eqHistIdx + (int)MathRound((double)i / width * EQUITY_HISTORY_SIZE)) % EQUITY_HISTORY_SIZE;
      else
         srcIdx = (int)MathRound((double)i / width * (count - 1));

      double val = g_equityHist[srcIdx];
      int level = (int)MathRound((val - g_eqHistMin) / range * 7.0);
      level = MathMax(0, MathMin(7, level));
      spark += blocks[level];
     }
   return spark;
  }

color GetRatioColor(double ratio)
  {
   if(ratio >= 100) return InpDangerColor;
   if(ratio >= 80)  return InpDangerColor;
   if(ratio >= 50)  return InpWarningColor;
   return InpSafeColor;
  }

//+------------------------------------------------------------------+
//| Create the dashboard background                                    |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   string name = OBJ_PREFIX + "BG";
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpDashX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpDashY);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 310);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 460);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpBgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, InpBorderColor);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Update the full on-chart dashboard                                 |
//+------------------------------------------------------------------+
void UpdateDashboard(const double equity)
  {
   double balance    = g_account.Balance();
   double refVal     = (InpDDBase == DD_FROM_PEAK) ? g_peakEquity : balance;
   double drawdown   = refVal - equity;
   double ddPct      = (refVal > 0) ? (drawdown / refVal) * 100.0 : 0;
   double dailyPnL   = equity - g_dayStartEquity;
   double dailyPct   = (g_dayStartEquity > 0) ? (dailyPnL / g_dayStartEquity) * 100.0 : 0;
   int    positions   = CountOpenPositions();
   double totalLots   = GetTotalLots();
   double floatingPnL = GetFloatingPnL();
   int    riskScore   = ComputeRiskScore(equity);
   int    spread      = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   string cur         = AccountInfoString(ACCOUNT_CURRENCY);

   int x  = InpDashX + 10;
   int xv = InpDashX + 150;
   int y  = InpDashY + 8;
   int lh = (int)(InpFontSize * 1.7);

   //--- HEADER
   DL("Title", x, y, "ASQ RISKGUARD", InpAccentColor, InpFontSize + 2);
   DL("Ver",   InpDashX + 225, y + 2, "v" + EA_VERSION, InpDimColor, InpFontSize - 2);
   y += lh + 2;

   //--- RISK SCORE BAR
   color scoreClr = InpSafeColor;
   string scoreLabel = "LOW RISK";
   if(riskScore >= 80)      { scoreClr = InpDangerColor;  scoreLabel = "CRITICAL"; }
   else if(riskScore >= 50) { scoreClr = InpWarningColor; scoreLabel = "ELEVATED"; }
   else if(riskScore >= 25) { scoreClr = InpAccentColor;  scoreLabel = "MODERATE"; }

   DL("ScBar", x, y, BuildProgressBar(riskScore, 24), scoreClr, InpFontSize - 1);
   DL("ScVal", InpDashX + 220, y, StringFormat("%d %s", riskScore, scoreLabel), scoreClr, InpFontSize - 1);
   y += lh;
   DL("Sep0", x, y, "-----------------------------------", InpBorderColor, InpFontSize - 3);
   y += lh - 4;

   //--- ACCOUNT
   DL("BalL", x, y, "Balance", InpDimColor, InpFontSize - 1);
   DL("BalV", xv, y, StringFormat("%.2f %s", balance, cur), InpTextColor, InpFontSize);
   y += lh;

   DL("EqL", x, y, "Equity", InpDimColor, InpFontSize - 1);
   DL("EqV", xv, y, StringFormat("%.2f %s", equity, cur),
      (ddPct > 2) ? InpWarningColor : InpTextColor, InpFontSize);
   y += lh;

   if(InpDDBase == DD_FROM_PEAK)
     {
      DL("PkL", x, y, "Peak (HWM)", InpDimColor, InpFontSize - 1);
      DL("PkV", xv, y, StringFormat("%.2f", g_peakEquity), InpAccentColor, InpFontSize);
      y += lh;
     }

   //--- EQUITY SPARKLINE
   DL("Spark", x, y, BuildEquitySparkline(28),
      (dailyPnL >= 0) ? InpSafeColor : InpDangerColor, InpFontSize);
   y += lh;
   DL("Sep1", x, y, "-----------------------------------", InpBorderColor, InpFontSize - 3);
   y += lh - 4;

   //--- DRAWDOWN
   double ddLimit = (InpDDMode == DD_PERCENT) ? InpMaxDrawdownPct : InpMaxDrawdownMoney;
   double ddCurr  = (InpDDMode == DD_PERCENT) ? MathMax(ddPct,0) : MathMax(drawdown,0);
   double ddRatio = (ddLimit > 0) ? ddCurr / ddLimit * 100 : 0;

   DL("DDL", x, y, "Drawdown", InpDimColor, InpFontSize - 1);
   DL("DDV", xv, y, StringFormat("%.2f%% / %.1f%%", MathMax(ddPct,0), InpMaxDrawdownPct),
      GetRatioColor(ddRatio), InpFontSize);
   y += lh;
   DL("DDBar", x, y, BuildProgressBar(ddRatio, 24), GetRatioColor(ddRatio), InpFontSize - 1);
   DL("DDPct", InpDashX + 220, y, StringFormat("%.0f%%", MathMin(ddRatio,999)), GetRatioColor(ddRatio), InpFontSize - 1);
   y += lh;

   //--- DAILY P&L
   double dayLoss  = (dailyPnL < 0) ? MathAbs(dailyPnL) : 0;
   double dayLPct  = (g_dayStartEquity > 0) ? (dayLoss / g_dayStartEquity) * 100.0 : 0;
   double dayRatio = (InpDailyLimitPct > 0 && dailyPnL < 0) ? dayLPct / InpDailyLimitPct * 100 : 0;
   color  dailyClr = (dailyPnL >= 0) ? InpSafeColor : InpDangerColor;
   string dSign    = (dailyPnL >= 0) ? "+" : "";

   DL("DyL", x, y, "Daily P&L", InpDimColor, InpFontSize - 1);
   DL("DyV", xv, y, StringFormat("%s%.2f (%s%.2f%%)", dSign, dailyPnL, dSign, dailyPct),
      dailyClr, InpFontSize);
   y += lh;

   if(InpEnableDailyLimit && dailyPnL < 0)
     {
      DL("DyBar", x, y, BuildProgressBar(dayRatio, 24), GetRatioColor(dayRatio), InpFontSize - 1);
      DL("DyPct", InpDashX + 220, y, StringFormat("%.0f%%", MathMin(dayRatio,999)), GetRatioColor(dayRatio), InpFontSize - 1);
     }
   else
     {
      DL("DyBar", x, y, BuildProgressBar(0, 24), InpDimColor, InpFontSize - 1);
      DL("DyPct", InpDashX + 220, y, "0%", InpDimColor, InpFontSize - 1);
     }
   y += lh;
   DL("Sep2", x, y, "-----------------------------------", InpBorderColor, InpFontSize - 3);
   y += lh - 4;

   //--- EXPOSURE
   DL("PosL", x, y, "Positions", InpDimColor, InpFontSize - 1);
   DL("PosV", xv, y, StringFormat("%d / %s", positions,
      (InpMaxOpenPositions > 0) ? IntegerToString(InpMaxOpenPositions) : "--"),
      InpTextColor, InpFontSize);
   y += lh;

   DL("LotL", x, y, "Exposure", InpDimColor, InpFontSize - 1);
   DL("LotV", xv, y, StringFormat("%.2f lots", totalLots), InpTextColor, InpFontSize);
   y += lh;

   DL("FltL", x, y, "Float P&L", InpDimColor, InpFontSize - 1);
   DL("FltV", xv, y, StringFormat("%s%.2f %s", (floatingPnL >= 0) ? "+" : "", floatingPnL, cur),
      (floatingPnL >= 0) ? InpSafeColor : InpDangerColor, InpFontSize);
   y += lh;

   DL("OrdL", x, y, "Orders today", InpDimColor, InpFontSize - 1);
   DL("OrdV", xv, y, StringFormat("%d / %s", g_ordersToday,
      (InpMaxOrdersPerDay > 0) ? IntegerToString(InpMaxOrdersPerDay) : "--"),
      InpTextColor, InpFontSize);
   y += lh;
   DL("Sep3", x, y, "-----------------------------------", InpBorderColor, InpFontSize - 3);
   y += lh - 4;

   //--- GUARDS
   DL("SpL", x, y, "Spread", InpDimColor, InpFontSize - 1);
   color spClr = InpTextColor;
   if(InpEnableSpreadGuard)
     {
      if(spread > InpMaxSpreadPoints) spClr = InpDangerColor;
      else if(spread > (int)(InpMaxSpreadPoints * 0.8)) spClr = InpWarningColor;
     }
   DL("SpV", xv, y, StringFormat("%d pts%s", spread,
      InpEnableSpreadGuard ? " / " + IntegerToString(InpMaxSpreadPoints) : ""),
      spClr, InpFontSize);
   y += lh;

   DL("SsL", x, y, "Session", InpDimColor, InpFontSize - 1);
   if(InpEnableSessionFilter)
     {
      bool inS = IsInSession();
      DL("SsV", xv, y, (inS ? "ACTIVE " : "OUTSIDE ") + InpSessionStart + "-" + InpSessionEnd,
         inS ? InpSafeColor : InpWarningColor, InpFontSize);
     }
   else
      DL("SsV", xv, y, "OFF", InpDimColor, InpFontSize);
   y += lh;

   DL("RcL", x, y, "Rec. Lot", InpDimColor, InpFontSize - 1);
   double recLot = CalculateLotSize(_Symbol, InpDefaultSLPoints);
   DL("RcV", xv, y, StringFormat("%.2f  (%s)", recLot, _Symbol), InpAccentColor, InpFontSize);
   y += lh;
   DL("Sep4", x, y, "-----------------------------------", InpBorderColor, InpFontSize - 3);
   y += lh - 4;

   //--- STATUS
   string statusText = "";
   color  statusClr  = InpSafeColor;
   if(g_equityStopHit)      { statusText = "EQUITY STOP";  statusClr = InpDangerColor; }
   else if(g_dailyLimitHit) { statusText = "DAILY LIMIT";  statusClr = InpDangerColor; }
   else if(riskScore >= 80) { statusText = "HIGH RISK";    statusClr = InpDangerColor; }
   else if(riskScore >= 50) { statusText = "CAUTION";      statusClr = InpWarningColor; }
   else                     { statusText = "MONITORING";    statusClr = InpSafeColor; }

   DL("StL", x, y, "Status", InpDimColor, InpFontSize - 1);
   DL("StV", xv, y, statusText, statusClr, InpFontSize + 1);
   y += lh + 4;

   //--- FOOTER
   DL("Brand", x, y, "AlgoSphere Quant", InpDimColor, InpFontSize - 2);
   DL("Tag", InpDashX + 175, y, "Precision before profit", C'35,38,52', InpFontSize - 3);
   y += lh;

   //--- resize background to fit content
   ObjectSetInteger(0, OBJ_PREFIX + "BG", OBJPROP_YSIZE, y - InpDashY + 5);
  }

//+------------------------------------------------------------------+
//| Dashboard label helper (create or update)                          |
//+------------------------------------------------------------------+
void DL(const string id, const int x, const int y,
        const string text, const color clr, const int fontSize)
  {
   string name = OBJ_PREFIX + id;

   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
  }

//+------------------------------------------------------------------+
//| OnTradeTransaction — track new orders for daily count              |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL)
        {
         if(HistoryDealSelect(trans.deal))
           {
            ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
            if(entry == DEAL_ENTRY_IN)
               g_ordersToday++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
