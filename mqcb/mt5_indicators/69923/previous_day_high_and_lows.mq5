//+------------------------------------------------------------------+
//|                                               PrevDayHighLow.mq5 |
//|                                        Copyright 2026, Velocity  |
//|                             https://www.mql5.com/en/users/sanad  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Velocity"
#property link      "https://www.mql5.com/en/users/sanad"
#property version   "1.00"
#property description "Draws the previous day High, Low, and Close as horizontal"
#property description "lines on the chart for a configurable number of past days."
#property description "Yesterday's lines extend to the right as live reference"
#property description "levels, with optional touch alerts."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== DISPLAY ==="
input int    DaysBack    = 5;     // Number of past days to draw (1-50)
input bool   ShowClose   = true;  // Show previous day close line
input bool   ShowLabels  = true;  // Show H / L / C labels on lines
input int    LineWidth   = 1;     // Line width (1-5)

input group "=== COLORS ==="
input color  High_Color  = clrRed;       // Previous day high line color
input color  Low_Color   = clrRoyalBlue; // Previous day low line color
input color  Close_Color = clrDarkGray;  // Previous day close line color

input group "=== ALERTS ==="
input bool   UseAlerts = false; // Alert when price touches a previous day level
input bool   UsePopup  = true;  // Show popup alert
input bool   UsePush   = false; // Send push notification

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string ExpName        = "PrevDayHL"; // Prefix for all chart objects
int    DaysCalculated = -1;          // Last calculated day index
bool   Alert_HighFired  = false;     // High touch alert fired today
bool   Alert_LowFired   = false;     // Low touch alert fired today
bool   Alert_CloseFired = false;     // Close touch alert fired today
int    LastAlertDay = -1;            // Day when alerts were last reset

//+------------------------------------------------------------------+
//| Indicator initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate inputs
   if(DaysBack < 1 || DaysBack > 50)
     {
      Alert("PrevDayHighLow: DaysBack must be between 1 and 50.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(LineWidth < 1 || LineWidth > 5)
     {
      Alert("PrevDayHighLow: LineWidth must be between 1 and 5.");
      return INIT_PARAMETERS_INCORRECT;
     }
//---
   EventSetTimer(1);
   DaysCalculated = -1;
   DrawAllLevels();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteAllObjects();
  }

//+------------------------------------------------------------------+
//| Indicator calculation (light — redraw flag only)                 |
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
//--- force redraw on new bar
   if(prev_calculated != rates_total)
      DaysCalculated = -1;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Timer — main drawing logic                                       |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- reset alert flags on new day
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int today_yday = dt.day_of_year;
   if(today_yday != LastAlertDay)
     {
      Alert_HighFired  = false;
      Alert_LowFired   = false;
      Alert_CloseFired = false;
      LastAlertDay     = today_yday;
     }
//---
   DrawAllLevels();
   if(UseAlerts)
      CheckAlerts();
  }

//+------------------------------------------------------------------+
//| Chart event — redraw on zoom/scroll                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      DaysCalculated = -1;
      DrawAllLevels();
     }
  }

