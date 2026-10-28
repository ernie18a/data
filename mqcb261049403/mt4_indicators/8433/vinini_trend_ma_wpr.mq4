//+------------------------------------------------------------------+
//|                                          VininI_Trend_MA_WPR.mq4 |
//|                                  Сopyright 2008. Victor Nicolaev |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Сopyright 2008. Victor Nicolaev"
#property link      "vinin@mail.ru"


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_level1 0
#property indicator_maximum 1
#property indicator_minimum -1

extern int WPR_Period=100;
extern int Trend_MA_Period=3;

extern int MA_Start=10;
extern int MA_Step=10;
extern int MA_Count=50;
extern int MA_Mode=0;
extern int Limit=1440;
//---- buffers
double Buffer[];
double WPR[];
double Trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
//---- drawing settings
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Trend);
   SetIndexBuffer(1,WPR);
   SetIndexBuffer(2,Buffer);
   return(0); 
  }//int init() 
//+------------------------------------------------------------------+
int start() 
  {
   int i,j;
   double sum=0;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(MA_Count,WPR_Period);

   for(i=limit;i>=0;i--) WPR[i]=iWPR(NULL,0,WPR_Period,i);

   for(i=limit;i>=0;i--)
     {
      sum=0;
      for(j=0;j<MA_Count;j++)
         if(WPR[i]>iMAOnArray(WPR,0,MA_Start+j*MA_Step,0,MA_Mode,i)) sum+=1; else sum-=1;
      Buffer[i]=sum/MA_Count;
     }

   for(i=limit;i>=0;i--)Trend[i]=iMAOnArray(Buffer,0,Trend_MA_Period,0,MA_Mode,i);

   return(0);
  }
//+------------------------------------------------------------------+
