//+------------------------------------------------------------------+
//|                                             SessionRangeBoxes.mq5|
//|                                        Copyright 2026, Velocity  |
//|                             https://www.mql5.com/en/users/sanad  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Velocity"
#property link      "https://www.mql5.com/en/users/sanad"
#property version   "1.00"
#property description "Draws colored high/low range boxes for the 3 main Forex sessions"
#property description "(Asian, London, New York) for a configurable number of past days."
#property description "Includes an average range stats panel and breakout alerts."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== SESSIONS ==="
input string Asian_Start   = "00:00";  // Asian session start (server time HH:MM)
input string Asian_End     = "08:00";  // Asian session end
input string London_Start  = "08:00";  // London session start
input string London_End    = "16:00";  // London session end
input string NewYork_Start = "13:00";  // New York session start
input string NewYork_End   = "21:00";  // New York session end

input group "=== DISPLAY ==="
input int    DaysBack       = 5;       // How many past days to draw boxes
input int    BoxAlpha       = 30;      // Box fill transparency (0-255)
input bool   ShowMidline    = true;    // Draw midpoint line inside each box
input bool   ShowLabels     = true;    // Show session name and range size label
input bool   ShowStatsPanel = true;    // Show average range stats panel

input group "=== COLORS ==="
input color  Asian_Color   = clrGold;           // Asian box color
input color  London_Color  = clrDodgerBlue;     // London box color
input color  NewYork_Color = clrMediumSeaGreen; // New York box color

input group "=== ALERTS ==="
input bool   UseAlerts = false; // Enable breakout alerts
input bool   UsePopup  = true;  // Show popup alert
input bool   UsePush   = false; // Send push notification

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string ExpName        = "SessRangeBoxes"; // Prefix for all chart objects
int    DaysCalculated = -1;               // Last day index drawn (avoid redraw every tick)
bool   Alert_AsianFired   = false;        // Today's breakout alert state
bool   Alert_LondonFired  = false;
bool   Alert_NewYorkFired = false;
int    LastAlertDay = -1;                 // Day of year when alerts were last reset

//+------------------------------------------------------------------+
//| Indicator initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate DaysBack
   if(DaysBack < 1 || DaysBack > 100)
     {
      Alert("SessionRangeBoxes: DaysBack must be between 1 and 100.");
      return INIT_PARAMETERS_INCORRECT;
     }
//--- validate BoxAlpha
   if(BoxAlpha < 0 || BoxAlpha > 255)
     {
      Alert("SessionRangeBoxes: BoxAlpha must be between 0 and 255.");
      return INIT_PARAMETERS_INCORRECT;
     }
//--- validate session time strings
   int h, m;
   if(!ParseTime(Asian_Start, h, m) || !ParseTime(Asian_End, h, m) ||
      !ParseTime(London_Start, h, m) || !ParseTime(London_End, h, m) ||
      !ParseTime(NewYork_Start, h, m) || !ParseTime(NewYork_End, h, m))
     {
      Alert("SessionRangeBoxes: Invalid session time format. Use HH:MM.");
      return INIT_PARAMETERS_INCORRECT;
     }
//---
   EventSetTimer(1);
   DaysCalculated = -1;
   DrawAllSessions();
   if(ShowStatsPanel)
      DrawStatsPanel();
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
// Force redraw when a new bar forms
   if(prev_calculated != rates_total)
      DaysCalculated = -1;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Timer — main drawing logic                                       |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- reset daily alert flags if new day
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int today_yday = dt.day_of_year;
   if(today_yday != LastAlertDay)
     {
      Alert_AsianFired   = false;
      Alert_LondonFired  = false;
      Alert_NewYorkFired = false;
      LastAlertDay       = today_yday;
     }
//---
   DrawAllSessions();
   if(UseAlerts)
      CheckBreakouts();
   if(ShowStatsPanel)
      DrawStatsPanel();
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
      DrawAllSessions();
      if(ShowStatsPanel)
         DrawStatsPanel();
     }
  }

