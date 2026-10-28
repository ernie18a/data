//+------------------------------------------------------------------+
//|                                     SessionVolatilityHeatmap.mq5 |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <Canvas\Canvas.mqh>

//--- inputs -----------------------------------------------------------------
input group "=== Volatility Heatmap ==="
input int    InpLookbackDays   = 30;    // Days of history used to average range per hour
input ENUM_BASE_CORNER InpCorner = CORNER_RIGHT_UPPER; // Heatmap panel corner
input int    InpOffsetX        = 12;    // X offset (pixels)
input int    InpOffsetY        = 18;    // Y offset (pixels)
input int    InpPanelWidth     = 340;   // Panel width (pixels)
input int    InpPanelHeight    = 150;   // Panel height (pixels)
input int    InpRefreshSecs    = 30;    // Refresh interval (seconds)

input group "=== Session Shading (server/broker time) ==="
input bool   InpShowSessions   = true;  // Draw session background bands on the chart
input int    InpSessionDays    = 6;     // How many recent days to shade
input int    InpAsianStartHour  = 0;    // Asian session start hour
input int    InpAsianEndHour    = 9;    // Asian session end hour
input int    InpLondonStartHour = 7;    // London session start hour
input int    InpLondonEndHour   = 16;   // London session end hour
input int    InpNewYorkStartHour= 12;   // New York session start hour
input int    InpNewYorkEndHour  = 21;   // New York session end hour

input group "=== Colors ==="
input color  InpBackColor      = C'12,18,32';    // Panel background (ink)
input color  InpBorderColor    = C'242,169,59';  // Panel border (amber)
input color  InpTextColor      = C'237,239,245'; // Panel text (off-white)
input color  InpLowColor       = C'26,38,58';    // Heatmap: quiet hour
input color  InpHighColor      = C'242,169,59';  // Heatmap: busiest hour
input color  InpAsianBandColor = C'223,235,250'; // Asian session shading (pale — chart objects render opaque)
input color  InpLondonBandColor= C'253,238,214'; // London session shading (pale — chart objects render opaque)
input color  InpNewYorkBandColor=C'250,222,222'; // New York session shading (pale — chart objects render opaque)

//--- globals ------------------------------------------------------------------
CCanvas g_canvas;
string  g_panelName = "SVH_Panel";
bool    g_canvasReady = false;
string  g_bandPrefix  = "SVH_Band_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!g_canvas.CreateBitmapLabel(g_panelName, InpOffsetX, InpOffsetY,
                                   InpPanelWidth, InpPanelHeight,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("SessionVolatilityHeatmap: failed to create canvas, error ", GetLastError());
      return(INIT_FAILED);
     }

   ObjectSetInteger(0, g_panelName, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, g_panelName, OBJPROP_XDISTANCE, InpOffsetX);
   ObjectSetInteger(0, g_panelName, OBJPROP_YDISTANCE, InpOffsetY);
   ObjectSetInteger(0, g_panelName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_HIDDEN, true);

   g_canvasReady = true;

   EventSetTimer(MathMax(5, InpRefreshSecs));
   RefreshAll();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_canvasReady)
      g_canvas.Destroy();
   ObjectDelete(0, g_panelName);
   ObjectsDeleteAll(0, g_bandPrefix);
  }

