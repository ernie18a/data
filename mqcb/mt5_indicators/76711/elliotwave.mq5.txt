//+------------------------------------------------------------------+
//|                                                   ElliotWave.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "https://www.mql5.com/en/users/andrijana998/seller"
#property link      "https://www.mql5.com/en/users/andrijana998/seller"
#property version   "1.00"
#property description "Automatic swing detection with tentative Elliott Wave (1-2-3-4-5 / A-B-C) labeling, basic rule validation and a Fibonacci info panel."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrSilver
#property indicator_width1  1
#property indicator_label1  "Swing pivots"

//--- input parameters
input int    InpDepth            = 12;    // Fractal window (bars each side) used to find swing points
input int    InpDeviationPts     = 300;   // Minimum move (points) required to confirm a new swing
input int    InpBackstep         = 5;     // Minimum bars between two swings of the same type
input int    InpMaxPivots        = 14;    // Maximum recent pivots kept for wave counting
input int    InpHistoryBars      = 3000;  // Bars of history scanned (0 = all available)
input bool   InpShowPanel        = true;  // Show info panel in the top-left corner
input color  InpImpulseColor     = clrDodgerBlue;   // Color of a confirmed impulse wave (1-2-3-4-5)
input color  InpCorrectiveColor  = clrOrange;        // Color of a confirmed correction (A-B-C)
input color  InpUnconfirmedColor = clrGray;          // Color of an unconfirmed fallback count
input color  InpTextColor        = clrWhite;         // Info panel text color
input int    InpFontSize         = 10;    // Info panel font size
input string InpFontName         = "Arial"; // Font used for labels and the info panel
input string InpPrefix           = "EW_";   // Prefix used for all objects created by the indicator

//--- indicator buffer
double ZZBuffer[];

//+------------------------------------------------------------------+
//| Single swing point (fractal pivot)                                |
//+------------------------------------------------------------------+
struct Pivot
  {
   int      bar;      // series-style bar index (0 = most recent bar)
   datetime time;      // bar time
   double   price;     // pivot price
   bool     isHigh;    // true = swing high, false = swing low
  };

//--- pivots in chronological order: index 0 = oldest, last = newest
Pivot pivots[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ZZBuffer, INDICATOR_DATA);
   ArraySetAsSeries(ZZBuffer, true);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Elliott Wave Auto Counter");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, InpPrefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < InpDepth * 2 + 10)
      return(0);

//--- work with series-style indexing (0 = most recent bar)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ZZBuffer, true);

   ArrayInitialize(ZZBuffer, EMPTY_VALUE);

//--- rebuild the swing structure and the wave labeling
   FindPivots(rates_total, time, high, low);
   PlotZigZag();

   ObjectsDeleteAll(0, InpPrefix);

   if(ArraySize(pivots) >= 4)
      LabelWaves(close);
   else
      if(InpShowPanel)
         DrawPanel("Not enough confirmed swing points yet.\nTry lowering Depth/Deviation, or wait for more history.");

   ChartRedraw(0);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Detect fractal-style swing highs/lows and filter them            |
//+------------------------------------------------------------------+
void FindPivots(const int rates_total, const datetime &time[], const double &high[], const double &low[])
  {
   ArrayResize(pivots, 0);

   int scanLimit = rates_total;
   if(InpHistoryBars > 0 && InpHistoryBars < rates_total)
      scanLimit = InpHistoryBars;

   int start = InpDepth;
   int end   = scanLimit - InpDepth - 1;
   if(end <= start)
      return;

//--- collect raw fractal highs/lows
   Pivot raw[];
   int rc = 0;

   for(int i = start; i <= end; i++)
     {
      bool isHigh = true, isLow = true;
      for(int k = 1; k <= InpDepth && (isHigh || isLow); k++)
        {
         if(high[i] < high[i-k] || high[i] < high[i+k])
            isHigh = false;
         if(low[i]  > low[i-k]  || low[i]  > low[i+k])
            isLow  = false;
        }
      if(isHigh)
        {
         ArrayResize(raw, rc+1);
         raw[rc].bar = i; raw[rc].time = time[i]; raw[rc].price = high[i]; raw[rc].isHigh = true;
         rc++;
        }
      else
         if(isLow)
           {
            ArrayResize(raw, rc+1);
            raw[rc].bar = i; raw[rc].time = time[i]; raw[rc].price = low[i]; raw[rc].isHigh = false;
            rc++;
           }
     }

   if(rc == 0)
      return;

//--- convert to chronological order (oldest first)
   Pivot chrono[];
   ArrayResize(chrono, rc);
   for(int j = 0; j < rc; j++)
      chrono[j] = raw[rc-1-j];

//--- merge same-type neighbours and enforce deviation / backstep filters
   Pivot filtered[];
   int fc = 0;

   for(int j = 0; j < rc; j++)
     {
      if(fc == 0)
        {
         ArrayResize(filtered, fc+1);
         filtered[fc] = chrono[j];
         fc++;
         continue;
        }

      Pivot last = filtered[fc-1];

      if(chrono[j].isHigh == last.isHigh)
        {
         if(chrono[j].isHigh && chrono[j].price > last.price)
            filtered[fc-1] = chrono[j];
         else
            if(!chrono[j].isHigh && chrono[j].price < last.price)
               filtered[fc-1] = chrono[j];
         continue;
        }

      double diffPts   = MathAbs(chrono[j].price - last.price) / _Point;
      int    barsApart = (int)MathAbs(chrono[j].bar - last.bar);

      if(diffPts < InpDeviationPts || barsApart < InpBackstep)
         continue;

      ArrayResize(filtered, fc+1);
      filtered[fc] = chrono[j];
      fc++;
     }

//--- keep only the most recent InpMaxPivots pivots
   int keep = MathMin(fc, InpMaxPivots);
   ArrayResize(pivots, keep);
   for(int j = 0; j < keep; j++)
      pivots[j] = filtered[fc - keep + j];
  }

