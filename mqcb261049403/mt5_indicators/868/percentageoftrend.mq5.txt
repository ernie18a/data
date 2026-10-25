//+------------------------------------------------------------------+
//|                                            PercentageofTrend.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum -1.00
#property indicator_maximum 1.00
#property indicator_level1 0.20
#property indicator_level2 0.80
#property indicator_level3 -0.20
#property indicator_level4 -0.80

#property indicator_buffers 3
#property indicator_plots   3
//--- plot Period1
#property indicator_label1  "Period1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Period2
#property indicator_label2  "Period2"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int InpPeriod1=20;  // Period1
input int InpPeriod2=100; // Period2
//--- indicator buffers
double         Period1Buffer[];
double         Period2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,Period1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Period2Buffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int max=MathMax(InpPeriod1,InpPeriod2);
   int pos;
   int bars=Bars(_Symbol,_Period);
   if(bars<max) return(0);
   if(prev_calculated>max) pos=prev_calculated;
   else pos = max;
   for(int i=pos; i<rates_total;i++)
     {
      double   HighValue1= 0;
      double   LowValue1 = 0;

      for(int cnt=i-InpPeriod1+1; cnt<i+1;cnt++)
        {
         if(high[cnt]>HighValue1) HighValue1=high[cnt];
        }

      for(int cnt=i-InpPeriod1+1; cnt<i+1;cnt++)
        {
         if(cnt==i-InpPeriod1+1) LowValue1=low[cnt];
         if(low[cnt]<LowValue1) LowValue1=low[cnt];
        }

      double   HighValue2= 0;
      double   LowValue2 = 0;

      for(int cnt=i-InpPeriod2+1; cnt<i+1;cnt++)
        {
         if(high[cnt]>HighValue2) HighValue2=high[cnt];
        }

      for(int cnt=i-InpPeriod2+1; cnt<i+1;cnt++)
        {
         if(cnt==i-InpPeriod2+1) LowValue2=low[cnt];
         if(low[cnt]<LowValue2) LowValue2=low[cnt];
        }

      Period1Buffer[i] = (close[i] - LowValue1) / (HighValue1 - LowValue1);
      Period2Buffer[i] = (close[i] - LowValue2)*-1 / (HighValue2 - LowValue2);

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
