//+------------------------------------------------------------------+
//|                                            Candels High Open.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
#property description "Comparison of four previous candles"
//+------------------------------------------------------------------+
//|    if(high(1)>high(2) && high(2)>high(3) &&                      |
//|       high(3)>high(4) && open(1)>open(2) &&                      |
//|       open(2)>open(3) && open(3)>open(4))                        |
//|       BuyOp=true;                                                |
//|    if(high(1)<high(2) && high(2)<high(3) &&                      |
//|       high(3)<high(4) && open(1)<open(2) &&                      |
//|       open(2)<open(3) && open(3)<open(4))                        |
//|       SellOp=true;                                               |
//+------------------------------------------------------------------+
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
//--- input parameter
input bool           InpReverse=false;         // Reverse signals
//--- indicator buffer
double               ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- name for DataWindow
   string short_name="Candels High Open";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+" (Reverge signals "+InpReverse+")");
//---
   ArraySetAsSeries(ExtLineBuffer,true);
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
//---
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(open,true);
//---
   if(rates_total<4)
      return(0);
//---
   int limit=rates_total-prev_calculated+1;
   if(prev_calculated==0)
      limit=rates_total-5;
//---
   for(int i=limit;i>=0;i--)
     {
      if(high[i+1]>high[i+2] && high[i+2]>high[i+3] && 
         high[i+3]>high[i+4] && open[i+1]>open[i+2] && 
         open[i+2]>open[i+3] && open[i+3]>open[i+4])
        {
         if(!InpReverse)
            ExtLineBuffer[i]=1;
         else
            ExtLineBuffer[i]=-1;
        }
      if(high[i+1]<high[i+2] && high[i+2]<high[i+3] && 
         high[i+3]<high[i+4] && open[i+1]<open[i+2] && 
         open[i+2]<open[i+3] && open[i+3]<open[i+4])
        {
         if(!InpReverse)
            ExtLineBuffer[i]=-1;
         else
            ExtLineBuffer[i]=1;
        }
      else
        {
         ExtLineBuffer[i]=0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