//+------------------------------------------------------------------+
//| Plot the raw swing structure as a background zigzag line         |
//+------------------------------------------------------------------+
void PlotZigZag()
  {
   for(int j = 0; j < ArraySize(pivots); j++)
      ZZBuffer[pivots[j].bar] = pivots[j].price;
  }

//+------------------------------------------------------------------+
//| Check whether pivots[s..s+5] form a valid Elliott impulse         |
//+------------------------------------------------------------------+
bool CheckImpulse(const int s)
  {
   double p0 = pivots[s].price,   p1 = pivots[s+1].price, p2 = pivots[s+2].price;
   double p3 = pivots[s+3].price, p4 = pivots[s+4].price, p5 = pivots[s+5].price;

   int dir = (p1 > p0) ? 1 : -1;

//--- rule 1: wave 2 may not retrace beyond the start of wave 1
   if(dir == 1 && p2 <= p0)
      return(false);
   if(dir == -1 && p2 >= p0)
      return(false);

   double len1 = MathAbs(p1 - p0);
   double len3 = MathAbs(p3 - p2);
   double len5 = MathAbs(p5 - p4);

//--- rule 2: wave 3 may not be the shortest of waves 1, 3 and 5
   if(len3 < len1 && len3 < len5)
      return(false);

//--- rule 3: wave 4 may not overlap the price territory of wave 1
   if(dir == 1 && p4 <= p1)
      return(false);
   if(dir == -1 && p4 >= p1)
      return(false);

   return(true);
  }

//+------------------------------------------------------------------+
//| Find and label the freshest valid impulse and correction         |
//+------------------------------------------------------------------+
void LabelWaves(const double &close[])
  {
   int n = ArraySize(pivots);
   int foundStart = -1;

   for(int s = n - 6; s >= 0; s--)
     {
      if(CheckImpulse(s))
        {
         foundStart = s;
         break;
        }
     }

   if(foundStart >= 0)
     {
      //--- label the confirmed impulse
      string wLabels[6] = {"0","1","2","3","4","5"};
      for(int k = 0; k <= 5; k++)
         DrawWaveLabel(pivots[foundStart+k], wLabels[k], InpImpulseColor);

      //--- label the following correction, if enough pivots exist
      int corrStart = foundStart + 5;
      if(n >= corrStart + 3 + 1)
        {
         string cLabels[3] = {"A","B","C"};
         for(int k = 0; k < 3; k++)
            DrawWaveLabel(pivots[corrStart+k+1], cLabels[k], InpCorrectiveColor);
        }

      if(InpShowPanel)
         DrawPanel(BuildPanelText(foundStart, true));
     }
   else
     {
      //--- fallback: no rule-valid impulse found, show a tentative count
      int cnt = MathMin(5, n);
      for(int k = 0; k < cnt; k++)
        {
         int idx = n - cnt + k;
         DrawWaveLabel(pivots[idx], IntegerToString(k+1) + "?", InpUnconfirmedColor);
        }

      if(InpShowPanel)
         DrawPanel(BuildPanelText(n - cnt, false));
     }
  }

//+------------------------------------------------------------------+
//| Draw a single wave-number/letter text label at a pivot           |
//+------------------------------------------------------------------+
void DrawWaveLabel(const Pivot &pv, const string text, const color clr)
  {
   string name = InpPrefix + "lbl_" + IntegerToString(pv.bar) + "_" + text;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, pv.time, pv.price);
   else
      ObjectMove(0, name, 0, pv.time, pv.price);

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, InpFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize + 2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, pv.isHigh ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Build the info panel text for the current wave count             |
//+------------------------------------------------------------------+
string BuildPanelText(const int s, const bool confirmed)
  {
   string txt = "Elliott Wave Auto Counter\n";

   if(confirmed)
     {
      double p0 = pivots[s].price,   p1 = pivots[s+1].price, p2 = pivots[s+2].price;
      double p3 = pivots[s+3].price, p4 = pivots[s+4].price;
      double len1 = MathAbs(p1-p0), len3 = MathAbs(p3-p2);
      double retr2 = MathAbs(p2-p1)/len1*100.0;
      double retr4 = (len3>0) ? MathAbs(p4-p3)/len3*100.0 : 0.0;
      double ext3  = (len1>0) ? len3/len1*100.0 : 0.0;

      txt += "Status: rule-valid impulse found\n";
      txt += StringFormat("Wave2 retrace: %.1f%%\n", retr2);
      txt += StringFormat("Wave4 retrace: %.1f%%\n", retr4);
      txt += StringFormat("Wave3 vs Wave1: %.1f%%\n", ext3);
     }
   else
     {
      txt += "Status: no rule-valid impulse in view\n";
      txt += "Showing a tentative sequential count only.\n";
     }

   txt += "For guidance only - confirm manually.";
   return(txt);
  }

//+------------------------------------------------------------------+
//| Draw or update the corner info panel                             |
//+------------------------------------------------------------------+
void DrawPanel(const string text)
  {
   string name = InpPrefix + "panel";
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, InpFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }
//+------------------------------------------------------------------+