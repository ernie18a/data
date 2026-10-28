//+------------------------------------------------------------------+
//|                                 Support-Resistance Indicator.mq4 |
//|                                       Copyright © 2007, Tinytjan |
//|                                                 tinytjan@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Tinytjan"
#property link      "tinytjan@mail.ru"

#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Orange

#include "../libraries/OneSideGaussian.mq4"

extern int WindowSize = 20;

//---- buffers
double Resistance[];
double Support[];
double Average[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   BuffersInit();

   IndicatorShortName("-=<Gaussian>=-");

   SetIndexBuffer(0, Resistance);
   SetIndexBuffer(1, Support);
   SetIndexBuffer(2, Average);

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
      
      Support[i] = Min;
      Resistance[i] = Max;
      Average[i] = (Max + Min)/2;
      
      Print (Support[i], "  ", Resistance[i], "  ", Average[i]);
   }
   return(0);
}
//+------------------------------------------------------------------+