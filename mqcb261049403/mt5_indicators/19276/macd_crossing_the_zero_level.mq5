//+------------------------------------------------------------------+
//|                                 MACD Crossing the zero level.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Moving Average Convergence/Divergence and lines"
#property description "Filling crossing the zero level"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "Crossing" 
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrRed,clrBlue 
#property indicator_width1  1
//+------------------------------------------------------------------+
//| Base crossing line                                               |
//+------------------------------------------------------------------+
enum BASE_CROSSING_LINE
  {
   MACD=0,    // MACD
   Signal=1,  // Signal
  };
//--- input parameters
input int                  InpFastEMA=12;                // Fast EMA period
input int                  InpSlowEMA=26;                // Slow EMA period
input int                  InpSignalSMA=9;               // Signal SMA period
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;  // Applied price
input BASE_CROSSING_LINE   InpBaseCrossingLine=Signal;   // Crossing the zero level
//--- indicator buffers
double                     ExtCrossingBuffer1[];
double                     ExtCrossingBuffer2[];
double                     ExtMacdBuffer[];
double                     ExtSignalBuffer[];
double                     ExtFastMaBuffer[];
double                     ExtSlowMaBuffer[];
//--- MA handles
int                        ExtFastMaHandle;
int                        ExtSlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtCrossingBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtCrossingBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMacdBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtSignalBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   if(InpBaseCrossingLine==Signal)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpSignalSMA-1);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpSignalSMA-1);
     }
//--- name for Dindicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD Crossing the zero level("+string(InpFastEMA)+","+string(InpSlowEMA)+","+string(InpSignalSMA)+")");
//--- get MA handles
   ExtFastMaHandle=iMA(NULL,0,InpFastEMA,0,MODE_EMA,InpAppliedPrice);
   ExtSlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
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
//--- check for data
   if(rates_total<InpSignalSMA)
      return(0);
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtFastMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtSlowMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//--- get Fast EMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtFastMaHandle,0,0,to_copy,ExtFastMaBuffer)<=0)
     {
      Print("Getting fast EMA is failed! Error",GetLastError());
      return(0);
     }
//--- get SlowSMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtSlowMaHandle,0,0,to_copy,ExtSlowMaBuffer)<=0)
     {
      Print("Getting slow SMA is failed! Error",GetLastError());
      return(0);
     }
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate MACD
   for(int i=limit;i<rates_total && !IsStopped();i++)
      ExtMacdBuffer[i]=ExtFastMaBuffer[i]-ExtSlowMaBuffer[i];
//--- calculate Signal
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- draw or move line
   for(int i=limit;i<rates_total && !IsStopped();i++)
     {
      if(InpBaseCrossingLine==Signal)
        {
         if(ExtSignalBuffer[i]<0.0) // the signal line crossed zero from top to bottom
           {
            ExtCrossingBuffer1[i]=low[i];
            ExtCrossingBuffer2[i]=0.0;
           }
         else // the signal line crossed zero from the bottom up
           {
            ExtCrossingBuffer1[i]=0.0;
            ExtCrossingBuffer2[i]=low[i];
           }
        }
      else
        {
         if(ExtMacdBuffer[i]<0.0) // the signal line crossed zero from top to bottom
           {
            ExtCrossingBuffer1[i]=low[i];
            ExtCrossingBuffer2[i]=0.0;
           }
         else // the signal line crossed zero from the bottom up
           {
            ExtCrossingBuffer1[i]=0.0;
            ExtCrossingBuffer2[i]=low[i];
           }
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
