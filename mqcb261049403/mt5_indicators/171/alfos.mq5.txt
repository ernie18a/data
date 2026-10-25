//+------------------------------------------------------------------+
//|                                                        AlfOs.mq5 |
//|                                             Copyright 2009, Alf. |
//|        http://forum.liteforex.org/showthread.php?p=6688#post6688 |
//+------------------------------------------------------------------+
#property copyright   "2009, MetaQuotes Software Corp."
#property link        "http://forum.liteforex.org/showthread.php?p=6688#post6688"
#property description "Alf of Oscillator"

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Silver
#property indicator_width1  2

input int                MA1=12;
input int                MA2=26;
input int                CMO1=55;
input int                CMO2=55;
input int                Signal=9;
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE;

double                   ExtOsMABuffer[];
double                   ExtMacdBuffer[];
double                   ExtSignalBuffer[];
double                   ExtFastMaBuffer[];
double                   ExtSlowMaBuffer[];

int                      ExtFastMaHandle;
int                      ExtSlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,ExtOsMABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMacdBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtSignalBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MA2+Signal-2);

   IndicatorSetString(INDICATOR_SHORTNAME,"AlfOs("+string(MA1)+","+string(MA2)+","+string(Signal)+")");
   PlotIndexSetString(0,PLOT_LABEL,"AlfOs");

   ExtFastMaHandle=iVIDyA(NULL,0,CMO1,MA1,0,InpAppliedPrice);
   ExtSlowMaHandle=iVIDyA(NULL,0,CMO2,MA2,0,InpAppliedPrice);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   if(rates_total<Signal)
      return(0);

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

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

   if(CopyBuffer(ExtFastMaHandle,0,0,to_copy,ExtFastMaBuffer)<=0)
     {
      Print("Getting fast EMA is failed! Error",GetLastError());
      return(0);
     }

   if(CopyBuffer(ExtSlowMaHandle,0,0,to_copy,ExtSlowMaBuffer)<=0)
     {
      Print("Getting slow SMA is failed! Error",GetLastError());
      return(0);
     }

   int i,limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;

   for(i=limit;i<rates_total;i++)
     {

      ExtMacdBuffer[i]=ExtFastMaBuffer[i]-ExtSlowMaBuffer[i];
     }

   SimpleMAOnBuffer(rates_total,prev_calculated,0,Signal,ExtMacdBuffer,ExtSignalBuffer);

   for(i=limit;i<rates_total;i++)
     {
      ExtOsMABuffer[i]=ExtMacdBuffer[i]-ExtSignalBuffer[i];
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
