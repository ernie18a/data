//+------------------------------------------------------------------+
//|                               VolatilityAdjustedMomentumDecay.mq5|
//|                                    Copyright 2026, Bosede Gbadebo|
//|                       https://www.mql5.com/en/users/bosedegbadebo|
//+------------------------------------------------------------------+
#property copyright "Bosede Gbadebo"
#property link      "https://www.mql5.com/en/users/bosedegbadebo"
#property version   "1.00"
#property description "Volatility-Adjusted Momentum Decay Line: a momentum reading that "
#property description "relaxes back toward zero at a speed scaled by the current ATR "
#property description "relative to its own moving average, so decay speed adapts to the "
#property description "prevailing volatility regime instead of using a fixed time constant."

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_level1  0.0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrGray

#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue, clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label1  "VAMD Decay Line"

//--- Input parameters
input int    InpMomentumPeriod = 10;    // Momentum lookback (bars)
input int    InpATRPeriod      = 14;    // ATR period (volatility unit)
input int    InpATRAvgPeriod   = 50;    // ATR averaging period (volatility baseline)
input double InpBaseDecay      = 0.15;  // Base decay rate (0.0 - 1.0)
input double InpMaxDecay       = 0.90;  // Maximum decay rate cap (0.0 - 1.0)

//--- Indicator buffers
double DecayLineBuffer[];
double ColorBuffer[];
double NormMomentumBuffer[];

//--- Globals
int atr_handle = INVALID_HANDLE;
int min_bars   = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMomentumPeriod < 1 || InpATRPeriod < 1 || InpATRAvgPeriod < 1)
     {
      Print("VAMD: invalid input period, must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpBaseDecay <= 0.0 || InpBaseDecay > 1.0 || InpMaxDecay <= 0.0 || InpMaxDecay > 1.0 || InpMaxDecay < InpBaseDecay)
     {
      Print("VAMD: decay rates must satisfy 0 < BaseDecay <= MaxDecay <= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0, DecayLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, NormMomentumBuffer, INDICATOR_CALCULATIONS);

   ArraySetAsSeries(DecayLineBuffer, false);
   ArraySetAsSeries(ColorBuffer, false);
   ArraySetAsSeries(NormMomentumBuffer, false);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   atr_handle = iATR(_Symbol, _Period, InpATRPeriod);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("VAMD: failed to create ATR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   min_bars = InpATRPeriod + InpATRAvgPeriod + InpMomentumPeriod + 10;

   IndicatorSetString(INDICATOR_SHORTNAME, "VAMD(" + IntegerToString(InpMomentumPeriod) + "," +
                       IntegerToString(InpATRPeriod) + "," + IntegerToString(InpATRAvgPeriod) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 4);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
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
   if(rates_total < min_bars)
      return(0);

//--- pull ATR values for the whole series available so far
   double atrArray[];
   ArraySetAsSeries(atrArray, false);
   int copied = CopyBuffer(atr_handle, 0, 0, rates_total, atrArray);
   if(copied <= 0)
      return(0);
   if(copied < rates_total)
      return(prev_calculated); // ATR not fully ready yet, wait for next tick

   int start;
   if(prev_calculated == 0)
     {
      start = min_bars;
      for(int k = 0; k < start && k < rates_total; k++)
        {
         DecayLineBuffer[k]    = EMPTY_VALUE;
         ColorBuffer[k]        = 0.0;
         NormMomentumBuffer[k] = 0.0;
        }
     }
   else
      start = prev_calculated - 1;

   if(start < min_bars)
      start = min_bars;

   for(int i = start; i < rates_total; i++)
     {
      if(i < InpMomentumPeriod || i < InpATRAvgPeriod - 1)
        {
         DecayLineBuffer[i]    = EMPTY_VALUE;
         ColorBuffer[i]        = 0.0;
         NormMomentumBuffer[i] = 0.0;
         continue;
        }

      double rawMomentum = close[i] - close[i - InpMomentumPeriod];
      double atrNow = atrArray[i];

      double normMomentum = (atrNow > 0.0) ? rawMomentum / atrNow : 0.0;
      NormMomentumBuffer[i] = normMomentum;

      //--- ATR regime baseline: simple average of ATR over InpATRAvgPeriod
      double atrSum = 0.0;
      for(int j = i - InpATRAvgPeriod + 1; j <= i; j++)
         atrSum += atrArray[j];
      double atrAvg = atrSum / InpATRAvgPeriod;

      double volRatio = (atrAvg > 0.0) ? atrNow / atrAvg : 1.0;

      double decayRate = InpBaseDecay * volRatio;
      if(decayRate < 0.0)
         decayRate = 0.0;
      if(decayRate > InpMaxDecay)
         decayRate = InpMaxDecay;

      double prevDecay;
      if(i > 0 && DecayLineBuffer[i - 1] != EMPTY_VALUE)
         prevDecay = DecayLineBuffer[i - 1];
      else
         prevDecay = 0.0;

      double decayValue = prevDecay + (normMomentum - prevDecay) * decayRate;

      DecayLineBuffer[i] = decayValue;
      ColorBuffer[i]     = (decayValue >= 0.0) ? 0.0 : 1.0;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
