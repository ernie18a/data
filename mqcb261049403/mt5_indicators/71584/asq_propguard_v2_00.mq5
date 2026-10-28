//+------------------------------------------------------------------+
//|                                          ASQ_PropGuard_v2.00.mq5 |
//|                                 Copyright 2026, AlgoSphere Quant |
//|                           https://www.mql5.com/en/users/robin2.0 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, AlgoSphere Quant"
#property link        "https://www.mql5.com/en/users/robin2.0"
#property version     "2.00"
#property description "Real-time prop firm rule monitor: daily loss, max drawdown,"
#property description "profit target, trading days, and session verdict with progress bars."
#property description "Presets for FTMO, MyFundedFX, TFT, E8, Bulenox, and custom rules."
#property description "AlgoSphere Quant — Precision-engineered trading tools."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Enumerations                                                       |
//+------------------------------------------------------------------+
enum ASQ_FIRM_PRESET
  {
   ASQ_FIRM_CUSTOM     = 0,   // Custom (manual rules)
   ASQ_FIRM_FTMO       = 1,   // FTMO
   ASQ_FIRM_MFF        = 2,   // MyFundedFX
   ASQ_FIRM_TFT        = 3,   // The Funded Trader
   ASQ_FIRM_E8         = 4,   // E8 Funding
   ASQ_FIRM_BULENOX    = 5    // Bulenox (Futures)
  };

enum ASQ_DD_METHOD
  {
   ASQ_DD_STATIC       = 0,   // From initial balance (static)
   ASQ_DD_TRAILING     = 1,   // From equity high-water mark (trailing)
   ASQ_DD_EOD          = 2    // From end-of-day balance
  };

//+------------------------------------------------------------------+
//| Inputs                                                             |
//+------------------------------------------------------------------+
input group                "═══ FIRM PRESET ═══"
input ASQ_FIRM_PRESET CfgPreset       = ASQ_FIRM_CUSTOM;  // Prop firm preset
input double    CfgAccountSize         = 100000.0;         // Account starting size

input group                "═══ RULES (Custom / Override) ═══"
input double    CfgDailyLossCap        = 5.0;    // Daily loss cap (%)
input double    CfgMaxDD               = 10.0;   // Max total drawdown (%)
input double    CfgTarget              = 10.0;   // Profit target (%)
input int       CfgMinDays             = 0;      // Min trading days (0=off)
input int       CfgMaxCalDays          = 0;      // Max calendar days (0=unlimited)
input ASQ_DD_METHOD CfgDDMethod        = ASQ_DD_STATIC; // DD calculation method

input group                "═══ DAY BOUNDARY ═══"
input int       CfgResetHour           = 0;      // Day reset hour (server time)
input int       CfgResetMin            = 0;      // Day reset minute

input group                "═══ APPEARANCE ═══"
input int       CfgPosX                = 15;     // Panel X
input int       CfgPosY                = 25;     // Panel Y
input int       CfgFont                = 10;     // Font size
input color     CfgClrBG               = C'18,18,28';    // Background
input color     CfgClrEdge             = C'30,35,50';    // Border
input color     CfgClrHead             = C'90,180,250';  // Section headers
input color     CfgClrBody             = C'165,170,185'; // Normal text
input color     CfgClrOK               = C'0,200,83';    // Safe / green
input color     CfgClrWarn             = C'255,215,0';   // Warning / yellow
input color     CfgClrBreach           = C'255,23,68';   // Danger / red
input color     CfgClrTarget           = C'0,230,118';   // Target hit

input group                "═══ ALERTS ═══"
input bool      CfgWarnAt80            = true;   // Alert at 80% of limits
input bool      CfgWarnOnBreach        = true;   // Alert when limit breached
input bool      CfgPush                = false;  // Push notification
input bool      CfgEmail               = false;  // Email alert

//+------------------------------------------------------------------+
//| Constants                                                          |
//+------------------------------------------------------------------+
const string PFX = "ASQPG_";
const string APP = "ASQ PropGuard";

