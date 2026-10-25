//+------------------------------------------------------------------+
//|                               Without shadow color histogram.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_plots   1 
//--- plot Histogram 
#property indicator_label1  "Shadow" 
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//--- 
#property indicator_color1  clrNONE,clrLawnGreen,clrLightSkyBlue
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  2 
//--- buffer of values 
double         HistogramBuffer[];
double         HistogramColors[];
//---
int m_digits=-1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_digits=Digits();
   if(m_digits<0)
      m_digits=0;
//--- indicator buffers mapping 
   SetIndexBuffer(0,HistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HistogramColors,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetDouble(INDICATOR_MINIMUM,0.1);
   IndicatorSetDouble(INDICATOR_MAXIMUM,2.1);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- set accuracy 
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---
   return(INIT_SUCCEEDED);
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
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
//---
   for(int i=limit;i<rates_total;i++)
     {
      if(i==0)
        {
         HistogramBuffer[0]=0.0;
         HistogramColors[0]=0;
         continue;
        }
      double count=0.0;
      HistogramBuffer[i-1]=0.0;
      HistogramColors[i-1]=0;
      if(CompareDoubles(high[i-1],open[i-1]) || CompareDoubles(high[i-1],close[i-1]))
         count=count+1.0;
      if(CompareDoubles(low[i-1],open[i-1]) || CompareDoubles(low[i-1],close[i-1]))
         count=count+1.0;
      //---
      if(count==1.0)
        {
         HistogramBuffer[i-1]=1.0;
         HistogramColors[i-1]=1;
         int d=0;
        }
      else if(count==2.0)
        {
         HistogramBuffer[i-1]=2.0;
         HistogramColors[i-1]=2;
         int d=0;
        }
     }
   HistogramBuffer[rates_total-1]=0.0;
   HistogramColors[rates_total-1]=0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,m_digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
