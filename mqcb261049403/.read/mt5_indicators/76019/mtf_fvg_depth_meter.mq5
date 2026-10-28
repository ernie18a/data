//+------------------------------------------------------------------+
//|                                       MTF_FVG_Depth_Meter.mq5    |
//|                                        Author: AKINYEMI AKINTOYE |
//+------------------------------------------------------------------+
#property copyright "AKINYEMI AKINTOYE"
#property version   "1.00"
#property description "Multi-Timeframe FVG Depth Meter: scans several timeframes for unfilled Fair Value Gaps, draws them on the chart, and plots a local bull/bear imbalance histogram."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label1  "FVG Bull Depth (pts)"

#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label2  "FVG Bear Depth (pts)"

//--- Inputs
input ENUM_TIMEFRAMES InpTF1               = PERIOD_M15; // Timeframe 1
input ENUM_TIMEFRAMES InpTF2               = PERIOD_H1;  // Timeframe 2
input ENUM_TIMEFRAMES InpTF3               = PERIOD_H4;  // Timeframe 3
input ENUM_TIMEFRAMES InpTF4               = PERIOD_D1;  // Timeframe 4
input int              InpLookbackBars     = 200;         // Bars scanned per timeframe
input double           InpMinGapPoints     = 50;          // Minimum gap size (points)
input int              InpMaxGapsPerTF     = 12;           // Max unfilled gaps drawn per timeframe
input double           InpFillThresholdPercent = 100.0;   // % traversal to mark a gap as filled
input color             InpBullColor        = clrDodgerBlue; // Bullish gap color
input color             InpBearColor        = clrOrangeRed;  // Bearish gap color
input ENUM_LINE_STYLE  InpRectStyle        = STYLE_SOLID;  // Gap rectangle border style
input bool              InpShowDashboard    = true;          // Show summary dashboard
input int               InpFontSize         = 9;             // Dashboard font size
input string            InpFontName         = "Consolas";     // Dashboard font

//--- Buffers
double BufferUp[];
double BufferDown[];

//--- Object name prefix
string gPrefix = "MTF_FVG_";

//--- Data structures
struct GapInfo
  {
   datetime t1;
   double   top;
   double   bottom;
   bool     bullish;
   double   fillPercent;
  };

struct TFData
  {
   ENUM_TIMEFRAMES tf;
   string          label;
   GapInfo         gaps[];
  };

TFData gTF[4];

//+------------------------------------------------------------------+
//| Convert a timeframe enum to a short display string                |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   string s = EnumToString(tf);
   StringReplace(s, "PERIOD_", "");
   return s;
  }

//+------------------------------------------------------------------+
//| Detect a new bar on the current chart timeframe                   |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastTime = 0;
   datetime t = iTime(_Symbol, _Period, 0);
   if(t != lastTime)
     {
      lastTime = t;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Scan one timeframe for unfilled Fair Value Gaps                   |
//+------------------------------------------------------------------+
void ScanTimeframeForGaps(TFData &d)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);

   int copied = CopyRates(_Symbol, d.tf, 0, InpLookbackBars + 5, rates);
   if(copied < 5)
     {
      ArrayResize(d.gaps, 0);
      return;
     }

   GapInfo found[];
   int foundCount = 0;

   for(int s = 2; s <= copied - 1; s++)
     {
      double h1 = rates[s].high;
      double l1 = rates[s].low;
      double h3 = rates[s - 2].high;
      double l3 = rates[s - 2].low;

      bool   bullish = false, bearish = false;
      double top = 0.0, bottom = 0.0;

      if(h1 < l3)
        {
         bullish = true;
         top     = l3;
         bottom  = h1;
        }
      else
         if(l1 > h3)
           {
            bearish = true;
            top     = l1;
            bottom  = h3;
           }
         else
            continue;

      double gapPts = (top - bottom) / _Point;
      if(gapPts < InpMinGapPoints)
         continue;

      double filledExtent = 0.0;
      for(int j = s - 3; j >= 0; j--)
        {
         if(bullish)
           {
            double lowJ = rates[j].low;
            if(lowJ <= bottom)
              {
               filledExtent = gapPts;
               break;
              }
            if(lowJ < top)
              {
               double covered = (top - lowJ) / _Point;
               if(covered > filledExtent)
                  filledExtent = covered;
              }
           }
         else
           {
            double highJ = rates[j].high;
            if(highJ >= top)
              {
               filledExtent = gapPts;
               break;
              }
            if(highJ > bottom)
              {
               double covered = (highJ - bottom) / _Point;
               if(covered > filledExtent)
                  filledExtent = covered;
              }
           }
        }

      double fillPct = (gapPts > 0) ? (filledExtent / gapPts * 100.0) : 0.0;
      if(fillPct >= InpFillThresholdPercent)
         continue; // already filled, skip

      GapInfo gi;
      gi.t1          = rates[s - 1].time;
      gi.top         = top;
      gi.bottom      = bottom;
      gi.bullish     = bullish;
      gi.fillPercent = fillPct;

      int n = ArraySize(found);
      ArrayResize(found, n + 1);
      found[n] = gi;
      foundCount++;

      if(foundCount >= InpMaxGapsPerTF)
         break;
     }

   ArrayResize(d.gaps, foundCount);
   for(int x = 0; x < foundCount; x++)
      d.gaps[x] = found[x];
  }