//+------------------------------------------------------------------+
//| Rule Set                                                           |
//+------------------------------------------------------------------+
struct RuleSet
  {
   double         dailyCap;
   double         maxDD;
   double         target;
   int            minDays;
   int            maxCalDays;
   ASQ_DD_METHOD  ddMethod;
  };

//+------------------------------------------------------------------+
//| Runtime State                                                      |
//+------------------------------------------------------------------+
RuleSet        rules;
double         baseBalance       = 0;
double         dayOpenBal        = 0;
double         dayOpenEq         = 0;
double         hwm               = 0;     // equity high-water mark
double         eodBal            = 0;     // end-of-day balance
datetime       curDay            = 0;
int            tradeDayCount     = 0;
datetime       challengeStart    = 0;
bool           sentDaily80       = false;
bool           sentDailyBreach   = false;
bool           sentDD80          = false;
bool           sentDDBreach      = false;
int            panW              = 310;

//+------------------------------------------------------------------+
//| Initialization                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   ApplyPreset();

   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);

   baseBalance    = (CfgAccountSize > 0) ? CfgAccountSize : bal;
   dayOpenBal     = bal;
   dayOpenEq      = eq;
   hwm            = MathMax(bal, eq);
   eodBal         = bal;
   curDay         = DayFloor(TimeCurrent());
   challengeStart = curDay;
   tradeDayCount  = 0;

   if(TradedOnDate(curDay))
      tradeDayCount = 1;

   DrawPanel();

   IndicatorSetString(INDICATOR_SHORTNAME, APP);
   PrintFormat("[%s] Ready. Base balance: %.2f", APP, baseBalance);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PFX);
  }

//+------------------------------------------------------------------+
//| Tick Handler                                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   DetectNewDay();

   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);

   //--- update equity high-water mark
   if(eq > hwm) hwm = eq;

   //--- compute daily P&L
   double dayPnL    = eq - dayOpenBal;
   double dayPnLPct = (dayOpenBal > 0) ? (dayPnL / dayOpenBal) * 100.0 : 0;

   //--- compute total drawdown based on selected method
   double ddAmt = 0, ddPct = 0, ddRef = 0;
   switch(rules.ddMethod)
     {
      case ASQ_DD_STATIC:   ddRef = baseBalance; ddAmt = baseBalance - eq; break;
      case ASQ_DD_TRAILING: ddRef = hwm;         ddAmt = hwm - eq;        break;
      case ASQ_DD_EOD:      ddRef = eodBal;      ddAmt = eodBal - eq;     break;
     }
   if(ddAmt < 0) ddAmt = 0;
   ddPct = (ddRef > 0) ? (ddAmt / ddRef) * 100.0 : 0;

   //--- profit progress
   double totPnL    = eq - baseBalance;
   double totPnLPct = (baseBalance > 0) ? (totPnL / baseBalance) * 100.0 : 0;
   double tgtProg   = (rules.target > 0) ? (totPnLPct / rules.target) * 100.0 : 0;
   if(tgtProg < 0) tgtProg = 0;

   //--- calendar days
   int calDays      = (int)((TimeCurrent() - challengeStart) / 86400) + 1;
   int daysLeft     = (rules.maxCalDays > 0) ? rules.maxCalDays - calDays : -1;

   //--- alerts
   EvalAlerts(dayPnLPct, ddPct);

   //--- refresh display
   Refresh(bal, eq, dayPnL, dayPnLPct, ddAmt, ddPct, totPnL, totPnLPct, tgtProg, calDays, daysLeft);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Apply prop firm preset rules                                       |