//+------------------------------------------------------------------+
//| Draw levels for all configured past days                         |
//+------------------------------------------------------------------+
void DrawAllLevels()
  {
//--- skip if already calculated today
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int cur_day = dt.day_of_year;
   if(cur_day == DaysCalculated)
      return;
//---
   for(int d = 1; d <= DaysBack; d++)
      DrawDayLevels(d);
//---
   DaysCalculated = cur_day;
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw High, Low, Close lines for one past day                     |
//+------------------------------------------------------------------+
void DrawDayLevels(const int day_idx)
  {
//--- get OHLC for this past day
   double hi  = iHigh(_Symbol, PERIOD_D1, day_idx);
   double lo  = iLow(_Symbol, PERIOD_D1, day_idx);
   double cl  = iClose(_Symbol, PERIOD_D1, day_idx);
//--- day spans from its own open to the next day's open
   datetime t_open      = iTime(_Symbol, PERIOD_D1, day_idx);
   datetime t_next_open = iTime(_Symbol, PERIOD_D1, day_idx - 1);
   if(hi == 0 || lo == 0 || t_open == 0 || t_next_open == 0)
      return;
//--- yesterday's lines are solid and extend right, older days are dotted and contained
   bool            is_yesterday = (day_idx == 1);
   ENUM_LINE_STYLE sty          = is_yesterday ? STYLE_SOLID : STYLE_DOT;
   bool            ray          = is_yesterday;
//--- object names
   string hn = ExpName + "_H_" + IntegerToString(day_idx);
   string ln = ExpName + "_L_" + IntegerToString(day_idx);
   string cn = ExpName + "_C_" + IntegerToString(day_idx);
//--- draw the three lines
   CreateLine(hn, t_open, t_next_open, hi, High_Color,  sty,       LineWidth, ray);
   CreateLine(ln, t_open, t_next_open, lo, Low_Color,   sty,       LineWidth, ray);
   if(ShowClose)
      CreateLine(cn, t_open, t_next_open, cl, Close_Color, STYLE_DOT, LineWidth, ray);
   else
      ObjectDelete(0, cn);
//--- labels
   if(ShowLabels)
     {
      string pfx = is_yesterday ? "PDH" : IntegerToString(day_idx) + "d PDH";
      string plx = is_yesterday ? "PDL" : IntegerToString(day_idx) + "d PDL";
      string pcx = is_yesterday ? "PDC" : IntegerToString(day_idx) + "d PDC";
      CreateLabel(ExpName + "_HL_" + IntegerToString(day_idx), t_next_open, hi, pfx, High_Color);
      CreateLabel(ExpName + "_LL_" + IntegerToString(day_idx), t_next_open, lo, plx, Low_Color);
      if(ShowClose)
         CreateLabel(ExpName + "_CL_" + IntegerToString(day_idx), t_next_open, cl, pcx, Close_Color);
      else
         ObjectDelete(0, ExpName + "_CL_" + IntegerToString(day_idx));
     }
   else
     {
      ObjectDelete(0, ExpName + "_HL_" + IntegerToString(day_idx));
      ObjectDelete(0, ExpName + "_LL_" + IntegerToString(day_idx));
      ObjectDelete(0, ExpName + "_CL_" + IntegerToString(day_idx));
     }
  }

//+------------------------------------------------------------------+
//| Alert when price touches yesterday's key levels                  |
//+------------------------------------------------------------------+
void CheckAlerts()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double hi  = iHigh(_Symbol, PERIOD_D1, 1);
   double lo  = iLow(_Symbol, PERIOD_D1, 1);
   double cl  = iClose(_Symbol, PERIOD_D1, 1);
   double tol = _Point * 5;
//--- high
   if(!Alert_HighFired && MathAbs(bid - hi) <= tol)
     {
      string msg = _Symbol + " price touched Previous Day High: " + DoubleToString(hi, _Digits);
      if(UsePopup)
         Alert(msg);
      if(UsePush)
         SendNotification(msg);
      Alert_HighFired = true;
     }
//--- low
   if(!Alert_LowFired && MathAbs(bid - lo) <= tol)
     {
      string msg = _Symbol + " price touched Previous Day Low: " + DoubleToString(lo, _Digits);
      if(UsePopup)
         Alert(msg);
      if(UsePush)
         SendNotification(msg);
      Alert_LowFired = true;
     }
//--- close
   if(ShowClose && !Alert_CloseFired && MathAbs(bid - cl) <= tol)
     {
      string msg = _Symbol + " price touched Previous Day Close: " + DoubleToString(cl, _Digits);
      if(UsePopup)
         Alert(msg);
      if(UsePush)
         SendNotification(msg);
      Alert_CloseFired = true;
     }
  }

//+------------------------------------------------------------------+
//| Delete all indicator chart objects                               |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   ObjectsDeleteAll(0, ExpName);
  }

//+------------------------------------------------------------------+
//| Create or update a horizontal line using OBJ_TREND               |
//+------------------------------------------------------------------+
void CreateLine(const string name, const datetime t1, const datetime t2,
                const double price, const color clr,
                const ENUM_LINE_STYLE style, const int width,
                const bool ray_right)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   else
     {
      ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
      ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
     }
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,     style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,     width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray_right);
   ObjectSetInteger(0, name, OBJPROP_BACK,      true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
  }

//+------------------------------------------------------------------+
//| Create or update a price label on the chart                      |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const datetime t, const double price,
                 const string text, const color clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   else
     {
      ObjectSetInteger(0, name, OBJPROP_TIME,  0, t);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
     }
   ObjectSetString(0, name, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  8);
   ObjectSetString(0, name, OBJPROP_FONT,      "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,    ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_BACK,      false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
  }
//+------------------------------------------------------------------+
