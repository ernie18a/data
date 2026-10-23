//+--------------------------------------------------------------+
//|                                  Motion Smoothness Index.mq4 |
//+--------------------------------------------------------------+
#property description "Original idea and creation by Alex Grover"
#property description "Metatrader code by Max Michael 2021"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_level1  0.5
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
#property version   "1.00"
#property strict

extern int    length = 50;
extern int   MaxBars = 2000;

double       buffer0[];
double       buffer1[];

int init()
{
   SetIndexBuffer(0, buffer0); SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1, buffer1); SetIndexStyle(1, DRAW_NONE);
   string sShortName="Motion Smoothness Index ("+ IntegerToString(length) +")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName); 
   SetIndexLabel(1,"");
   return(0);
}

int start()
{
   int counted = IndicatorCounted();
   if (counted < 0) return(-1);
   int limit = Bars-counted-1;
   if (limit > MaxBars) limit=MaxBars;
   
   int i=limit;
   while(i>=0) { buffer1[i]=Close[i]-Close[i+1]; i--; }
      
   i=limit;
   while(i>=0)
   {
      if (i > MaxBars-length) buffer0[i]=EMPTY_VALUE;
      else buffer0[i]=iStdDevOnArray(buffer1,0,length,0,MODE_SMA,i) / iStdDev(_Symbol,0,length,0,MODE_SMA,PRICE_CLOSE,i);
      i--;
   }
   return(0);
}
