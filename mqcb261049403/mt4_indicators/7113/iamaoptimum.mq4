//+------------------------------------------------------------------+
//|                                               i-AMA-Optimum.mq4  |
//|                                     Copyright © 2005-2007 RickD  |
//+------------------------------------------------------------------+
#property copyright "© 2005-2007 RickD"
#property link      "www.e2e-fx.net"
//----
#define major   1
#define minor   0
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Orange
#property indicator_color2  Black
#property indicator_width1  2
//---- indicator parameters
extern int P = 1000;
extern double Fast = 2; 
extern double Slow = 10;
//---- indicator buffers
double buf1[];
double buf2[];
//----
double SlowSC, FastSC;
double AMA;
double Noise, Signal;
double ER, SSC;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() 
  {  
//---- вычисляем сглаживающие константы
   SlowSC = 2 / (1 + Slow);
   FastSC = 2 / (1 + Fast);
//----       
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 158);      
// IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1);
   SetIndexBuffer(0, buf1);
   SetIndexBuffer(1, buf2);   
//----   
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
//----   
   IndicatorShortName("AMA("+ P + ", " + Fast + ", " + Slow + ")");      
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int start() 
  {
   if(Bars < P) 
       return (0);
   int counted = IndicatorCounted();
//   if(Symbol() == "EURUSD") 
//       Print("C= ", counted, " B= ", Bars);  
   if(counted < 0) 
       return (-1);
   if(counted == Bars-1) 
       return (0);
   int limit = 0;
   if(counted == 0 || counted > Bars-2) 
     {
       Noise = 0;
       limit = Bars - 2;
     }
//----   
   for(int i = limit; i >= 0; i--) 
     {
       if(limit > 0 && i > limit - P) 
         {
           Noise += MathAbs(Open[i] - Open[i+1]);
           buf1[i] = 0;
           buf2[i] = 0;
           continue;
         }
       Signal = MathAbs(Open[i] - Open[i+P]);
       Noise += MathAbs(Open[i] - Open[i+1]);
       Noise -= MathAbs(Open[i+P] - Open[i+1+P]);    
   	   //----
   	   ER = 1;
   	   if(Noise > 0) 
   	       ER = Signal / Noise;
   	   SSC = MathPow(SlowSC + ER*(FastSC - SlowSC), 2);
   	   //----
       if(i == limit - P)
           AMA = Open[i];
       else
           AMA = SSC*Open[i] + (1 - SSC)*buf1[i+1];
       buf1[i] = AMA;
       buf2[i] = AMA;
     }
   return (0);
  }
//+------------------------------------------------------------------+

