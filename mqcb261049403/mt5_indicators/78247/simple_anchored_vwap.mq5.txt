//+------------------------------------------------------------------+
//|                                         Simple_Anchored_VWAP.mq5 |
//|                             Copyright 2026, Maksim Ermolin       |
//|                     https://www.mql5.com/en/market/product/157612 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Maksim Ermolin"
#property link        "https://www.mql5.com/en/market/product/157612"
#property version     "1.00"
#property description "Simple Anchored Volume Weighted Average Price (AVWAP) Indicator."
#property description "Calculates cumulative institutional fair value from a user-defined anchor date."
#property description "Features optional volatility standard deviation bands and auto volume detection."
#property description "For interactive on-chart Drag & Drop, Multi-Anchor confluence, and push alerts:"
#property description "Check Fixed Time AVWAP on MQL5 Market: https://www.mql5.com/en/market/product/157612"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Plot 1: Main AVWAP Line
#property indicator_label1  "AVWAP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: Upper SD Band
#property indicator_label2  "Upper Band (+1 SD)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- Plot 3: Lower SD Band
#property indicator_label3  "Lower Band (-1 SD)"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//--- Volume Type Selection
enum ENUM_VOL_TYPE
{
   VOL_AUTO  = 0, // Auto Detect (Real Volume if available, else Tick)
   VOL_TICK  = 1, // Tick Volume
   VOL_REAL  = 2  // Real Volume
};

//--- Input Parameters
input datetime          InpAnchorTime       = D'2026.10.01 00:00'; // Anchor Date/Time
input ENUM_APPLIED_PRICE InpAppliedPrice    = PRICE_TYPICAL;       // Applied Price (Default: Typical)
input ENUM_VOL_TYPE     InpVolumeType       = VOL_AUTO;            // Volume Source
input bool              InpShowBands        = true;                // Show Standard Deviation Bands (+/- 1 SD)
input double            InpBandMultiplier   = 1.0;                 // Standard Deviation Multiplier

//--- Indicator Buffers
double ExtVwapBuffer[];
double ExtUpperBuffer[];
double ExtLowerBuffer[];

int OnInit()
{
   SetIndexBuffer(0, ExtVwapBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowerBuffer, INDICATOR_DATA);

   PlotIndexSetString(0, PLOT_LABEL, "AVWAP");
   PlotIndexSetString(1, PLOT_LABEL, "Upper Band (+1 SD)");
   PlotIndexSetString(2, PLOT_LABEL, "Lower Band (-1 SD)");

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   ArraySetAsSeries(ExtVwapBuffer, false);
   ArraySetAsSeries(ExtUpperBuffer, false);
   ArraySetAsSeries(ExtLowerBuffer, false);

   IndicatorSetString(INDICATOR_SHORTNAME, "Simple AVWAP");
   return(INIT_SUCCEEDED);
}

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
   if(rates_total <= 0) return(0);

   bool use_real = false;
   if(InpVolumeType == VOL_REAL) use_real = true;
   else if(InpVolumeType == VOL_AUTO)
   {
      long total_real = 0;
      int check_limit = MathMin(rates_total, 50);
      for(int i = rates_total - 1; i >= rates_total - check_limit; i--)
         total_real += volume[i];
      if(total_real > 0) use_real = true;
   }

   int start_idx = -1;
   datetime target_time = InpAnchorTime;
   if(target_time <= 0) target_time = time[0];

   for(int i = 0; i < rates_total; i++)
   {
      if(time[i] >= target_time) { start_idx = i; break; }
   }

   int clear_to = (start_idx >= 0) ? start_idx : rates_total;
   for(int i = 0; i < clear_to; i++)
   {
      ExtVwapBuffer[i]  = EMPTY_VALUE;
      ExtUpperBuffer[i] = EMPTY_VALUE;
      ExtLowerBuffer[i] = EMPTY_VALUE;
   }

   if(start_idx < 0) return(rates_total);

   double cum_vol_price  = 0.0;
   double cum_vol        = 0.0;
   double cum_vol_dev_sq = 0.0;

   for(int i = start_idx; i < rates_total; i++)
   {
      double v = (use_real) ? (double)volume[i] : (double)tick_volume[i];
      if(v <= 0.0) v = 1.0;

      double p = 0.0;
      switch(InpAppliedPrice)
      {
         case PRICE_CLOSE:    p = close[i]; break;
         case PRICE_OPEN:     p = open[i]; break;
         case PRICE_HIGH:     p = high[i]; break;
         case PRICE_LOW:      p = low[i]; break;
         case PRICE_MEDIAN:   p = (high[i] + low[i]) / 2.0; break;
         case PRICE_TYPICAL:  p = (high[i] + low[i] + close[i]) / 3.0; break;
         case PRICE_WEIGHTED: p = (high[i] + low[i] + close[i] + close[i]) / 4.0; break;
         default:             p = (high[i] + low[i] + close[i]) / 3.0; break;
      }

      cum_vol_price += p * v;
      cum_vol       += v;

      double vwap = (cum_vol > 0.0) ? (cum_vol_price / cum_vol) : p;
      ExtVwapBuffer[i] = vwap;

      if(InpShowBands)
      {
         double diff = p - vwap;
         cum_vol_dev_sq += diff * diff * v;
         double variance = (cum_vol > 0.0) ? (cum_vol_dev_sq / cum_vol) : 0.0;
         double sd = MathSqrt(variance) * InpBandMultiplier;

         ExtUpperBuffer[i] = vwap + sd;
         ExtLowerBuffer[i] = vwap - sd;
      }
      else
      {
         ExtUpperBuffer[i] = EMPTY_VALUE;
         ExtLowerBuffer[i] = EMPTY_VALUE;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+