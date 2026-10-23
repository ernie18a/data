//+------------------------------------------------------------------+
//|                                                 StopDistance.mq5 |
//|                                      Copyright 2026, Bohdan Klok |
//|                            https://www.mql5.com/en/users/kbposht |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Bohdan Klok"
#property link      "https://www.mql5.com/en/users/kbposht"
#property version   "1.10"
#property description "Shows the range of every bar in points, its moving average"
#property description "and a suggested stop distance (average x factor)."
#property description ""
#property description "Why: a stop tighter than the typical bar range gets taken"
#property description "out by ordinary noise. The indicator makes that threshold"
#property description "visible in points - the same unit a stop loss is set in."
#property description ""
#property description "All values are in symbol points, not pips."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Range
#property indicator_label1  "Range"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSteelBlue
#property indicator_width1  2
//--- plot Average
#property indicator_label2  "Average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
//--- plot Suggested stop
#property indicator_label3  "Suggested stop"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
//+------------------------------------------------------------------+
//| Averaging method                                                 |
//+------------------------------------------------------------------+
enum ENUM_AVG_METHOD
  {
   AVG_SMA=0,   // Simple (SMA)
   AVG_EMA=1    // Exponential (EMA)
  };
//--- input parameters
input int             InpPeriod=20;        // Averaging period
input ENUM_AVG_METHOD InpMethod=AVG_SMA;   // Averaging method
input double          InpStopFactor=1.5;   // Stop factor (multiplier of the average)
//--- indicator buffers
double RangeBuf[];
double AvgBuf[];
double StopBuf[];
//--- EMA smoothing factor
double g_emaK=0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check input parameters
   if(InpPeriod<1)
     {
      Print("StopDistance: InpPeriod must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStopFactor<=0.0)
     {
      Print("StopDistance: InpStopFactor must be > 0");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(_Point<=0.0)
     {
      Print("StopDistance: the symbol does not report a point size");
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,RangeBuf,INDICATOR_DATA);
   SetIndexBuffer(1,AvgBuf,INDICATOR_DATA);
   SetIndexBuffer(2,StopBuf,INDICATOR_DATA);
//--- plot labels shown in the Data Window
   PlotIndexSetString(0,PLOT_LABEL,"Range, points");
   PlotIndexSetString(1,PLOT_LABEL,StringFormat("Average(%d), points",InpPeriod));
   PlotIndexSetString(2,PLOT_LABEL,StringFormat("Stop x%.2f, points",InpStopFactor));
//--- the averages are undefined before the first full period
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpPeriod-1);
//--- short name; points are whole numbers, so no decimal digits
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("StopDistance(%d, %s, %.2f)",InpPeriod,
                                   (InpMethod==AVG_EMA ? "EMA" : "SMA"),InpStopFactor));
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- EMA smoothing factor
   g_emaK=2.0/(InpPeriod+1.0);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//|                                                                  |
//| The arrays passed in here are NOT series: index 0 is the oldest  |
//| bar and rates_total-1 is the current one. That is the opposite   |
//| of CopyRates/iTime in an Expert Advisor, where 0 is the latest   |
//| bar - so the loops below run forward.                            |
//|                                                                  |
//| prev_calculated is the number of bars processed on the previous  |
//| call. Without it the whole history is recomputed on every tick.  |
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
   if(rates_total<InpPeriod)
      return(0);
//---
   const double invPoint=1.0/_Point;
//--- first call: compute everything; afterwards only the forming bar
   const int start=(prev_calculated>1 ? prev_calculated-1 : 0);
   for(int i=start; i<rates_total; ++i)
      RangeBuf[i]=(high[i]-low[i])*invPoint;
//--- the average starts on the first bar that has a full period behind it
   int avgStart=(prev_calculated>1 ? prev_calculated-1 : InpPeriod-1);
   if(avgStart<InpPeriod-1)
      avgStart=InpPeriod-1;
//---
   for(int i=avgStart; i<rates_total; ++i)
     {
      if(InpMethod==AVG_EMA && i>InpPeriod-1)
        {
         //--- EMA builds on the previous value, which is already in the buffer
         AvgBuf[i]=RangeBuf[i]*g_emaK+AvgBuf[i-1]*(1.0-g_emaK);
        }
      else
        {
         //--- SMA; for EMA this is also the seed on the first calculated bar
         double sum=0.0;
         for(int k=i-InpPeriod+1; k<=i; ++k)
            sum+=RangeBuf[k];
         AvgBuf[i]=sum/InpPeriod;
        }
      StopBuf[i]=AvgBuf[i]*InpStopFactor;
     }
//--- becomes prev_calculated on the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