//+------------------------------------------------------------------+
//| Draw the currently unfilled gap rectangles on the main chart      |
//+------------------------------------------------------------------+
void DrawGaps()
  {
   ObjectsDeleteAll(0, gPrefix + "RECT_");

   for(int k = 0; k < 4; k++)
     {
      int cnt = ArraySize(gTF[k].gaps);
      for(int x = 0; x < cnt; x++)
        {
         GapInfo gi = gTF[k].gaps[x];
         string  name = gPrefix + "RECT_" + IntegerToString(k) + "_" + IntegerToString(x);
         datetime t2 = TimeCurrent() + PeriodSeconds(_Period) * 20;

         if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, gi.t1, gi.top, t2, gi.bottom))
            continue;

         color clr = gi.bullish ? InpBullColor : InpBearColor;
         ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, name, OBJPROP_STYLE, InpRectStyle);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }
     }
  }

//+------------------------------------------------------------------+
//| Create or update a dashboard text label                           |
//+------------------------------------------------------------------+
void CreateOrUpdateLabel(string name, string text, int row)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20 + row * 16);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, name, OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrSilver);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Refresh the on-chart summary dashboard                            |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   int    totalGaps = 0;
   double totalDepth = 0.0;

   CreateOrUpdateLabel(gPrefix + "LBL_HEADER", "MTF FVG Depth Meter", 0);

   for(int k = 0; k < 4; k++)
     {
      int    cnt = ArraySize(gTF[k].gaps);
      double depth = 0.0;
      for(int x = 0; x < cnt; x++)
         depth += (gTF[k].gaps[x].top - gTF[k].gaps[x].bottom) / _Point;

      totalGaps  += cnt;
      totalDepth += depth;

      string txt = StringFormat("%-4s  %2d gaps   %6.0f pt", gTF[k].label, cnt, depth);
      CreateOrUpdateLabel(gPrefix + "LBL_" + IntegerToString(k), txt, k + 1);
     }

   string totalTxt = StringFormat("Total: %d gaps  |  %.0f pt", totalGaps, totalDepth);
   CreateOrUpdateLabel(gPrefix + "LBL_TOTAL", totalTxt, 5);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferUp, INDICATOR_DATA);
   SetIndexBuffer(1, BufferDown, INDICATOR_DATA);
   ArraySetAsSeries(BufferUp, false);
   ArraySetAsSeries(BufferDown, false);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   gTF[0].tf = InpTF1;
   gTF[1].tf = InpTF2;
   gTF[2].tf = InpTF3;
   gTF[3].tf = InpTF4;
   for(int k = 0; k < 4; k++)
      gTF[k].label = TimeframeToString(gTF[k].tf);

   IndicatorSetString(INDICATOR_SHORTNAME, "MTF FVG Depth Meter");
   IndicatorSetInteger(INDICATOR_DIGITS, 0);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, gPrefix);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   if(rates_total < 3)
      return(0);

   int start = (prev_calculated > 2) ? prev_calculated - 1 : 2;

   for(int i = start; i < rates_total; i++)
     {
      BufferUp[i]   = 0.0;
      BufferDown[i] = 0.0;

      if(i < 2)
         continue;

      // candle1 = i-2 (oldest), candle2 = i-1 (middle), candle3 = i (newest)
      if(high[i - 2] < low[i])
        {
         double gapSize = (low[i] - high[i - 2]) / _Point;
         if(gapSize >= InpMinGapPoints)
            BufferUp[i] = gapSize;
        }
      else
         if(low[i - 2] > high[i])
           {
            double gapSize = (low[i - 2] - high[i]) / _Point;
            if(gapSize >= InpMinGapPoints)
               BufferDown[i] = -gapSize;
           }
     }

   if(IsNewBar())
     {
      for(int k = 0; k < 4; k++)
         ScanTimeframeForGaps(gTF[k]);

      DrawGaps();

      if(InpShowDashboard)
         UpdateDashboard();
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
