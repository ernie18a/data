//+------------------------------------------------------------------+
//|                                             VininI_MA_WPR.v1.mq4 |
//|                                         Victor Nicolaev aka Vinin|
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "2008. Victor Nicolaev aka Vinin"
#property link      "e-mail: vinin@mail.ru"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Aqua
#property indicator_level1 0
#property indicator_level2 60
#property indicator_level3 -60

#property indicator_maximum 100
#property indicator_minimum -100
//---- input parameters

extern int WPR_Period= 14;
extern int  MA_Period=3;
extern int Limit=1440;
int  MA_Mode  =0;

double WPR[];
double MA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,WPR_Period+MA_Period);
   SetIndexBuffer(0,MA);
   SetIndexBuffer(1,WPR);
   IndicatorShortName("MA_WPR("+WPR_Period+","+MA_Period+")");
   SetIndexLabel(0,"MA(WPR)");

   return(0); }

//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   int i;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if (limit>Limit && Limit>0) limit = Limit;
   for (i = limit;i>=0;i--) WPR[i] = (iWPR(Symbol(),Period(),WPR_Period,i)+50.0)*2.0;
   for (i = limit;i>=0;i--) MA[i] = iMAOnArray(WPR,0,MA_Period,0,MA_Mode,i);
   return(0); 
}// int start()


