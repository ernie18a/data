//+------------------------------------------------------------------+
//|                                        PropFirmRiskDashboard.mq5 |
//|                            Dror M. - MQL5/MT5 EA & indicator dev |
//+------------------------------------------------------------------+
#property copyright "Dror M."
#property version   "1.00"
#property description "Prop-Firm Risk Dashboard - a read-only on-chart panel showing balance,"
#property description "equity, today's P/L, and how close the account is to a configurable daily-loss"
#property description "limit and a max-drawdown limit, color-coded OK / WARNING / DANGER."
#property description "Monitoring tool only - it does NOT place, modify or close any trades."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input double           InpStartBalance = 0.0;                // Starting balance (0 = use current balance)
input double           InpDailyLossPct = 5.0;                // Daily loss limit, % of day-start equity
input double           InpMaxDDPct     = 10.0;               // Max drawdown limit, % of starting balance
input int              InpWarnPct      = 60;                 // Warning at this % of a limit used
input int              InpDangerPct    = 85;                 // Danger at this % of a limit used
input ENUM_BASE_CORNER InpCorner       = CORNER_LEFT_UPPER;  // Panel corner
input int              InpX            = 14;                 // Horizontal offset (px)
input int              InpY            = 26;                 // Vertical offset (px)
input int              InpFontSize     = 9;                  // Font size
input string           InpFont         = "Consolas";        // Font name
input color            InpLabelColor   = clrGainsboro;       // Label text color
input color            InpOkColor      = clrLimeGreen;       // OK color
input color            InpWarnColor    = clrOrange;          // Warning color
input color            InpDangerColor  = clrRed;             // Danger color
input bool             InpShowPanelBg  = true;               // Show panel background
input color            InpPanelBgColor = C'28,32,48';        // Panel background color
input color            InpPanelBorder  = clrSlateGray;       // Panel border color
input int              InpPanelWidth   = 340;                // Panel width (px)

//--- constants / globals
#define PFX "PFRD_"                              // chart-object name prefix
const string GV_DAYEQ   = "PFRD_DayStartEquity"; // terminal global: equity at start of day
const string GV_DAYSTMP = "PFRD_DayStamp";       // terminal global: day number anchor
const int    ROWS       = 8;
double       g_startBalance = 0.0;
int          g_rowH         = 0;

//+------------------------------------------------------------------+
//| Day number (days since epoch) used to detect a new trading day   |
//+------------------------------------------------------------------+
int DayStamp()
  {
   return((int)(TimeCurrent() / 86400));
  }

//+------------------------------------------------------------------+
//| Equity captured at the start of the current day (persisted)      |
//+------------------------------------------------------------------+
double DayStartEquity()
  {
   int today = DayStamp();
   if(!GlobalVariableCheck(GV_DAYSTMP) || (int)GlobalVariableGet(GV_DAYSTMP) != today || !GlobalVariableCheck(GV_DAYEQ))
     {
      GlobalVariableSet(GV_DAYEQ, AccountInfoDouble(ACCOUNT_EQUITY));
      GlobalVariableSet(GV_DAYSTMP, today);
     }
   return(GlobalVariableGet(GV_DAYEQ));
  }

//+------------------------------------------------------------------+
//| Create the panel labels once                                     |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   if(InpShowPanelBg)
     {
      string bg = PFX + "bg";
      if(ObjectFind(0, bg) < 0)
         ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, InpX - 6);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, InpY - 6);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, InpPanelWidth);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, ROWS * g_rowH + 14);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, InpPanelBgColor);
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, InpPanelBorder);
      ObjectSetInteger(0, bg, OBJPROP_BACK, false);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);
     }
   for(int i = 0; i < ROWS; i++)
     {
      string name = PFX + "row" + (string)i;
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpY + i * g_rowH);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, name, OBJPROP_FONT, InpFont);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpLabelColor);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
     }
  }

//+------------------------------------------------------------------+
//| Update one panel row                                             |
//+------------------------------------------------------------------+
void SetRow(int i, string text, color clr)
  {
   string name = PFX + "row" + (string)i;
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Pick a color from how much of a limit has been used              |
//+------------------------------------------------------------------+
color StatusColor(double usedPct)
  {
   if(usedPct >= InpDangerPct) return(InpDangerColor);
   if(usedPct >= InpWarnPct)   return(InpWarnColor);
   return(InpOkColor);
  }

//+------------------------------------------------------------------+
string Money(double v) { return(DoubleToString(v, 2)); }

//+------------------------------------------------------------------+
//| Recompute metrics and refresh the panel                          |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   double bal  = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double prof = AccountInfoDouble(ACCOUNT_PROFIT);        // floating P/L of open positions
   double mlvl = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);  // 0 when flat
   string ccy  = AccountInfoString(ACCOUNT_CURRENCY);

   double dayEq = DayStartEquity();
   double dayPL = eq - dayEq;

   // daily loss used (only a loss counts toward the limit)
   double dailyLimitMoney = dayEq * InpDailyLossPct / 100.0;
   double dailyLossMoney  = (dayPL < 0.0) ? -dayPL : 0.0;
   double dailyUsedPct    = (dailyLimitMoney > 0.0) ? (dailyLossMoney / dailyLimitMoney * 100.0) : 0.0;

   // max drawdown from the starting balance
   double ddLimitMoney = g_startBalance * InpMaxDDPct / 100.0;
   double ddMoney      = (g_startBalance - eq > 0.0) ? (g_startBalance - eq) : 0.0;
   double ddUsedPct    = (ddLimitMoney > 0.0) ? (ddMoney / ddLimitMoney * 100.0) : 0.0;

   color dayClr = StatusColor(dailyUsedPct);
   color ddClr  = StatusColor(ddUsedPct);

   SetRow(0, "PROP-FIRM RISK DASHBOARD", InpLabelColor);
   SetRow(1, "Balance / Equity : " + Money(bal) + " / " + Money(eq) + " " + ccy, InpLabelColor);
   SetRow(2, "Floating P/L     : " + Money(prof) + " " + ccy, (prof >= 0.0 ? InpOkColor : InpDangerColor));
   SetRow(3, "Today's P/L      : " + Money(dayPL) + " " + ccy, (dayPL >= 0.0 ? InpOkColor : InpDangerColor));
   SetRow(4, "Daily loss used  : " + DoubleToString(dailyUsedPct, 0) + "%  (limit " + Money(dailyLimitMoney) + ")", dayClr);
   SetRow(5, "Max DD used      : " + DoubleToString(ddUsedPct, 0) + "%  (limit " + Money(ddLimitMoney) + ")", ddClr);
   SetRow(6, "Margin level     : " + (mlvl > 0.0 ? DoubleToString(mlvl, 0) + "%" : "n/a"), InpLabelColor);
   SetRow(7, "Start " + Money(g_startBalance) + " | DLL " + DoubleToString(InpDailyLossPct, 1) + "% | MDD " + DoubleToString(InpMaxDDPct, 1) + "%", InpLabelColor);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_startBalance = (InpStartBalance > 0.0) ? InpStartBalance : AccountInfoDouble(ACCOUNT_BALANCE);
   g_rowH = InpFontSize + 8;
   DayStartEquity();   // anchor the day-start equity
   BuildPanel();
   EventSetTimer(1);
   UpdatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
  {
   UpdatePanel();
   return(rates_total);
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdatePanel();
  }
//+------------------------------------------------------------------+
