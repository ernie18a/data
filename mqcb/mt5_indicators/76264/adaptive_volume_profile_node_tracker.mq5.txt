//+------------------------------------------------------------------+
//|                         Adaptive Volume Profile Node Tracker.mq5 |
//|                                   Copyright 2026, Adeolu Gbadebo |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Adeolu Gbadebo"
#property link        "https://forge.mql5.io"
#property version     "1.00"
#property description "Rolling, volatility-adaptive volume profile with POC, Value Area,"
#property description "and High/Low Volume Node (HVN/LVN) tracking."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "POC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Value Area High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_DASH
#property indicator_width2  1

#property indicator_label3  "Value Area Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DASH
#property indicator_width3  1

//--- inputs
input int    InpLookback         = 200;    // Rolling window length (bars) used to build the profile
input int    InpMaxBins          = 24;     // Maximum number of price bins in the profile
input int    InpATRPeriod        = 14;     // ATR period used to adapt bin width to volatility
input double InpValueAreaPercent = 70.0;   // Percent of total volume defining the Value Area
input int    InpRecalcBars       = 10;     // Bars between profile recalculations
input bool   InpUseRealVolume    = false;  // Use real (exchange) volume instead of tick volume
input double InpNodeStdDevMult   = 1.0;    // StdDev multiplier for HVN / LVN node classification
input color  InpHVNColor         = clrOrangeRed;   // High Volume Node color
input color  InpLVNColor         = clrGray;        // Low Volume Node color

//--- indicator buffers
double POCBuffer[];
double VAHBuffer[];
double VALBuffer[];

//--- globals
int      g_atrHandle    = INVALID_HANDLE;
datetime g_lastBarTime  = 0;
int      g_barsSinceCalc = 0;
string   g_prefix       = "APVNT_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, POCBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, VAHBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, VALBuffer, INDICATOR_DATA);

   ArraySetAsSeries(POCBuffer, false);
   ArraySetAsSeries(VAHBuffer, false);
   ArraySetAsSeries(VALBuffer, false);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   if(InpLookback < 20)
   {
      Print("InpLookback must be at least 20 bars.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(InpMaxBins < 5)
   {
      Print("InpMaxBins must be at least 5.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle. Error: ", GetLastError());
      return(INIT_FAILED);
   }

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("Adaptive Volume Profile Node Tracker (%d,%d)", InpLookback, InpMaxBins));

   g_barsSinceCalc = InpRecalcBars; // force a build on the first tick

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);

   ObjectsDeleteAll(0, g_prefix);
}

