//+------------------------------------------------------------------+
//|                              Liquidity Void Decay Oscillator.mq5 |
//|                                                  ADEDAYO GBADEBO |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "ADEDAYO GBADEBO"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Detects thin-participation displacement voids and scores how quickly price re-fills them."
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_minimum 0
#property indicator_maximum 100

//--- Plot 1: Void Decay Score (histogram)
#property indicator_label1  "Void Decay Score"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver, clrDodgerBlue, clrTomato
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- Plot 2: Signal Line (smoothed)
#property indicator_label2  "Signal Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Inputs
input int    InpLookback         = 20;    // Bars used to compute average range and volume
input double InpRangeMultiplier  = 1.5;   // Bar range must exceed AvgRange * this to qualify as a void
input double InpVolumeThreshold  = 0.70;  // Bar volume must be below AvgVolume * this to qualify as a void
input double InpDecayRate        = 15.0;  // Score points removed per 10% of the zone re-traded
input int    InpMaxVoids         = 8;     // Maximum number of unfilled void zones tracked at once
input int    InpMinZonePoints    = 0;     // Minimum zone size in points to qualify (0 = disabled)
input int    InpSignalSmoothing  = 3;     // Smoothing period for the signal line

//--- Indicator buffers
double BufDecay[];
double BufDecayColor[];
double BufSignal[];
double BufSmoothTemp[];

//--- Void zone tracking structure
struct VoidZone
  {
   double high;
   double low;
   double score;      // 100 = fresh void, 0 = fully filled/inactive
   datetime created;
   bool   bullish;     // true = void formed on an up-thrust (acts as support), false = down-thrust (resistance)
  };

