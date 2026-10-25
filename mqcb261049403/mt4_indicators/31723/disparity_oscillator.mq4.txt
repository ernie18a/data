//+--------------------------------------------------------------+
//|                                     Disparity Oscillator.mq4 |
//+--------------------------------------------------------------+
#property description "Code by Max Michael 2020"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Aqua
#property version     "1.00"
#property strict

extern int    period = 10;
extern int   MaxBars = 1000;

double       pipvalue;
double       buffer1[];

int init()
{
   SetIndexBuffer(0, buffer1);  SetIndexStyle(0, DRAW_LINE);
   if (period<4) period=4;
   string sShortName="Disparity Oscillator ("+ period +")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0, sShortName);
   pipvalue = Point*MathPow(10,Digits%2);
   if (Digits<=2) pipvalue=0.1; //=GOLD & Indices
   return(0);
}

int start()
{
   int counted = IndicatorCounted();
   if (counted < 0) return(-1);
   int limit = Bars-counted-1;
   if (limit > MaxBars) limit=MaxBars;
   
   int i=limit;
   while(i>=0)
   {
      int n=period * 1.5; //round to integer
      double sum = (Close[i]-Close[i+n]) / Close[i+n]; n--;
      for(int x=period-1; x>0; x--) { sum += (Close[i+x]-Close[i+n])/Close[i+n]; n--; }
      buffer1[i] = sum / period / pipvalue;
      i--;
   }
   
   return(0);
}
