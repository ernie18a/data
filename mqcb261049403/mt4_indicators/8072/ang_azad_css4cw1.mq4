//+------------------------------------------------------------------+
//|                                              ang_AZad_Css[cw].mq4|
//|                           Copyright © 2006, ANG3110@latchess.com |
//+------------------------------------------------------------------+
#property  copyright "ANG3110@latchess.com"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Indigo
#property indicator_color2 DarkSlateBlue
//----
extern double ki=2;
extern int Shift=0;
extern int zShift=0;
//----
double za[], z, za2[], z2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, za);
   SetIndexShift(0, Shift);
   SetIndexBuffer(1, za2);
   SetIndexShift(1, Shift+zShift);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(0,"ang_AZad(C)Z"+ki+",s"+Shift+"");
   SetIndexLabel(1,"ang_AZad(C)Z2"+ki+",s"+Shift+"ss"+zShift+"");
   IndicatorShortName("ang_AZad_Css[cw]");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator start function                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, cbi;
   int n, ai, bi, f, ai2, bi2, f2;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
//----
   for(i=limit; i>=0; i--)
     {
      if(Close[i] > z && Close[i] > Close[i+1])
         z=za[i+1] + (Close[i] - za[i+1])/ki;
      if(Close[i] < z && Close[i] < Close[i+1])
         z=za[i+1] + (Close[i] - za[i+1])/ki;
      if(Close[i] > z2 && Close[i] < Close[i+1])
         z2=za2[i+1] + (Close[i] - za2[i+1])/ki;
      if(Close[i] < z2 && Close[i] > Close[i+1])
         z2=za2[i+1] + (Close[i] - za2[i+1])/ki;
      if(i > Bars - 5)
        {
         z=Close[i];
         z2=z;
        }
      za[i]=z;
      za2[i]=z2;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

