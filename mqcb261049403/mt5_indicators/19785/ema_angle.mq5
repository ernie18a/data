//+------------------------------------------------------------------+
//|                                                    EMA_Angle.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description   ""
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot HistEMA
#property indicator_label1  "EMA Angle"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      InpPeriod   =  50;   // Period EMA
input uint     InpShift    =  6;    // Shift of the second EMA
input double   InpTreshold =  0.3;  // Treshold
//--- indicator buffers
double         BufferEMA[];
double         BufferEMAColors[];
double         BufferTMP[];
//--- global variables
int            period;
int            shift;
int            handle_ema;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set parameters
   period=(InpPeriod<1 ? 1 : InpPeriod);
   shift=int(InpShift==0 ? 1 : InpShift);
   handle_ema=iMA(NULL,0,period,0,MODE_EMA,PRICE_MEDIAN);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("Failed to create an EMA handle");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferEMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferEMAColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferTMP,INDICATOR_CALCULATIONS);
//--- colors parameters 
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrGreen);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,clrRed);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,2,clrYellow);
//--- strings parameters
   string params="("+(string)period+","+(string)shift+","+(string)InpTreshold+")";
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA Angle"+params);
//---
   return(INIT_SUCCEEDED);
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
//--- Checking for minimum number of bars
   if(rates_total<period+shift+1) return 0;
//--- Set arrays as time series
   ArraySetAsSeries(BufferEMA,true);
   ArraySetAsSeries(BufferEMAColors,true);
   ArraySetAsSeries(BufferTMP,true);
//--- check for limits
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-shift-1;
      ArrayInitialize(BufferEMA,0.0);
      ArrayInitialize(BufferTMP,EMPTY_VALUE);
      int copied=CopyBuffer(handle_ema,0,0,(limit==0 ? 1 : rates_total),BufferTMP);
      if(copied<1 || Point()==0) return 0;
     }
//--- calculate indicator
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int copied=CopyBuffer(handle_ema,0,0,(limit==0 ? 1 : rates_total),BufferTMP);
      if(copied<1 || Point()==0) return 0;
      double ema0=BufferTMP[i];
      double ema1=BufferTMP[i+shift];
      double angle=(ema0-ema1)/Point();
      BufferEMA[i]=angle;
      if(angle>=InpTreshold)
         BufferEMAColors[i]=0;
      else if(angle<=-InpTreshold)
         BufferEMAColors[i]=1;
      else
         BufferEMAColors[i]=2;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
