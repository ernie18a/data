//+------------------------------------------------------------------+
//|                            Индикатор гэпов                       |
//|                              FOREX&STOX                          |
//|                           ram-kr@krastalk.ru                     |
//+------------------------------------------------------------------+
#property copyright "ram-kr@krastalk.ru"
#property link      ""
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Blue");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"Red");
//----
   IndicatorShortName("Индикатор гэпов FOREX&STOX");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

//+----Main Section--------------------------------------------------+
   double value1,value2;
   for(int i=0;i<=limit;i++)
     {
      value1=0;   value2=0;
      //  гэп ВНИЗ \---------------------------------------------     
      if((Open[i]-Close[i+1])>0) value1=(Open[i]-Close[i+1])/Point;
      //  гэп ВВЕРХ /----------------------------------------------      
      if((Open[i]-Close[i+1])<0) value2=(Open[i]-Close[i+1])/Point;
      //--------------------------------------------------------      
      ExtMapBuffer1[i]=value1;
      ExtMapBuffer2[i]=value2;
     } //end for
//+------------------------------------------------------------------+
   return(0);
  }
//+------------------------------------------------------------------+
