//+------------------------------------------------------------------+
//|                                                   AwesomeMod.mq5 |
//|                                                            Manel |
//+------------------------------------------------------------------+
#property copyright "Manel"
#property link      ""
#property version   "2.00"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrRed
#property indicator_width1  1
#property indicator_label1  "FastAO"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGreen,clrTomato
#property indicator_width2  1
#property indicator_label2  "SlowAO"
#property indicator_level2 -0.5
#property indicator_level3  0.5
//+------------------------------------------------------------------+
//| Include packages
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
//--- inputs
input int shortmean  = 18;
input int mediummean = 40;
input int longmean   = 200;
input int meanAOfast= 12;
input int meanAOslow= 18;
//--- indicator buffers
double ExtAOBufferSlow[];
double ExtColorBufferSlow[];
//---
double ExtAOBufferFast[];
double ExtColorBufferFast[];
//---
double ExtFastBuffer[];
double ExtMediumBuffer[];
double ExtSlowBuffer[];
//---
double EMA_AOBuffer_Slow[];
double EMA_AOBuffer_Fast[];
//--- handles for MAs
int    ExtFastEMAHandle;
int    ExtMediumEMAHandle;
int    ExtSlowEMAHandle;
//--- bars minimum for calculation
#define DATA_LIMIT longmean+1
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,EMA_AOBuffer_Slow,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBufferSlow,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,EMA_AOBuffer_Fast,INDICATOR_DATA);
   SetIndexBuffer(3,ExtColorBufferFast,INDICATOR_COLOR_INDEX);
//---
   SetIndexBuffer(4,ExtFastBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtMediumBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtSlowBuffer,INDICATOR_CALCULATIONS);
//---
   SetIndexBuffer(7,ExtAOBufferSlow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ExtAOBufferFast,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,33);
//--- name for DataWindow 
   IndicatorSetString(INDICATOR_SHORTNAME,"AwesomeMod("+string(shortmean)+
                      ","+string(mediummean)+","+string(longmean)+";"+string(meanAOfast)+","+string(meanAOslow)+")");
//--- get handles
   ExtFastEMAHandle=iMA(NULL,0,shortmean,0,MODE_EMA,PRICE_MEDIAN);
   ExtMediumEMAHandle=iMA(NULL,0,mediummean,0,MODE_EMA,PRICE_MEDIAN);
   ExtSlowEMAHandle=iMA(NULL,0,longmean,0,MODE_EMA,PRICE_MEDIAN);
//--- initialization done
  }
//+------------------------------------------------------------------+
//|  Awesome Oscillator                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- check for rates total
   if(rates_total<=DATA_LIMIT)
      return(0);// not enough bars for calculation
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtFastEMAHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtFastEMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtMediumEMAHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMediumEMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtSlowEMAHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowEMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
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
//--- get FastEMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtFastEMAHandle,0,0,to_copy,ExtFastBuffer)<=0)
     {
      Print("Getting fast EMA is failed! Error",GetLastError());
      return(0);
     }
//--- get MediumEMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMediumEMAHandle,0,0,to_copy,ExtMediumBuffer)<=0)
     {
      Print("Getting medium EMA is failed! Error",GetLastError());
      return(0);
     }
//--- get SlowEMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtSlowEMAHandle,0,0,to_copy,ExtSlowBuffer)<=0)
     {
      Print("Getting slow EMA is failed! Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   int i,limit;
   if(prev_calculated<=DATA_LIMIT)
     {
      for(i=0;i<DATA_LIMIT;i++)
        {
         ExtAOBufferSlow[i]=0.0;
         ExtAOBufferFast[i]=0.0;
        }
      limit=DATA_LIMIT;
     }
   else limit=prev_calculated-1;
//--- main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtAOBufferFast[i]=(ExtFastBuffer[i]/ExtMediumBuffer[i]-1)*100;
      ExtAOBufferSlow[i]=(ExtMediumBuffer[i]/ExtSlowBuffer[i]-1)*100;
     }
//---
   SmoothedMAOnBuffer(rates_total,prev_calculated,1,meanAOfast,ExtAOBufferFast,EMA_AOBuffer_Fast);
   SmoothedMAOnBuffer(rates_total,prev_calculated,1,meanAOslow,ExtAOBufferSlow,EMA_AOBuffer_Slow);
//---
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(EMA_AOBuffer_Fast[i]>=EMA_AOBuffer_Fast[i-1]) ExtColorBufferFast[i]=0.0; // set color Green
      else ExtColorBufferFast[i]=1.0; // set color Red
      if(EMA_AOBuffer_Slow[i]>=EMA_AOBuffer_Slow[i-1]) ExtColorBufferSlow[i]=0.0; // set color Green
      else ExtColorBufferSlow[i]=1.0; // set color Red
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
