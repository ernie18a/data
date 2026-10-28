//+------------------------------------------------------------------+
//|                                            VininI_Trend_LRMA.mq4 |
//|                                  Сopyright 2008. Victor Nicolaev |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Сopyright 2008. Victor Nicolaev"
#property link      "vinin@mail.ru"


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Orange
#property indicator_level1 0
#property indicator_maximum 1
#property indicator_minimum -1
#property indicator_width1 2

extern int MA_Start=10;
extern int MA_Step=10;
extern int MA_Count=50;
extern int MA_Mode=0;
extern int MA_Close=1;
extern int SignalSMA=3;
extern int Limit=1440;
extern bool LRMA_On=true;
//---- buffers
double Buffer[];
double Buffer0[];
//+------------------------------------------------------------------+
//| Функция LRMA общая                                               |
//+------------------------------------------------------------------+
double LRMA(int periodMA,int shift)
  {
   double result=NormalizeDouble(3 *iMA(NULL,0,periodMA,0,MODE_LWMA,PRICE_CLOSE,shift) -
                                 2 *iMA(NULL,0,periodMA,0,MODE_SMA,PRICE_CLOSE,shift),Digits);
   return(result);
  }
//+------------------------------------------------------------------+
//| Функция LRMAonArray                                              |
//+------------------------------------------------------------------+
double LRMAonArray(double Arr[],int periodMA,int shift)
  {
   double result=3 *iMAOnArray(Arr,Bars,periodMA,0,MODE_LWMA,shift) -
                 2*iMAOnArray(Arr,Bars,periodMA,0,MODE_SMA,shift);
   return(result);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
//---- drawing settings
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Buffer);
   SetIndexBuffer(1,Buffer0);

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
   if(counted_bars==0) limit-=1+MA_Count;
   for(i=limit;i>=0;i--)
     {
      sum=0;
      for(j=0;j<MA_Count;j++) if(LRMA(MA_Close,i)>LRMA(MA_Start+j*MA_Step,i)) sum+=1; else sum-=1;
      Buffer0[i]=sum/MA_Count;
     }
   for(i=limit;i>=0;i--)
     {
      if(LRMA_On)
         Buffer[i]=LRMAonArray(Buffer0,SignalSMA,i);
      else
         Buffer[i]=iMAOnArray(Buffer0,0,SignalSMA,0,MODE_SMA,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
