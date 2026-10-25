//+------------------------------------------------------------------+
//|                                                 SuperTrendTV.mq5 |
//|                                 Copyright 2026, Mykyta Samoiliuk |
//|                                                     www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Mykyta Samoiliuk"
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "SuperTrend that matches TradingView's ta.supertrend bar for bar."
#property description "ATR is Wilder/RMA seeded with SMA(period). iATR is not the same thing."
#property description "Direction: -1 = uptrend, +1 = downtrend, as in TradingView."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot 1: the line itself, coloured by trend
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrTeal,clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label1  "SuperTrend"
//--- plot 2 and 3 are not drawn, they are here to be read with iCustom
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Direction"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "ATR"
//--- input parameters
input int    InpPeriod=10;   // ATR period
input double InpFactor=3.0;  // Factor
//--- indicator buffers
double ExtSuperTrend[];      // buffer 0
double ExtColor[];           // buffer 1
double ExtDirection[];       // buffer 2
double ExtATR[];             // buffer 3
double ExtUpper[];           // buffer 4
double ExtLower[];           // buffer 5
double ExtTR[];              // buffer 6
//--- working copies of the inputs, corrected if the caller passed nonsense
int    ExtPeriod=10;
double ExtFactor=3.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- Check for input values. A bad parameter corrects itself rather than stopping
//--- the indicator, the way the standard examples shipped with the terminal do.
//--- Refusing to start also stops any expert that creates this indicator through
//--- iCustom, and the failure surfaces there as an unexplained missing handle.
   if(InpPeriod<1)
     {
      ExtPeriod=10;
      PrintFormat("Incorrect input parameter InpPeriod = %d. Indicator will use value %d.",
                  InpPeriod,ExtPeriod);
     }
   else
      ExtPeriod=InpPeriod;

   if(InpFactor<=0.0)
     {
      ExtFactor=3.0;
      PrintFormat("Incorrect input parameter InpFactor = %.2f. Indicator will use value %.2f.",
                  InpFactor,ExtFactor);
     }
   else
      ExtFactor=InpFactor;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtSuperTrend,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtDirection,INDICATOR_DATA);
   SetIndexBuffer(3,ExtATR,INDICATOR_DATA);
   SetIndexBuffer(4,ExtUpper,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtLower,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtTR,INDICATOR_CALCULATIONS);
//--- the calculation below is recursive and reads bar i-1, so indexing must be
//--- left to right, otherwise i-1 quietly becomes the bar after this one
   ArraySetAsSeries(ExtSuperTrend,false);
   ArraySetAsSeries(ExtColor,false);
   ArraySetAsSeries(ExtDirection,false);
   ArraySetAsSeries(ExtATR,false);
   ArraySetAsSeries(ExtUpper,false);
   ArraySetAsSeries(ExtLower,false);
   ArraySetAsSeries(ExtTR,false);
//--- sets first bar from what index will be drawn
   for(int i=0; i<3; i++)
     {
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,ExtPeriod-1);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,EMPTY_VALUE);
     }
//--- name for DataWindow
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("SuperTrendTV(%d,%.2f)",ExtPeriod,ExtFactor));
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| SuperTrend, TradingView compatible                               |
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
   if(rates_total<ExtPeriod)
      return(0);

   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- the last finished bar is recalculated too, everything after it depends on it
   int start=(prev_calculated>1) ? prev_calculated-1 : 0;
//--- the main loop of calculations
   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      //--- ta.tr(handle_na=true): bar 0 has no previous close
      if(i==0)
         ExtTR[i]=high[0]-low[0];
      else
        {
         double prev_close=close[i-1];
         ExtTR[i]=MathMax(high[i]-low[i],
                          MathMax(MathAbs(high[i]-prev_close),MathAbs(low[i]-prev_close)));
        }
      //--- nothing is defined until the ATR has enough true ranges
      if(i<ExtPeriod-1)
        {
         ExtATR[i]=0.0;
         ExtUpper[i]=0.0;
         ExtLower[i]=0.0;
         ExtDirection[i]=0.0;
         ExtColor[i]=0.0;
         ExtSuperTrend[i]=EMPTY_VALUE;
         continue;
        }
      //--- ta.rma: alpha is 1/period and the seed is SMA(period). That seed is why
      //--- iATR does not line up, its warm-up starts a bar later and the recursion
      //--- carries the gap forever.
      if(i==ExtPeriod-1)
        {
         double sum=0.0;
         for(int k=0; k<ExtPeriod; k++)
            sum+=ExtTR[k];
         ExtATR[i]=sum/ExtPeriod;
        }
      else
         ExtATR[i]=(ExtTR[i]-ExtATR[i-1])/ExtPeriod+ExtATR[i-1];
      //--- raw bands around hl2
      double mid=(high[i]+low[i])/2.0;
      double upper=mid+ExtFactor*ExtATR[i];
      double lower=mid-ExtFactor*ExtATR[i];
      //--- nz() turns an undefined previous band into zero
      bool   has_prev=(i>ExtPeriod-1);
      double prev_upper=has_prev ? ExtUpper[i-1] : 0.0;
      double prev_lower=has_prev ? ExtLower[i-1] : 0.0;
      //--- Sticky bands: a band only tightens until price closes through it.
      //--- Miss this and the result disagrees with TradingView on about half the bars.
      //--- The rule runs on bar 0 as well. Pine compares against nz(band[1]) which is
      //--- zero there, and a comparison with na counts as false, so the upper band
      //--- collapses to zero on that bar. Skipping the rule on bar 0 looks harmless
      //--- and is not: with period 1 the ATR already exists there and the series
      //--- diverges from the original from the very first value.
      bool   has_close=(i>0);
      double prev_close=has_close ? close[i-1] : 0.0;
      if(!(lower>prev_lower || (has_close && prev_close<prev_lower)))
         lower=prev_lower;
      if(!(upper<prev_upper || (has_close && prev_close>prev_upper)))
         upper=prev_upper;
      //--- direction. Comparing against the previous upper band is an exact match
      //--- on purpose: both sides are the same stored double, as in Pine.
      int direction;
      if(!has_prev)
         direction=1;
      else
         if(ExtSuperTrend[i-1]==ExtUpper[i-1])
            direction=(close[i]>upper) ? -1 : 1;
         else
            direction=(close[i]<lower) ? 1 : -1;
      //--- store
      ExtUpper[i]=upper;
      ExtLower[i]=lower;
      ExtDirection[i]=(double)direction;
      ExtSuperTrend[i]=(direction==-1) ? lower : upper;
      ExtColor[i]=(direction==-1) ? 0.0 : 1.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
