//+------------------------------------------------------------------+
//|                                            SR-Rate Indicator.mq4 |
//|                                       Copyright © 2007, Tinytjan |
//|                                                 tinytjan@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Tinytjan"
#property link      "tinytjan@mail.ru"

#property indicator_separate_window
#property indicator_buffers 1

#property indicator_color1 Red

#include "../libraries/OneSideGaussian.mq4"

extern int WindowSize = 20;

//---- buffers
double Rate[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   BuffersInit();

   IndicatorShortName("-=<SR-Rate>=-");

   SetIndexBuffer(0, Rate);

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int ToCount = Bars - IndicatorCounted();
   
   for (int i = ToCount - 1; i >= 0; i--)
   {
      double Max = 0;
      double Min = 999999999;

      for (int j = i; j < i + WindowSize; j++)
      {
         double low = Smooth_5(PRICE_LOW, j);
         if (low < Min) Min = low;
         
         double high = Smooth_5(PRICE_HIGH, j);
         if (high > Max) Max = high;
      }
      
      if (Min == 0) Rate[i] = 0;
      else Rate[i] = (Smooth_5(PRICE_WEIGHTED, i) - Min)/(Max - Min);
   }
   return(0);
}
//+------------------------------------------------------------------+