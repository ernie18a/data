//+------------------------------------------------------------------+
//|                                             VininI_MV_WPR_v1.mq4 |
//|                                         Victor Nicolaev aka Vinin|
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Сopyright 2008. Victor Nicolaev aka Vinin"
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

extern string WPR_Symbol="GBPUSD";
extern int WPR_Period= 14;
extern int Limit=1440;

int reversi;

double WPR[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,WPR_Period);
   SetIndexBuffer(0,WPR);
   IndicatorShortName(WPR_Symbol+"(WPR,"+WPR_Period+")");
   SetIndexLabel(0,WPR_Symbol+"(WPR)");
   reversi=0;
   if (StringFind(Symbol(),"USD",0)!=StringFind(WPR_Symbol,"USD",0)) reversi=1;
   return(0); }

//+------------------------------------------------------------------+
int start() {
   static int TimeWPR=-1;
   int limit;
   int counted_bars=IndicatorCounted();
   int i, CurrentTime, WPRPos;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   if (limit>Limit && Limit>0) limit = Limit;
   if (TimeWPR>0) limit+=iBarShift(WPR_Symbol,Period(),TimeWPR);
   for (i = limit;i>=0;i--){
      CurrentTime=Time[i];
      WPRPos=iBarShift(WPR_Symbol,Period(),CurrentTime);
      if (iTime(WPR_Symbol,Period(),WPRPos)<CurrentTime) WPRPos++;
      WPR[i] = (iWPR(WPR_Symbol,Period(),WPR_Period,WPRPos)+50.0)*2.0;
      if (reversi!=0) WPR[i]*=-1.0;
      
   }
   TimeWPR=iTime(WPR_Symbol,Period(),0);
   
   
   return(0); 
}// int start()