//+------------------------------------------------------------------+
void ApplyPreset()
  {
   switch(CfgPreset)
     {
      case ASQ_FIRM_FTMO:
         rules.dailyCap   = 5.0;
         rules.maxDD      = 10.0;
         rules.target     = 10.0;
         rules.minDays    = 4;
         rules.maxCalDays = 30;
         rules.ddMethod   = ASQ_DD_STATIC;
         break;
      case ASQ_FIRM_MFF:
         rules.dailyCap   = 5.0;
         rules.maxDD      = 12.0;
         rules.target     = 8.0;
         rules.minDays    = 5;
         rules.maxCalDays = 30;
         rules.ddMethod   = ASQ_DD_STATIC;
         break;
      case ASQ_FIRM_TFT:
         rules.dailyCap   = 5.0;
         rules.maxDD      = 10.0;
         rules.target     = 10.0;
         rules.minDays    = 0;
         rules.maxCalDays = 35;
         rules.ddMethod   = ASQ_DD_STATIC;
         break;
      case ASQ_FIRM_E8:
         rules.dailyCap   = 5.0;
         rules.maxDD      = 8.0;
         rules.target     = 8.0;
         rules.minDays    = 0;
         rules.maxCalDays = 0;
         rules.ddMethod   = ASQ_DD_TRAILING;
         break;
      case ASQ_FIRM_BULENOX:
         rules.dailyCap   = 0;
         rules.maxDD      = 4.0;
         rules.target     = 6.0;
         rules.minDays    = 0;
         rules.maxCalDays = 0;
         rules.ddMethod   = ASQ_DD_TRAILING;
         break;
      default:
         rules.dailyCap   = CfgDailyLossCap;
         rules.maxDD      = CfgMaxDD;
         rules.target     = CfgTarget;
         rules.minDays    = CfgMinDays;
         rules.maxCalDays = CfgMaxCalDays;
         rules.ddMethod   = CfgDDMethod;
         break;
     }
  }

//+------------------------------------------------------------------+
//| Day boundary detection                                             |
//+------------------------------------------------------------------+
void DetectNewDay()
  {
   datetime now = TimeCurrent();
   datetime today = DayFloor(now);

   //--- build reset timestamp for today
   MqlDateTime rd;
   TimeToStruct(today, rd);
   rd.hour = CfgResetHour;
   rd.min  = CfgResetMin;
   rd.sec  = 0;
   datetime resetAt = StructToTime(rd);

   if(today != curDay && now >= resetAt)
     {
      //--- snapshot end-of-day balance before rollover
      eodBal = AccountInfoDouble(ACCOUNT_BALANCE);

      //--- roll forward
      curDay = today;
      double b = AccountInfoDouble(ACCOUNT_BALANCE);
      double e = AccountInfoDouble(ACCOUNT_EQUITY);
      dayOpenBal = b;
      dayOpenEq  = e;

      //--- reset daily alert flags
      sentDaily80    = false;
      sentDailyBreach = false;

      //--- count previous day as traded?
      if(TradedOnDate(today - 86400))
         tradeDayCount++;

      PrintFormat("[%s] New day. Balance: %.2f | Trade days: %d", APP, b, tradeDayCount);
     }
  }

//+------------------------------------------------------------------+
//| Check if any trades executed on a specific date                    |
//+------------------------------------------------------------------+
bool TradedOnDate(datetime dayStart)
  {
   datetime dayEnd = dayStart + 86400;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) == 0) continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t >= dayStart && t < dayEnd) return true;
     }

   if(HistorySelect(dayStart, dayEnd))
      if(HistoryDealsTotal() > 0) return true;

   return false;
  }

//+------------------------------------------------------------------+
//| Floor a timestamp to midnight                                      |
//+------------------------------------------------------------------+
datetime DayFloor(datetime t)
  {
   MqlDateTime d;
   TimeToStruct(t, d);
   d.hour = 0; d.min = 0; d.sec = 0;
   return StructToTime(d);
  }

