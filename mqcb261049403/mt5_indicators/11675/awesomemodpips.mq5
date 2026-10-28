//+------------------------------------------------------------------+
//|                                               AwesomeModPips.mq5 |
//|                                                    Manel Sanchon |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Manel Sanchon"
#property version   "1.00"
//---- indicator settings
#property indicator_separate_window
//#property indicator_level2 -20
//#property indicator_level3  20
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_width1  1
#property indicator_label1  "AOModPips"

//+------------------------------------------------------------------+
//| Include packages
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>

//--- inputs
input int shortmean = 30;
input int longmean  = 60;

input int meanAO=30;

//--- indicator buffers
double ExtAOBuffer[];
double ExtColorBuffer[];
double ExtFastBuffer[];
double ExtSlowBuffer[];
double EMA_AOBuffer[];

double max=0.00;

//--- handles for MAs
int    ExtFastEMAHandle;
int    ExtSlowEMAHandle;
//--- bars minimum for calculation
#define DATA_LIMIT 33
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,EMA_AOBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtAOBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtFastBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtSlowBuffer,INDICATOR_CALCULATIONS);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,33);
//--- name for DataWindow 
   IndicatorSetString(INDICATOR_SHORTNAME,"AwesomeModPips("+string(shortmean)+
                      ","+string(longmean)+";"+string(meanAO)+")");
//--- get handles
   ExtFastEMAHandle=iMA(NULL,0,shortmean,0,MODE_EMA,PRICE_CLOSE);
   ExtSlowEMAHandle=iMA(NULL,0,longmean,0,MODE_EMA,PRICE_CLOSE);
//---- initialization done
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
         ExtAOBuffer[i]=0.0;
      limit=DATA_LIMIT;
     }
   else limit=prev_calculated-1;
//--- main loop of calculations

   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtAOBuffer[i]=(ExtFastBuffer[i]-ExtSlowBuffer[i])/_Point/10;
     }

   SmoothedMAOnBuffer(rates_total,prev_calculated,1,meanAO,ExtAOBuffer,EMA_AOBuffer);

   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(EMA_AOBuffer[i]>=EMA_AOBuffer[i-1])ExtColorBuffer[i]=0.0; // set color Green
      else                                  ExtColorBuffer[i]=1.0; // set color Red
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
