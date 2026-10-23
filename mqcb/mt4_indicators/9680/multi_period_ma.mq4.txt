//+------------------------------------------------------------------+
//|                                              Multi.Period.MA.mq4 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Vladimir Hlystov"
#property link      "http://cmillion.narod.ru"
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 NULL
#property indicator_width1 1  
#property indicator_color2 Lime
#property indicator_width2 2  
//---- input parameters
/*
PRICE_CLOSE    0 
PRICE_OPEN     1 
PRICE_HIGH     2 
PRICE_LOW      3 
PRICE_MEDIAN   4 (high+low)/2 
PRICE_TYPICAL  5 (high+low+close)/3 
PRICE_WEIGHTED 6 (high+low+close+close)/4 

PERIOD_M1   1     1 minute 
PERIOD_M5   5     5 minute 
PERIOD_M15  15    15 minute 
PERIOD_M30  30    30 minute 
PERIOD_H1   60    1 hour 
PERIOD_H4   240   4 hour 
PERIOD_D1   1440  1 day 
PERIOD_W1   10080
PERIOD_MN1  43200
*/
extern int PeriodMA      = 5;
extern int applied_price = 0;
extern int timeframe     = 5;
//---- buffers
double BufferS[];
double Buffer[];
int pUsr;
//+------------------------------------------------------------------+
int init()
  {
   if (timeframe<Period()) timeframe=Period();
   IndicatorBuffers(2);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, Buffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, BufferS);
//---- 
   timeframe = next_period(timeframe);
   SetIndexLabel(0, "MA "+StrPer(timeframe));
   pUsr=timeframe/Period();
   return(0);
  }
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
   {
      BufferS[i]  = iMA(NULL,timeframe,PeriodMA,0,MODE_SMA,applied_price,
                    iBarShift(NULL,timeframe,Time[i],false));
   }
   for(i=0; i<limit; i++)
   {
      Buffer[i]  = iMAOnArray(BufferS,0,pUsr,0,MODE_SMA,i);
   }
   return(0);
}
//+------------------------------------------------------------------+
int next_period(int per)
{
   if (per > 43200)  return(0); 
   if (per > 10080)  return(43200); 
   if (per > 1440)   return(10080); 
   if (per > 240)    return(1440); 
   if (per > 60)     return(240); 
   if (per > 30)     return(60);
   if (per > 15)     return(30); 
   if (per >  5)     return(15); 
   if (per >  1)     return(5);   
   if (per == 1)     return(1);   
   if (per == 0)     return(Period());   
}
//+------------------------------------------------------------------+
string StrPer(int per)
{
   if (per == 1)     return(" M1 ");
   if (per == 5)     return(" M5 ");
   if (per == 15)    return(" M15 ");
   if (per == 30)    return(" M30 ");
   if (per == 60)    return(" H1 ");
   if (per == 240)   return(" H4 ");
   if (per == 1440)  return(" D1 ");
   if (per == 10080) return(" W1 ");
   if (per == 43200) return(" MN1 ");
return("ошибка периода");
}
//+------------------------------------------------------------------+


