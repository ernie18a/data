//+------------------------------------------------------------------+
//|                                           SpreadMonitorPanel.mq5 |
//|                  Live spread monitor panel with spike alerts     |
//|                                                        Dror Munk |
//+------------------------------------------------------------------+
#property copyright   "Dror Munk"
#property version     "1.00"
#property description "Shows the live spread of the chart symbol in a small on-chart"
#property description "panel: current, minimum, average and maximum since attach,"
#property description "color-coded against your warning/danger thresholds."
#property description ""
#property description "Optional alert when the spread stays at or above the danger"
#property description "threshold for N consecutive seconds (news/rollover spikes)."
#property description "Monitoring only - it does not trade and has no buffers."
#property indicator_chart_window
#property indicator_plots 0

//--- inputs
input int              InpWarnPoints    = 20;                // Warning threshold, points
input int              InpDangerPoints  = 40;                // Danger threshold, points
input bool             InpAlertOn       = true;              // Alert on sustained danger spread
input int              InpAlertSeconds  = 3;                 // ...sustained for N seconds
input int              InpAlertCooldown = 300;               // Min seconds between alerts
input ENUM_BASE_CORNER InpCorner        = CORNER_RIGHT_UPPER;// Panel corner
input int              InpXOffset       = 10;                // X offset, px
input int              InpYOffset       = 25;                // Y offset, px
input int              InpFontSize      = 10;                // Font size

//--- panel object names
#define SMP_PREFIX "SMP_"

//--- colors
color COL_BG     = C'20,28,38';
color COL_HEAD   = clrWhite;
color COL_OK     = clrLimeGreen;
color COL_WARN   = clrOrange;
color COL_DANGER = clrTomato;
color COL_MUTED  = clrSilver;

//--- state
double   g_min_spread    = -1;
double   g_max_spread    = 0;
double   g_sum_spread    = 0;
long     g_samples       = 0;
datetime g_attached_at   = 0;
int      g_danger_streak = 0;
datetime g_last_alert    = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_attached_at = TimeCurrent();
   CreatePanel();
   EventSetTimer(1);
   UpdatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, SMP_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer: sample the spread once per second                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   double cur = CurrentSpreadPoints();
   if(cur < 0)
      return;

   if(g_min_spread < 0 || cur < g_min_spread)
      g_min_spread = cur;
   if(cur > g_max_spread)
      g_max_spread = cur;
   g_sum_spread += cur;
   g_samples++;

//--- sustained-danger alert
   if(cur >= InpDangerPoints)
      g_danger_streak++;
   else
      g_danger_streak = 0;

   if(InpAlertOn && g_danger_streak >= InpAlertSeconds &&
      TimeCurrent() - g_last_alert >= InpAlertCooldown)
     {
      g_last_alert = TimeCurrent();
      Alert(StringFormat("%s spread %.0f points >= danger threshold %d for %d s",
                         _Symbol, cur, InpDangerPoints, g_danger_streak));
     }

   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Current spread in points (float-spread safe)                      |
//+------------------------------------------------------------------+
double CurrentSpreadPoints()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0 || bid <= 0 || _Point <= 0)
      return -1;
   return (ask - bid) / _Point;
  }

//+------------------------------------------------------------------+
//| Panel creation                                                    |
//+------------------------------------------------------------------+
bool IsRightCorner()
  {
   return (InpCorner == CORNER_RIGHT_UPPER || InpCorner == CORNER_RIGHT_LOWER);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   int w = 190, h = 118;
   MakeRect(SMP_PREFIX + "bg", InpYOffset, w, h);
   MakeLabel(SMP_PREFIX + "title", InpYOffset + 8,  "Spread Monitor", COL_HEAD, InpFontSize);
   MakeLabel(SMP_PREFIX + "cur",   InpYOffset + 30, "...", COL_OK, InpFontSize + 2);
   MakeLabel(SMP_PREFIX + "min",   InpYOffset + 56, "...", COL_MUTED, InpFontSize - 1);
   MakeLabel(SMP_PREFIX + "avg",   InpYOffset + 74, "...", COL_MUTED, InpFontSize - 1);
   MakeLabel(SMP_PREFIX + "max",   InpYOffset + 92, "...", COL_MUTED, InpFontSize - 1);
  }

//+------------------------------------------------------------------+
//| Panel refresh                                                     |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   double cur = CurrentSpreadPoints();
   double avg = (g_samples > 0) ? g_sum_spread / (double)g_samples : 0;

   color ccur = COL_OK;
   if(cur >= InpDangerPoints)
      ccur = COL_DANGER;
   else
      if(cur >= InpWarnPoints)
         ccur = COL_WARN;

   SetText(SMP_PREFIX + "cur", StringFormat("%s  %.1f pts", _Symbol, cur), ccur);
   SetText(SMP_PREFIX + "min", StringFormat("min  %.1f", (g_min_spread < 0 ? 0 : g_min_spread)), COL_MUTED);
   SetText(SMP_PREFIX + "avg", StringFormat("avg  %.1f   (%I64d samples)", avg, g_samples), COL_MUTED);
   SetText(SMP_PREFIX + "max", StringFormat("max  %.1f   since %s", g_max_spread,
           TimeToString(g_attached_at, TIME_MINUTES)), COL_MUTED);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Object helpers                                                    |
//+------------------------------------------------------------------+
void MakeRect(const string name, const int y, const int w, const int h)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, IsRightCorner() ? InpXOffset + w : InpXOffset);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, COL_BG);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, C'60,80,100');
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MakeLabel(const string name, const int y, const string text,
               const color clr, const int size)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, IsRightCorner() ? InpXOffset + 12 : InpXOffset + 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,
                    IsRightCorner() ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(const string name, const string text, const color clr)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
