//+------------------------------------------------------------------+
//|                                      Multi.Period.Stochastic.mq4 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Vladimir Hlystov"
#property link      "http://cmillion.narod.ru"
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 DarkOrange
#property indicator_width1 1  
#property indicator_color2 Orange
#property indicator_width2 1  
//---- input parameters
extern int KPeriod =5;
extern int DPeriod =3;
extern int Slowing =3;
extern int timeframe =60;
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
   SetIndexLabel(0, "Stochastic "+StrPer(timeframe));
   pUsr=timeframe/Period();
   return(0);
  }
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
   {
      BufferS[i]  = iStochastic(NULL,timeframe,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_MAIN,
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