//+------------------------------------------------------------------+
//| Timer — periodic refresh independent of ticks                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RefreshAll();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[])
  {
   static datetime lastBar = 0;
   if(rates_total > 0 && time[rates_total - 1] != lastBar)
     {
      lastBar = time[rates_total - 1];
      RefreshAll();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Rebuilds both the heatmap panel and the session bands              |
//+------------------------------------------------------------------+
void RefreshAll()
  {
   double hourlyRange[24];
   if(ComputeHourlyRange(hourlyRange))
      DrawHeatmapPanel(hourlyRange);

   if(InpShowSessions)
      DrawSessionBands();
  }

//+------------------------------------------------------------------+
//| Averages (high-low), in points, for each hour of the day over the  |
//| lookback window, using the chart's own timeframe.                  |
//+------------------------------------------------------------------+
bool ComputeHourlyRange(double &hourlyRange[])
  {
   ArrayInitialize(hourlyRange, 0.0);
   double sums[24];
   int    counts[24];
   ArrayInitialize(sums, 0.0);
   ArrayInitialize(counts, 0);

   datetime fromTime = TimeCurrent() - (InpLookbackDays * 86400);

   MqlRates rates[];
   int copied = CopyRates(_Symbol, _Period, fromTime, TimeCurrent(), rates);
   if(copied <= 0)
      return(false);

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      point = 0.0001;

   MqlDateTime dt;
   for(int i = 0; i < copied; i++)
     {
      TimeToStruct(rates[i].time, dt);
      int hour = dt.hour;
      double rangePoints = (rates[i].high - rates[i].low) / point;
      sums[hour]   += rangePoints;
      counts[hour] += 1;
     }

   for(int h = 0; h < 24; h++)
      hourlyRange[h] = (counts[h] > 0) ? (sums[h] / counts[h]) : 0.0;

   return(true);
  }

//+------------------------------------------------------------------+
//| Draws the 24-cell heatmap strip with hour labels                   |
//+------------------------------------------------------------------+
void DrawHeatmapPanel(const double &hourlyRange[])
  {
   if(!g_canvasReady)
      return;

   g_canvas.Erase(ColorToARGB(InpBackColor, 235));
   g_canvas.Rectangle(0, 0, InpPanelWidth - 1, InpPanelHeight - 1, ColorToARGB(InpBorderColor, 255));

   g_canvas.FontSet("Arial Bold", -100);
   g_canvas.TextOut(12, 10, "SESSION VOLATILITY (avg range, pts)", ColorToARGB(InpBorderColor, 255));

   double maxVal = 0.0;
   for(int h = 0; h < 24; h++)
      if(hourlyRange[h] > maxVal)
         maxVal = hourlyRange[h];
   if(maxVal <= 0.0)
      maxVal = 1.0;

   int marginX  = 12;
   int top      = 34;
   int barsAreaW = InpPanelWidth - 2 * marginX;
   int barsAreaH = 68;
   int cellW    = barsAreaW / 24;

   for(int h = 0; h < 24; h++)
     {
      double frac = hourlyRange[h] / maxVal;
      color cellColor = BlendColor(InpLowColor, InpHighColor, frac);

      int cx = marginX + h * cellW;
      int barH = (int)(frac * barsAreaH);
      int cy = top + (barsAreaH - barH);

      g_canvas.FillRectangle(cx, cy, cx + cellW - 2, top + barsAreaH, ColorToARGB(cellColor, 255));
     }

   //--- baseline and hour ticks every 3 hours
   g_canvas.Line(marginX, top + barsAreaH, marginX + barsAreaW, top + barsAreaH, ColorToARGB(InpTextColor, 90));
   g_canvas.FontSet("Arial", -70);
   for(int h = 0; h < 24; h += 3)
     {
      int cx = marginX + h * cellW;
      g_canvas.TextOut(cx, top + barsAreaH + 4, IntegerToString(h), ColorToARGB(InpTextColor, 170));
     }

   g_canvas.FontSet("Arial", -75);
   g_canvas.TextOut(marginX, InpPanelHeight - 16,
                     "Hours are broker/server time  |  " + IntegerToString(InpLookbackDays) + "d lookback",
                     ColorToARGB(InpTextColor, 140));

   g_canvas.Update();
  }

//+------------------------------------------------------------------+
//| Linear color blend between two colors, t in [0,1]                  |
//+------------------------------------------------------------------+
color BlendColor(const color c1, const color c2, double t)
  {
   t = MathMax(0.0, MathMin(1.0, t));
   int r1 = (int)(c1 & 0xFF),         g1 = (int)((c1 >> 8) & 0xFF),  b1 = (int)((c1 >> 16) & 0xFF);
   int r2 = (int)(c2 & 0xFF),         g2 = (int)((c2 >> 8) & 0xFF),  b2 = (int)((c2 >> 16) & 0xFF);

   int r = (int)(r1 + (r2 - r1) * t);
   int g = (int)(g1 + (g2 - g1) * t);
   int b = (int)(b1 + (b2 - b1) * t);
   return((color)(r | (g << 8) | (b << 16)));
  }

//+------------------------------------------------------------------+
//| Draws session background bands on the price chart for recent days  |
//+------------------------------------------------------------------+
void DrawSessionBands()
  {
   ObjectsDeleteAll(0, g_bandPrefix);

   //--- generous vertical extent so the band always spans full chart height
   int bars = MathMin(iBars(_Symbol, _Period), 3000);
   if(bars < 10)
      return;

   double hi = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, bars, 0));
   double lo = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, bars, 0));
   double pad = (hi - lo) * 4.0;
   if(pad <= 0.0)
      pad = hi * 0.05;
   double top = hi + pad;
   double bottom = lo - pad;

   datetime today = TimeCurrent() - (TimeCurrent() % 86400);

   for(int d = 0; d < InpSessionDays; d++)
     {
      datetime dayStart = today - (d * 86400);

      DrawOneBand(dayStart, InpAsianStartHour, InpAsianEndHour, InpAsianBandColor, top, bottom, "Asian_" + IntegerToString(d));
      DrawOneBand(dayStart, InpLondonStartHour, InpLondonEndHour, InpLondonBandColor, top, bottom, "London_" + IntegerToString(d));
      DrawOneBand(dayStart, InpNewYorkStartHour, InpNewYorkEndHour, InpNewYorkBandColor, top, bottom, "NewYork_" + IntegerToString(d));
     }
  }

//+------------------------------------------------------------------+
//| Draws one session rectangle for one day, handling same-day ranges  |
//+------------------------------------------------------------------+
void DrawOneBand(const datetime dayStart, const int startHour, const int endHour,
                  const color bandColor, const double top, const double bottom, const string tag)
  {
   if(endHour <= startHour)
      return; // same-day sessions only, keeps the object model simple and predictable

   datetime t1 = dayStart + startHour * 3600;
   datetime t2 = dayStart + endHour * 3600;

   string name = g_bandPrefix + tag;
   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, top, t2, bottom))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, bandColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+------------------------------------------------------------------+