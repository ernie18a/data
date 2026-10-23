//+------------------------------------------------------------------+
//|                                                       OsMACD.mq4 |
//|                                            Copyright © 2007, SOK |
//|                                         http://SOK.LiteForex.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, SOK"
#property link      "http://sok.liteforex.net"
//----
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 LimeGreen
#property indicator_color2 Magenta
#property indicator_color3 Black
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Black
#property indicator_color7 Brown
//---- input parameters
extern int FastEMA = 12;
extern int SlowEMA = 26;
extern int SignalSMA = 9;
extern int AplyingPrice = 0;
//---- buffers
double ExtMapBuffer0[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, ExtMapBuffer0);
   SetIndexStyle(1, DRAW_LINE, 0, 2);
   SetIndexBuffer(1, ExtMapBuffer1);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, ExtMapBuffer2);
//----
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, ExtMapBuffer3);
   SetIndexStyle(4, DRAW_HISTOGRAM);
   SetIndexBuffer(4, ExtMapBuffer4);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, ExtMapBuffer5);
   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, ExtMapBuffer6);
//----
   IndicatorShortName("OsMACD_M(" + FastEMA + ", " + SlowEMA + ", " + 
                      SignalSMA + ")"); 
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2, "OsMA");
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5, "MACD");
   SetIndexLabel(6, "Signal");
//----
   SetIndexDrawBegin(0, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(1, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(3, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(4, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(6, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   double dOsMAPrev, dMACDPrev;
   int counted_bars = IndicatorCounted();
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) 
       counted_bars--;
   else
     {
       ArrayInitialize(ExtMapBuffer0, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer1, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer2, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer3, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer4, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer5, EMPTY_VALUE); 
       ArrayInitialize(ExtMapBuffer6, EMPTY_VALUE); 
     }
   limit = Bars - counted_bars;
   if(counted_bars==0) limit--;   
//---- основной цикл
   for(int i = limit-1; i >= 0; i--)
     {
       ExtMapBuffer2[i] = iOsMA(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, i);
       
       dOsMAPrev = iOsMA(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, 
                         i + 1);
       if(dOsMAPrev > ExtMapBuffer2[i] || CompareDouble(dOsMAPrev, ExtMapBuffer2[i]))
         {
           ExtMapBuffer1[i] = ExtMapBuffer2[i];
           ExtMapBuffer1[i+1] = dOsMAPrev;
         }
       else
         {          
           ExtMapBuffer0[i] = ExtMapBuffer2[i];
           ExtMapBuffer0[i+1] = dOsMAPrev;
         }
       ExtMapBuffer5[i] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, 
                                AplyingPrice, MODE_MAIN, i);
       dMACDPrev = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, 
                         MODE_MAIN, i + 1);
       if(dMACDPrev > ExtMapBuffer5[i] || CompareDouble(dMACDPrev, ExtMapBuffer5[i]))
           ExtMapBuffer4[i] = ExtMapBuffer5[i];
       else
           ExtMapBuffer3[i] = ExtMapBuffer5[i]; 
       ExtMapBuffer6[i] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, 
                                AplyingPrice, MODE_SIGNAL, i);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Функция сранения двух вещественных чисел.                        |
//+------------------------------------------------------------------+
bool CompareDouble(double Number1, double Number2)
  {
    bool Compare = NormalizeDouble(Number1 - Number2, 8) == 0;
    return(Compare);
  } 
//+------------------------------------------------------------------+