//+------------------------------------------------------------------+
//| Evaluate alert conditions                                          |
//+------------------------------------------------------------------+
void EvalAlerts(const double dayPct, const double ddPct)
  {
   //--- daily 80% warning
   if(CfgWarnAt80 && rules.dailyCap > 0 && !sentDaily80)
      if(dayPct < 0 && MathAbs(dayPct) >= rules.dailyCap * 0.8)
        {
         Notify(StringFormat("[%s] WARNING: Daily loss %.2f%% approaching %.1f%% cap",
                             APP, MathAbs(dayPct), rules.dailyCap));
         sentDaily80 = true;
        }

   //--- daily breach
   if(CfgWarnOnBreach && rules.dailyCap > 0 && !sentDailyBreach)
      if(dayPct < 0 && MathAbs(dayPct) >= rules.dailyCap)
        {
         Notify(StringFormat("[%s] BREACH: Daily loss %.2f%% hit %.1f%% cap!",
                             APP, MathAbs(dayPct), rules.dailyCap));
         sentDailyBreach = true;
        }

   //--- max DD 80%
   if(CfgWarnAt80 && rules.maxDD > 0 && !sentDD80)
      if(ddPct >= rules.maxDD * 0.8)
        {
         Notify(StringFormat("[%s] WARNING: Drawdown %.2f%% nearing %.1f%% limit",
                             APP, ddPct, rules.maxDD));
         sentDD80 = true;
        }

   //--- max DD breach
   if(CfgWarnOnBreach && rules.maxDD > 0 && !sentDDBreach)
      if(ddPct >= rules.maxDD)
        {
         Notify(StringFormat("[%s] BREACH: Drawdown %.2f%% hit %.1f%% limit!",
                             APP, ddPct, rules.maxDD));
         sentDDBreach = true;
        }
  }

//+------------------------------------------------------------------+
//| Send alert via configured channels                                 |
//+------------------------------------------------------------------+
void Notify(const string msg)
  {
   Print(msg);
   Alert(msg);
   if(CfgPush)  SendNotification(msg);
   if(CfgEmail) SendMail(APP + " Alert", msg);
  }

