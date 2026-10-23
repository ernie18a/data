//+------------------------------------------------------------------+
//|                                               Rate_AOModPips.mq5 |
//|                                                    Manel Sanchon |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Manel Sanchon"
#property version   "1.00"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_width1  1
#property indicator_label1  "Rate_AOModPips"

//+------------------------------------------------------------------+
//| Include packages
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>

//--- inputs
input int short_mean  = 10;
input int long_mean   = 30;
input int meanAO      = 7;
input int meanSpeed   = 7;

//--- indicator buffers
double ExtAOBuffer[];
double ExtBuffer[];
double ExtColorBuffer[];
double SpeedAOMod[];

double max=0.00;

//--- handles for MAs
int    ExtAOHandle;

//--- bars minimum for calculation
#define DATA_LIMIT 33
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,SpeedAOMod,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtAOBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,33);
//--- name for DataWindow 
   IndicatorSetString(INDICATOR_SHORTNAME,"Rate_AOModPips("+string(short_mean)
                      +","+string(long_mean)
                      +";"+string(meanAO)+","+string(meanSpeed)+")");
//--- get handles
   ExtAOHandle=iCustom(NULL,0,"AwesomeModPips",short_mean,long_mean,meanAO);

//---- initialization done
  }
//+------------------------------------------------------------------+
//|  PipsToAverage Indicator                                         |
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
   int calculated=BarsCalculated(ExtAOHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtAOHandle is calculated (",calculated,"bars ). Error",GetLastError());
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
//--- get AO buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtAOHandle,0,0,to_copy,ExtAOBuffer)<=0)
     {
      Print("Getting fast AO is failed! Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   int i,limit;
   if(prev_calculated<=DATA_LIMIT)
     {
      for(i=0;i<DATA_LIMIT;i++)
         ExtBuffer[i]=0;
      limit=DATA_LIMIT;
     }
   else limit=prev_calculated-1;
//--- main loop of calculations

   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtBuffer[i]=(ExtAOBuffer[i]-ExtAOBuffer[i-1]);
     }

   SmoothedMAOnBuffer(rates_total,prev_calculated,1,meanSpeed,ExtBuffer,SpeedAOMod);

   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(SpeedAOMod[i]>=SpeedAOMod[i-1])    ExtColorBuffer[i]=0.0; // set color Green
      else                                  ExtColorBuffer[i]=1.0; // set color Red
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