//+------------------------------------------------------------------+
//| Draw a horizontal / trend line object                            |
//+------------------------------------------------------------------+
void CreateLevelLine(const string name, const datetime t0, const double p0,
                      const datetime t1, const double p1, const color clr,
                      const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t0, p0, t1, p1);
   else
   {
      ObjectMove(0, name, 0, t0, p0);
      ObjectMove(0, name, 1, t1, p1);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Draw the profile: POC/VAH/VAL lines, HVN/LVN nodes, mini histogram|
//+------------------------------------------------------------------+
void DrawProfileObjects(const datetime t0, const datetime t1, const datetime tRight,
                         const double windowLow, const double binWidth, const int binCount,
                         const double &binVolume[], const double maxVol,
                         const double pocPrice, const double vahPrice, const double valPrice,
                         const double hvnThreshold, const double lvnThreshold)
{
   ObjectsDeleteAll(0, g_prefix);

   CreateLevelLine(g_prefix + "POC", t0, pocPrice, t1, pocPrice, clrDodgerBlue, STYLE_SOLID, 2);
   CreateLevelLine(g_prefix + "VAH", t0, vahPrice, t1, vahPrice, clrSilver, STYLE_DASH, 1);
   CreateLevelLine(g_prefix + "VAL", t0, valPrice, t1, valPrice, clrSilver, STYLE_DASH, 1);

   int periodSeconds  = PeriodSeconds();
   int histogramBars   = 15;

   for(int b = 0; b < binCount; b++)
   {
      double binLow  = windowLow + b * binWidth;
      double binHigh = binLow + binWidth;
      double binMid  = (binLow + binHigh) / 2.0;

      if(binVolume[b] > 0 && binVolume[b] >= hvnThreshold)
      {
         CreateLevelLine(g_prefix + "HVN_" + IntegerToString(b), t0, binMid, t1, binMid,
                          InpHVNColor, STYLE_SOLID, 3);
      }
      else if(binVolume[b] <= lvnThreshold)
      {
         CreateLevelLine(g_prefix + "LVN_" + IntegerToString(b), t0, binMid, t1, binMid,
                          InpLVNColor, STYLE_DOT, 1);
      }

      if(maxVol > 0)
      {
         double   ratio    = binVolume[b] / maxVol;
         int      barsWide = (int)MathRound(ratio * histogramBars);
         if(barsWide < 1) barsWide = 1;

         datetime rectT0 = tRight;
         datetime rectT1 = tRight + barsWide * periodSeconds;

         string rname = g_prefix + "HIST_" + IntegerToString(b);
         if(ObjectFind(0, rname) < 0)
            ObjectCreate(0, rname, OBJ_RECTANGLE, 0, rectT0, binLow, rectT1, binHigh);
         else
         {
            ObjectMove(0, rname, 0, rectT0, binLow);
            ObjectMove(0, rname, 1, rectT1, binHigh);
         }
         ObjectSetInteger(0, rname, OBJPROP_COLOR, (binVolume[b] >= hvnThreshold) ? InpHVNColor : clrSilver);
         ObjectSetInteger(0, rname, OBJPROP_FILL, true);
         ObjectSetInteger(0, rname, OBJPROP_BACK, true);
         ObjectSetInteger(0, rname, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, rname, OBJPROP_HIDDEN, true);
      }
   }
}

//+------------------------------------------------------------------+
//| Build the rolling adaptive volume profile                        |
//+------------------------------------------------------------------+
void BuildProfile(const int rates_total, const datetime &time[], const double &high[],
                   const double &low[], const double &close[], const long &tick_volume[],
                   const long &volume[])
{
   int endIdx   = rates_total - 1;
   int startIdx = endIdx - InpLookback + 1;
   if(startIdx < 0) startIdx = 0;

   double windowHigh = -DBL_MAX;
   double windowLow  =  DBL_MAX;

   for(int i = startIdx; i <= endIdx; i++)
   {
      if(high[i] > windowHigh) windowHigh = high[i];
      if(low[i]  < windowLow)  windowLow  = low[i];
   }
   if(windowHigh <= windowLow)
      return;

   double atrBuf[];
   ArraySetAsSeries(atrBuf, true);
   if(CopyBuffer(g_atrHandle, 0, 0, 1, atrBuf) <= 0)
      return;

   double atrValue = atrBuf[0];
   if(atrValue <= 0)
      atrValue = (windowHigh - windowLow) / InpMaxBins;

   double rawBinWidth = atrValue * 0.5;
   if(rawBinWidth <= 0)
      return;

   int binCount = (int)MathRound((windowHigh - windowLow) / rawBinWidth);
   if(binCount < 5)          binCount = 5;
   if(binCount > InpMaxBins) binCount = InpMaxBins;

   double binWidth = (windowHigh - windowLow) / binCount;

   double binVolume[];
   ArrayResize(binVolume, binCount);
   ArrayInitialize(binVolume, 0.0);

   double totalVolume = 0.0;

   for(int i = startIdx; i <= endIdx; i++)
   {
      double vol = InpUseRealVolume ? (double)volume[i] : (double)tick_volume[i];
      int bin = (int)((close[i] - windowLow) / binWidth);
      if(bin < 0) bin = 0;
      if(bin >= binCount) bin = binCount - 1;
      binVolume[bin] += vol;
      totalVolume    += vol;
   }
   if(totalVolume <= 0)
      return;

   // --- Point of Control (highest-volume bin) ---
   int    pocBin = 0;
   double maxVol = binVolume[0];
   for(int b = 1; b < binCount; b++)
   {
      if(binVolume[b] > maxVol)
      {
         maxVol = binVolume[b];
         pocBin = b;
      }
   }

   // --- Value Area expansion around POC ---
   int    loBin = pocBin, hiBin = pocBin;
   double vaVolume     = binVolume[pocBin];
   double targetVolume = totalVolume * (InpValueAreaPercent / 100.0);

   while(vaVolume < targetVolume && (loBin > 0 || hiBin < binCount - 1))
   {
      double volBelow = (loBin > 0)             ? binVolume[loBin - 1] : -1.0;
      double volAbove = (hiBin < binCount - 1)   ? binVolume[hiBin + 1] : -1.0;

      if(volAbove >= volBelow)
      {
         hiBin++;
         vaVolume += binVolume[hiBin];
      }
      else
      {
         loBin--;
         vaVolume += binVolume[loBin];
      }
   }

   double pocPrice = windowLow + (pocBin + 0.5) * binWidth;
   double vahPrice = windowLow + (hiBin + 1) * binWidth;
   double valPrice = windowLow + loBin * binWidth;

   // --- Mean / StdDev of bin volumes for HVN / LVN classification ---
   double mean = totalVolume / binCount;
   double variance = 0.0;
   for(int b = 0; b < binCount; b++)
      variance += MathPow(binVolume[b] - mean, 2);
   variance /= binCount;
   double stdev = MathSqrt(variance);

   double hvnThreshold = mean + InpNodeStdDevMult * stdev;
   double lvnThreshold = MathMax(0.0, mean - InpNodeStdDevMult * stdev);

   // --- Publish POC / VAH / VAL across the profile window in the buffers ---
   for(int i = startIdx; i <= endIdx; i++)
   {
      POCBuffer[i] = pocPrice;
      VAHBuffer[i] = vahPrice;
      VALBuffer[i] = valPrice;
   }

   DrawProfileObjects(time[startIdx], time[endIdx], time[endIdx], windowLow, binWidth, binCount,
                       binVolume, maxVol, pocPrice, vahPrice, valPrice, hvnThreshold, lvnThreshold);
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
   if(rates_total < InpLookback + InpATRPeriod + 5)
      return(0);

   int start = (prev_calculated > 1) ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
   {
      POCBuffer[i] = (i > 0) ? POCBuffer[i - 1] : EMPTY_VALUE;
      VAHBuffer[i] = (i > 0) ? VAHBuffer[i - 1] : EMPTY_VALUE;
      VALBuffer[i] = (i > 0) ? VALBuffer[i - 1] : EMPTY_VALUE;
   }

   int lastIdx = rates_total - 1;
   bool isNewBar = (time[lastIdx] != g_lastBarTime);

   if(prev_calculated == 0)
      g_barsSinceCalc = InpRecalcBars; // force first calculation

   if(isNewBar)
   {
      g_barsSinceCalc++;
      g_lastBarTime = time[lastIdx];
   }

   if(g_barsSinceCalc >= InpRecalcBars && rates_total >= InpLookback)
   {
      g_barsSinceCalc = 0;
      BuildProfile(rates_total, time, high, low, close, tick_volume, volume);
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