//+------------------------------------------------------------------+
//|                    PANEL CONSTRUCTION                               |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   int x = CfgPosX, y = CfgPosY;
   int rh = (int)(CfgFont * 1.8);
   int bh = 8, sp = 4;

   //--- background
   R(PFX + "BG", x - 6, y - 6, panW + 12, 600, CfgClrBG, CfgClrEdge);

   //--- header
   L(PFX + "Title", x, y, "══ PROP GUARD ══", CfgClrHead, CfgFont + 2);
   y += rh + 2;

   string tag = FirmTag();
   L(PFX + "Tag", x, y, tag, C'100,105,120', CfgFont - 1);
   y += rh;
   L(PFX + "D0", x, y, Sep(), CfgClrEdge, CfgFont - 2);
   y += rh - 2;

   //--- account
   L(PFX + "HA", x, y, "ACCOUNT", CfgClrHead, CfgFont); y += rh;
   L(PFX + "Bal", x, y, "Balance: —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "Eq",  x, y, "Equity:  —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "Flt", x, y, "Floating: —", CfgClrBody, CfgFont); y += rh + sp;

   L(PFX + "D1", x, y, Sep(), CfgClrEdge, CfgFont - 2); y += rh - 2;

   //--- daily loss
   L(PFX + "HD", x, y, "DAILY LOSS", CfgClrHead, CfgFont); y += rh;
   L(PFX + "DPnL", x, y, "Today: —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "DBar", x, y, "", CfgClrBody, CfgFont); y += 2;
   R(PFX + "DBbg", x, y, panW - 10, bh, C'25,28,38', C'25,28,38');
   R(PFX + "DBfill", x, y, 1, bh, CfgClrOK, CfgClrOK);
   y += bh + 2;
   L(PFX + "DPct", x, y, "", C'80,85,100', CfgFont - 2); y += rh;
   L(PFX + "DRem", x, y, "Remaining: —", CfgClrBody, CfgFont); y += rh + sp;

   L(PFX + "D2", x, y, Sep(), CfgClrEdge, CfgFont - 2); y += rh - 2;

   //--- max drawdown
   L(PFX + "HDD", x, y, "MAX DRAWDOWN", CfgClrHead, CfgFont); y += rh;
   L(PFX + "DDVal", x, y, "Drawdown: —", CfgClrBody, CfgFont); y += rh;
   R(PFX + "DDbg", x, y, panW - 10, bh, C'25,28,38', C'25,28,38');
   R(PFX + "DDfill", x, y, 1, bh, CfgClrOK, CfgClrOK);
   y += bh + 2;
   L(PFX + "DDPct", x, y, "", C'80,85,100', CfgFont - 2); y += rh;
   L(PFX + "DDRem", x, y, "Remaining: —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "DDMeth", x, y, "", C'80,85,100', CfgFont - 2); y += rh + sp;

   L(PFX + "D3", x, y, Sep(), CfgClrEdge, CfgFont - 2); y += rh - 2;

   //--- profit target
   L(PFX + "HT", x, y, "PROFIT TARGET", CfgClrHead, CfgFont); y += rh;
   L(PFX + "TVl", x, y, "Progress: —", CfgClrBody, CfgFont); y += rh;
   R(PFX + "TBbg", x, y, panW - 10, bh, C'25,28,38', C'25,28,38');
   R(PFX + "TBfill", x, y, 1, bh, CfgClrHead, CfgClrHead);
   y += bh + 2;
   L(PFX + "TPct", x, y, "", C'80,85,100', CfgFont - 2); y += rh;
   L(PFX + "TNeed", x, y, "Need: —", CfgClrBody, CfgFont); y += rh + sp;

   L(PFX + "D4", x, y, Sep(), CfgClrEdge, CfgFont - 2); y += rh - 2;

   //--- challenge status
   L(PFX + "HS", x, y, "CHALLENGE STATUS", CfgClrHead, CfgFont); y += rh;
   L(PFX + "TDays", x, y, "Trade days: —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "CDays", x, y, "Calendar: —", CfgClrBody, CfgFont); y += rh;
   L(PFX + "Verd", x, y, "Verdict: —", CfgClrOK, CfgFont); y += rh + sp;

   //--- branding
   L(PFX + "Brand", x, y, "AlgoSphere Quant", C'50,55,70', CfgFont - 2); y += rh;

   ObjectSetInteger(0, PFX + "BG", OBJPROP_YSIZE, y - CfgPosY + 10);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Refresh all dashboard values                                       |
//+------------------------------------------------------------------+
void Refresh(const double bal, const double eq,
             const double dayPnL, const double dayPnLPct,
             const double ddAmt, const double ddPct,
             const double totPnL, const double totPnLPct,
             const double tgtProg,
             const int calDays, const int daysLeft)
  {
   int bMax = panW - 10;
   double flt = eq - bal;

   //--- account
   U(PFX + "Bal", StringFormat("Balance:  %.2f", bal), CfgClrBody);
   U(PFX + "Eq",  StringFormat("Equity:   %.2f", eq),
     (eq < bal) ? CfgClrWarn : CfgClrBody);
   U(PFX + "Flt", StringFormat("Floating: %s%.2f", (flt >= 0) ? "+" : "", flt),
     (flt >= 0) ? CfgClrOK : CfgClrBreach);

   //--- daily loss
   double dLoss    = (dayPnL < 0) ? MathAbs(dayPnL) : 0;
   double dLossPct = (dayPnLPct < 0) ? MathAbs(dayPnLPct) : 0;
   double dUsed    = (rules.dailyCap > 0) ? MathMin(100, (dLossPct / rules.dailyCap) * 100.0) : 0;

   color dC = StatusClr(dUsed);
   U(PFX + "DPnL",
     StringFormat("Today: %s%.2f (%s%.2f%%)",
                  (dayPnL >= 0) ? "+" : "", dayPnL,
                  (dayPnLPct >= 0) ? "+" : "", dayPnLPct), dC);

   int dW = (int)MathMax(1, MathMin(bMax, bMax * dUsed / 100.0));
   ObjectSetInteger(0, PFX + "DBfill", OBJPROP_XSIZE, dW);
   ObjectSetInteger(0, PFX + "DBfill", OBJPROP_BGCOLOR, dC);
   ObjectSetInteger(0, PFX + "DBfill", OBJPROP_BORDER_COLOR, dC);

   if(rules.dailyCap > 0)
     {
      U(PFX + "DPct", StringFormat("%.0f%% of %.1f%% cap consumed", dUsed, rules.dailyCap), C'80,85,100');
      double dRemM = (rules.dailyCap / 100.0 * dayOpenBal) - dLoss;
      if(dRemM < 0) dRemM = 0;
      double dRemP = rules.dailyCap - dLossPct;
      if(dRemP < 0) dRemP = 0;
      U(PFX + "DRem", StringFormat("Remaining: $%.2f (%.2f%%)", dRemM, dRemP),
        (dRemP < 1.0) ? CfgClrBreach : CfgClrBody);
     }
   else
     {
      U(PFX + "DPct", "No daily cap", C'80,85,100');
      U(PFX + "DRem", "", CfgClrBody);
     }

   //--- max drawdown
   double ddUsed = (rules.maxDD > 0) ? MathMin(100, (ddPct / rules.maxDD) * 100.0) : 0;
   color ddC = StatusClr(ddUsed);
   U(PFX + "DDVal", StringFormat("Drawdown: %.2f%% ($%.2f)", ddPct, ddAmt), ddC);

   int ddW = (int)MathMax(1, MathMin(bMax, bMax * ddUsed / 100.0));
   ObjectSetInteger(0, PFX + "DDfill", OBJPROP_XSIZE, ddW);
   ObjectSetInteger(0, PFX + "DDfill", OBJPROP_BGCOLOR, ddC);
   ObjectSetInteger(0, PFX + "DDfill", OBJPROP_BORDER_COLOR, ddC);

   if(rules.maxDD > 0)
     {
      U(PFX + "DDPct", StringFormat("%.0f%% of %.1f%% limit consumed", ddUsed, rules.maxDD), C'80,85,100');
      double ddRem = rules.maxDD - ddPct;
      if(ddRem < 0) ddRem = 0;
      U(PFX + "DDRem", StringFormat("Remaining: $%.2f (%.2f%%)", ddRem / 100.0 * baseBalance, ddRem),
        (ddRem < 2.0) ? CfgClrBreach : CfgClrBody);
     }
   else
     {
      U(PFX + "DDPct", "No DD limit", C'80,85,100');
      U(PFX + "DDRem", "", CfgClrBody);
     }

   string mStr = "";
   switch(rules.ddMethod)
     {
      case ASQ_DD_STATIC:   mStr = "Basis: initial balance (static)";     break;
      case ASQ_DD_TRAILING: mStr = "Basis: equity high-water mark (trail)"; break;
      case ASQ_DD_EOD:      mStr = "Basis: end-of-day balance";            break;
     }
   U(PFX + "DDMeth", mStr, C'80,85,100');

   //--- profit target
   double capped = MathMax(0, MathMin(tgtProg, 100.0));
   color tC = CfgClrHead;
   if(tgtProg >= 100)     tC = CfgClrTarget;
   else if(tgtProg >= 70) tC = CfgClrOK;

   U(PFX + "TVl",
     StringFormat("Progress: %s%.2f%% of %.1f%%",
                  (totPnLPct >= 0) ? "+" : "", totPnLPct, rules.target), tC);

   int tW = (int)MathMax(1, MathMin(bMax, bMax * capped / 100.0));
   color tbC = (tgtProg >= 100) ? CfgClrTarget : CfgClrHead;
   ObjectSetInteger(0, PFX + "TBfill", OBJPROP_XSIZE, tW);
   ObjectSetInteger(0, PFX + "TBfill", OBJPROP_BGCOLOR, tbC);
   ObjectSetInteger(0, PFX + "TBfill", OBJPROP_BORDER_COLOR, tbC);

   if(rules.target > 0)
     {
      U(PFX + "TPct", StringFormat("%.0f%% complete", capped), C'80,85,100');
      double needM = (rules.target / 100.0 * baseBalance) - totPnL;
      if(needM < 0) needM = 0;
      double needP = rules.target - totPnLPct;
      if(needP < 0) needP = 0;

      if(tgtProg >= 100)
         U(PFX + "TNeed", "TARGET REACHED!", CfgClrTarget);
      else
         U(PFX + "TNeed", StringFormat("Need: $%.2f (%.2f%%)", needM, needP), CfgClrBody);
     }
   else
     {
      U(PFX + "TPct", "No profit target set", C'80,85,100');
      U(PFX + "TNeed",
        StringFormat("P&L: %s$%.2f", (totPnL >= 0) ? "+" : "", totPnL),
        (totPnL >= 0) ? CfgClrOK : CfgClrBreach);
     }

   //--- challenge status
   int td = tradeDayCount;
   if(TradedOnDate(curDay)) td = tradeDayCount + 1;

   string tdX = "";
   if(rules.minDays > 0)
     {
      int need = rules.minDays - td;
      tdX = (need > 0) ? StringFormat(" (need %d more)", need) : " ✓";
     }
   U(PFX + "TDays", StringFormat("Trade days: %d%s", td, tdX), CfgClrBody);

   string cdX = "";
   if(daysLeft >= 0) cdX = StringFormat(" (%d left)", MathMax(0, daysLeft));
   U(PFX + "CDays", StringFormat("Calendar: %d%s", calDays, cdX),
     (daysLeft >= 0 && daysLeft <= 3) ? CfgClrWarn : CfgClrBody);

   //--- verdict
   double dLPct = (dayPnLPct < 0) ? MathAbs(dayPnLPct) : 0;
   bool dBreach   = (rules.dailyCap > 0 && dLPct >= rules.dailyCap);
   bool ddBreach  = (rules.maxDD > 0 && ddPct >= rules.maxDD);
   bool expired   = (daysLeft == 0);
   bool hit       = (tgtProg >= 100);
   bool daysOK    = (rules.minDays <= 0 || td >= rules.minDays);

   string v = ""; color vC = CfgClrOK;

   if(dBreach || ddBreach)
     { v = "FAILED — LIMIT BREACHED"; vC = CfgClrBreach; }
   else if(expired && !hit)
     { v = "FAILED — TIME EXPIRED"; vC = CfgClrBreach; }
   else if(hit && daysOK)
     { v = "PASSED!"; vC = CfgClrTarget; }
   else if(hit && !daysOK)
     { v = "TARGET HIT — Need more days"; vC = CfgClrWarn; }
   else if(ddUsed >= 80 || dUsed >= 80)
     { v = "AT RISK — Near limits"; vC = CfgClrWarn; }
   else
     { v = "ON TRACK"; vC = CfgClrOK; }

   U(PFX + "Verd", StringFormat("Verdict: %s", v), vC);
  }

//+------------------------------------------------------------------+
//| Helpers                                                            |
//+------------------------------------------------------------------+
color StatusClr(const double pct)
  {
   if(pct >= 80)  return CfgClrBreach;
   if(pct >= 50)  return CfgClrWarn;
   return CfgClrOK;
  }

string FirmTag()
  {
   string sz = StringFormat("$%.0fK", CfgAccountSize / 1000);
   switch(CfgPreset)
     {
      case ASQ_FIRM_FTMO:    return "FTMO | " + sz;
      case ASQ_FIRM_MFF:     return "MyFundedFX | " + sz;
      case ASQ_FIRM_TFT:     return "The Funded Trader | " + sz;
      case ASQ_FIRM_E8:      return "E8 Funding | " + sz;
      case ASQ_FIRM_BULENOX: return "Bulenox | " + sz;
      default:               return "Custom Rules | " + sz;
     }
  }

string Sep() { return "────────────────────────────────"; }

//+------------------------------------------------------------------+
//|                    UI PRIMITIVES                                    |
//+------------------------------------------------------------------+
void L(const string n, int x, int y, const string t, color c, int s)
  {
   ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetString(0,  n, OBJPROP_TEXT, t);
   ObjectSetString(0,  n, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, s);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

void R(const string n, int x, int y, int w, int h, color bg, color bd)
  {
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, bd);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

void U(const string n, const string t, color c)
  {
   ObjectSetString(0, n, OBJPROP_TEXT, t);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
  }
//+------------------------------------------------------------------+