VoidZone Zones[];
int      ZoneCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufDecay,      INDICATOR_DATA);
   SetIndexBuffer(1, BufDecayColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BufSignal,     INDICATOR_DATA);
   SetIndexBuffer(3, BufSmoothTemp, INDICATOR_CALCULATIONS);

   PlotIndexSetString(0, PLOT_LABEL, "Void Decay Score");
   PlotIndexSetString(1, PLOT_LABEL, "Signal Line");

   ArraySetAsSeries(BufDecay,      false);
   ArraySetAsSeries(BufDecayColor, false);
   ArraySetAsSeries(BufSignal,     false);
   ArraySetAsSeries(BufSmoothTemp, false);

   IndicatorSetString(INDICATOR_SHORTNAME, "Liquidity Void Decay Oscillator (" + IntegerToString(InpLookback) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   ArrayResize(Zones, InpMaxVoids);
   ZoneCount = 0;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Compute the average true range over a lookback window             |
//+------------------------------------------------------------------+
double AverageRange(const double &high[], const double &low[], int idx, int lookback)
  {
   if(idx < lookback)
      return(0.0);
   double sum = 0.0;
   for(int k = idx - lookback; k < idx; k++)
      sum += (high[k] - low[k]);
   return(sum / lookback);
  }

//+------------------------------------------------------------------+
//| Compute the average tick volume over a lookback window            |
//+------------------------------------------------------------------+
double AverageVolume(const long &vol[], int idx, int lookback)
  {
   if(idx < lookback)
      return(0.0);
   long sum = 0;
   for(int k = idx - lookback; k < idx; k++)
      sum += vol[k];
   return((double)sum / lookback);
  }

//+------------------------------------------------------------------+
//| Register a new void zone, evicting the weakest one if at capacity |
//+------------------------------------------------------------------+
void RegisterZone(double zHigh, double zLow, datetime zTime, bool zBullish)
  {
   if(InpMinZonePoints > 0)
     {
      double pts = (zHigh - zLow) / _Point;
      if(pts < InpMinZonePoints)
         return;
     }

   if(ZoneCount < InpMaxVoids)
     {
      Zones[ZoneCount].high    = zHigh;
      Zones[ZoneCount].low     = zLow;
      Zones[ZoneCount].score   = 100.0;
      Zones[ZoneCount].created = zTime;
      Zones[ZoneCount].bullish = zBullish;
      ZoneCount++;
      return;
     }

   // At capacity: replace the weakest (lowest score) zone
   int weakestIdx = 0;
   double weakestScore = Zones[0].score;
   for(int i = 1; i < ZoneCount; i++)
     {
      if(Zones[i].score < weakestScore)
        {
         weakestScore = Zones[i].score;
         weakestIdx = i;
        }
     }
   if(weakestScore < 100.0)
     {
      Zones[weakestIdx].high    = zHigh;
      Zones[weakestIdx].low     = zLow;
      Zones[weakestIdx].score   = 100.0;
      Zones[weakestIdx].created = zTime;
      Zones[weakestIdx].bullish = zBullish;
     }
  }

//+------------------------------------------------------------------+
//| Decay all active zones based on how much of each was re-traded by |
//| the current bar, and return the strongest remaining score plus    |
//| its directional bias (+1 bullish void nearby, -1 bearish).        |
//+------------------------------------------------------------------+
double DecayZones(double barHigh, double barLow, int &bias)
  {
   double strongest = 0.0;
   bias = 0;

   for(int i = ZoneCount - 1; i >= 0; i--)
     {
      if(Zones[i].score <= 0.0)
         continue;

      double zoneRange = Zones[i].high - Zones[i].low;
      if(zoneRange <= 0.0)
        {
         Zones[i].score = 0.0;
         continue;
        }

      // Overlap between the current bar's range and the zone
      double overlapHigh = MathMin(barHigh, Zones[i].high);
      double overlapLow  = MathMax(barLow,  Zones[i].low);
      double overlap     = overlapHigh - overlapLow;

      if(overlap > 0.0)
        {
         double fillFraction = overlap / zoneRange;          // 0..1
         // InpDecayRate is points removed per 10% of the zone re-traded,
         // so a full 100% fill removes InpDecayRate * 10 points.
         double decayAmount  = fillFraction * InpDecayRate * 10.0;
         if(decayAmount > 100.0)
            decayAmount = 100.0;

         Zones[i].score -= decayAmount;
         if(Zones[i].score < 0.0)
            Zones[i].score = 0.0;
        }

      if(Zones[i].score > strongest)
        {
         strongest = Zones[i].score;
         bias = Zones[i].bullish ? 1 : -1;
        }
     }

   return(strongest);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   if(rates_total < InpLookback + 2)
      return(0);

   int start;

   if(prev_calculated == 0)
     {
      // Fresh calculation (chart load / history change): rebuild everything
      ArrayResize(Zones, InpMaxVoids);
      ZoneCount = 0;
      ArrayInitialize(BufDecay, 0.0);
      ArrayInitialize(BufSignal, 0.0);
      ArrayInitialize(BufDecayColor, 0.0);
      start = InpLookback + 1;
     }
   else
     {
      start = prev_calculated - 1;
      if(start < InpLookback + 1)
         start = InpLookback + 1;
     }

   for(int i = start; i < rates_total; i++)
     {
      double avgRange = AverageRange(high, low, i, InpLookback);
      double avgVol   = AverageVolume(tick_volume, i, InpLookback);

      double barRange = high[i] - low[i];

      // Void formation: displacement bar with unusually thin participation
      if(avgRange > 0.0 && avgVol > 0.0 &&
         barRange > avgRange * InpRangeMultiplier &&
         (double)tick_volume[i] < avgVol * InpVolumeThreshold)
        {
         bool bullish = close[i] > open[i];
         RegisterZone(high[i], low[i], time[i], bullish);
        }

      int bias = 0;
      double score = DecayZones(high[i], low[i], bias);

      BufDecay[i] = score;
      // Color index: 0 = neutral/inactive, 1 = bullish void nearby, 2 = bearish void nearby
      if(score <= 0.0)
         BufDecayColor[i] = 0.0;
      else if(bias >= 0)
         BufDecayColor[i] = 1.0;
      else
         BufDecayColor[i] = 2.0;
     }

   // Smooth the signal line (simple moving average of the decay buffer)
   int smoothStart = MathMax(start, InpSignalSmoothing);
   for(int i = smoothStart; i < rates_total; i++)
     {
      double sum = 0.0;
      for(int k = i - InpSignalSmoothing + 1; k <= i; k++)
         sum += BufDecay[k];
      BufSignal[i] = sum / InpSignalSmoothing;
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayFree(Zones);
   ZoneCount = 0;
  }
//+------------------------------------------------------------------+