//+------------------------------------------------------------------+
//| Draw boxes for all sessions over DaysBack days                   |
//+------------------------------------------------------------------+
void DrawAllSessions()
  {
//--- get current day index to skip unnecessary redraws
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int cur_day = dt.day_of_year;
   if(cur_day == DaysCalculated)
      return;
//---
   for(int d = 0; d < DaysBack; d++)
     {
      // Get midnight (server time) of the target day
      datetime day_start = iTime(_Symbol, PERIOD_D1, d);
      if(day_start == 0)
         continue;
      //---
      datetime t1, t2;
      // Asian
      if(GetSessionBounds(day_start, Asian_Start, Asian_End, t1, t2))
         DrawSessionBox("Asian", d, t1, t2, Asian_Color, "Asian");
      // London
      if(GetSessionBounds(day_start, London_Start, London_End, t1, t2))
         DrawSessionBox("London", d, t1, t2, London_Color, "London");
      // New York
      if(GetSessionBounds(day_start, NewYork_Start, NewYork_End, t1, t2))
         DrawSessionBox("NY", d, t1, t2, NewYork_Color, "NY");
     }
//---
   DaysCalculated = cur_day;
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw a single session box with midline and label                 |
//+------------------------------------------------------------------+
void DrawSessionBox(const string sess, const int day_idx,
                    const datetime t1, const datetime t2,
                    const color clr, const string label)
  {
//--- find H/L in range
   double hi = -DBL_MAX, lo = DBL_MAX;
   int bar1 = iBarShift(_Symbol, PERIOD_M1, t1, false);
   int bar2 = iBarShift(_Symbol, PERIOD_M1, t2, false);
   if(bar1 < 0 || bar2 < 0)
      return;
   if(bar1 < bar2)
     {
      int tmp = bar1;
      bar1 = bar2;
      bar2 = tmp;
     }
   for(int b = bar2; b <= bar1; b++)
     {
      double h = iHigh(_Symbol, PERIOD_M1, b);
      double l = iLow(_Symbol, PERIOD_M1, b);
      if(h > hi)
         hi = h;
      if(l < lo)
         lo = l;
     }
   if(hi == -DBL_MAX || lo == DBL_MAX)
      return;
//---
   string box_name = ExpName + "_Box_" + sess + "_" + IntegerToString(day_idx);
   string mid_name = ExpName + "_Mid_" + sess + "_" + IntegerToString(day_idx);
   string lbl_name = ExpName + "_Lbl_" + sess + "_" + IntegerToString(day_idx);
//--- draw box
   CreateRectangle(box_name, t1, hi, t2, lo, clr, BoxAlpha);
//--- midline
   if(ShowMidline)
     {
      double mid = (hi + lo) / 2.0;
      CreateTrendLine(mid_name, t1, mid, t2, mid, clr, STYLE_DOT, 1);
     }
   else
      ObjectDelete(0, mid_name);
//--- label
   if(ShowLabels)
     {
      double range_pips;
      if(_Digits == 3 || _Digits == 5)
         range_pips = (hi - lo) / (_Point * 10.0);
      else
         range_pips = (hi - lo) / _Point;
      string lbl_text = label + " " + DoubleToString(range_pips, 1) + "p";
      CreateLabel(lbl_name, t1, hi, lbl_text, clr);
     }
   else
      ObjectDelete(0, lbl_name);
  }

//+------------------------------------------------------------------+
//| Check if price broke today's session box and fire alerts         |
//+------------------------------------------------------------------+
void CheckBreakouts()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   datetime day_start = iTime(_Symbol, PERIOD_D1, 0);
   datetime t1, t2;
//---
   string names[3]  = {"Asian", "London", "NY"};
   string starts[3] = {Asian_Start, London_Start, NewYork_Start};
   string ends[3]   = {Asian_End, London_End, NewYork_End};
   bool   fired[3];
   fired[0] = Alert_AsianFired;
   fired[1] = Alert_LondonFired;
   fired[2] = Alert_NewYorkFired;
//---
   for(int i = 0; i < 3; i++)
     {
      if(fired[i])
         continue;
      if(!GetSessionBounds(day_start, starts[i], ends[i], t1, t2))
         continue;
      string box_name = ExpName + "_Box_" + names[i] + "_0";
      if(ObjectFind(0, box_name) < 0)
         continue;
      double hi = ObjectGetDouble(0, box_name, OBJPROP_PRICE, 0);
      double lo = ObjectGetDouble(0, box_name, OBJPROP_PRICE, 1);
      if(bid > hi || bid < lo)
        {
         string dir = (bid > hi) ? "ABOVE" : "BELOW";
         string msg = _Symbol + " price broke " + dir + " " + names[i] + " session range!";
         if(UsePopup)
            Alert(msg);
         if(UsePush)
            SendNotification(msg);
         fired[i] = true;
         // Write back
         if(i == 0)
            Alert_AsianFired   = true;
         if(i == 1)
            Alert_LondonFired  = true;
         if(i == 2)
            Alert_NewYorkFired = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw stats panel with average session ranges                     |
//+------------------------------------------------------------------+
void DrawStatsPanel()
  {
   double avg_asian = 0, avg_london = 0, avg_ny = 0;
   int cnt_asian = 0, cnt_london = 0, cnt_ny = 0;
//---
   for(int d = 0; d < DaysBack; d++)
     {
      datetime day_start = iTime(_Symbol, PERIOD_D1, d);
      if(day_start == 0)
         continue;
      datetime t1, t2;
      double hi, lo;
      // Asian
      if(GetSessionBounds(day_start, Asian_Start, Asian_End, t1, t2))
        {
         if(GetSessionRange(t1, t2, hi, lo))
           { avg_asian += RangeToPips(hi, lo); cnt_asian++; }
        }
      // London
      if(GetSessionBounds(day_start, London_Start, London_End, t1, t2))
        {
         if(GetSessionRange(t1, t2, hi, lo))
           { avg_london += RangeToPips(hi, lo); cnt_london++; }
        }
      // New York
      if(GetSessionBounds(day_start, NewYork_Start, NewYork_End, t1, t2))
        {
         if(GetSessionRange(t1, t2, hi, lo))
           { avg_ny += RangeToPips(hi, lo); cnt_ny++; }
        }
     }
   if(cnt_asian  > 0)
      avg_asian  /= cnt_asian;
   if(cnt_london > 0)
      avg_london /= cnt_london;
   if(cnt_ny     > 0)
      avg_ny     /= cnt_ny;
//--- panel geometry (top-left, pixel coords)
   int px = 10, py = 20;
   int pw = 200, row_h = 18, hdr_h = 22;
   int total_h = hdr_h + row_h * 3 + 6;
//--- background
   CreatePanelRect(ExpName + "_PanelBg", px, py, pw, total_h,
                   C'20,20,20', C'80,80,80');
//--- header
   CreatePanelLabel(ExpName + "_PanelHdr", px + 4, py + 3,
                    "SESSION RANGE STATS", clrWhite, 7);
//--- rows
   string asian_str  = "Asian     avg " + DoubleToString(avg_asian,  1) + " pip";
   string london_str = "London    avg " + DoubleToString(avg_london, 1) + " pip";
   string ny_str     = "New York  avg " + DoubleToString(avg_ny,     1) + " pip";
   CreatePanelLabel(ExpName + "_PanelRow_Asian",  px + 4, py + hdr_h + 2,
                    asian_str,  Asian_Color,   8);
   CreatePanelLabel(ExpName + "_PanelRow_London", px + 4, py + hdr_h + row_h + 2,
                    london_str, London_Color,  8);
   CreatePanelLabel(ExpName + "_PanelRow_NY",     px + 4, py + hdr_h + row_h * 2 + 2,
                    ny_str,     NewYork_Color, 8);
  }

//+------------------------------------------------------------------+
//| Delete all indicator chart objects                               |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   ObjectsDeleteAll(0, ExpName);
  }

//+------------------------------------------------------------------+
//| Build session start/end datetimes for a given day               |
//+------------------------------------------------------------------+
bool GetSessionBounds(const datetime day_start, const string sess_start,
                      const string sess_end, datetime &t1, datetime &t2)
  {
   int sh, sm, eh, em;
   if(!ParseTime(sess_start, sh, sm))
      return false;
   if(!ParseTime(sess_end,   eh, em))
      return false;
   t1 = day_start + sh * 3600 + sm * 60;
   t2 = day_start + eh * 3600 + em * 60;
// Handle sessions that cross midnight (end < start)
   if(t2 <= t1)
      t2 += 86400;
   return true;
  }

//+------------------------------------------------------------------+
//| Get H/L for a bar range                                         |
//+------------------------------------------------------------------+
bool GetSessionRange(const datetime t1, const datetime t2,
                     double &hi, double &lo)
  {
   hi = -DBL_MAX;
   lo = DBL_MAX;
   int bar1 = iBarShift(_Symbol, PERIOD_M1, t1, false);
   int bar2 = iBarShift(_Symbol, PERIOD_M1, t2, false);
   if(bar1 < 0 || bar2 < 0)
      return false;
   if(bar1 < bar2)
     {
      int tmp = bar1;
      bar1 = bar2;
      bar2 = tmp;
     }
   for(int b = bar2; b <= bar1; b++)
     {
      double h = iHigh(_Symbol, PERIOD_M1, b);
      double l = iLow(_Symbol, PERIOD_M1, b);
      if(h > hi)
         hi = h;
      if(l < lo)
         lo = l;
     }
   return (hi != -DBL_MAX && lo != DBL_MAX);
  }

//+------------------------------------------------------------------+
//| Convert H/L range to pips                                       |
//+------------------------------------------------------------------+
double RangeToPips(const double hi, const double lo)
  {
   double diff = hi - lo;
   if(_Digits == 5 || _Digits == 3)
      return diff / (_Point * 10.0);
   return diff / _Point;
  }

//+------------------------------------------------------------------+
//| Parse "HH:MM" string into hour and minute integers              |
//+------------------------------------------------------------------+
bool ParseTime(const string s, int &h, int &m)
  {
   h = 0;
   m = 0;
   if(StringLen(s) != 5)
      return false;
   if(StringGetCharacter(s, 2) != ':')
      return false;
   string sh = StringSubstr(s, 0, 2);
   string sm = StringSubstr(s, 3, 2);
   h = (int)StringToInteger(sh);
   m = (int)StringToInteger(sm);
   if(h < 0 || h > 23)
      return false;
   if(m < 0 || m > 59)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Create or update a filled rectangle object                       |
//+------------------------------------------------------------------+
void CreateRectangle(const string name, const datetime t1, const double p1,
                     const datetime t2, const double p2,
                     const color clr, const int alpha)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   else
     {
      ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
     }
//--- appearance
   color fill_clr = ColorToARGB(clr, (uchar)alpha);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   fill_clr);
   ObjectSetInteger(0, name, OBJPROP_FILL,      true);
   ObjectSetInteger(0, name, OBJPROP_BACK,      true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED,  false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,     1);
  }

//+------------------------------------------------------------------+
//| Create or update a trend line (used as midline)                  |
//+------------------------------------------------------------------+
void CreateTrendLine(const string name, const datetime t1, const double p1,
                     const datetime t2, const double p2,
                     const color clr, const ENUM_LINE_STYLE style,
                     const int width)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   else
     {
      ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
     }
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,     style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,     width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_BACK,      true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
  }

//+------------------------------------------------------------------+
//| Create or update a text label on the chart (price-anchored)     |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const datetime t1, const double price,
                 const string text, const color clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t1, price);
   else
     {
      ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
     }
   ObjectSetString(0, name, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  8);
   ObjectSetString(0, name, OBJPROP_FONT,      "Arial");
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,    ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_BACK,      false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
  }

//+------------------------------------------------------------------+
//| Create or update a panel background rectangle (pixel coords)    |
//+------------------------------------------------------------------+
void CreatePanelRect(const string name, const int x, const int y,
                     const int sx, const int sy,
                     const color bg_clr, const color bord_clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,      sx);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,      sy);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,    bg_clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, bord_clr);
   ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Create or update a panel text label (pixel coords)              |
//+------------------------------------------------------------------+
void CreatePanelLabel(const string name, const int x, const int y,
                      const string text, const color clr, const int font_size)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetString(0, name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   font_size);
   ObjectSetString(0, name, OBJPROP_FONT,       "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }
//+------------------------------------------------------------------+
