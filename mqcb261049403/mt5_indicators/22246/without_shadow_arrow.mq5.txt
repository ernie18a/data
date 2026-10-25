//+------------------------------------------------------------------+
//|                                         Without shadow arrow.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window 
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Histogram 
#property indicator_label1  "Shadow high"
#property indicator_type1   DRAW_ARROW
#property indicator_label2  "Shadow low"
#property indicator_type2   DRAW_ARROW
//--- 
#property indicator_color1  clrLawnGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_color2  clrLightSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters 
input ushort   code        = 174;   // Symbol code to draw Shadow
input int      arrow_shift = 9;     // Arrow shift
//--- buffer of values 
double         ArrowsBufferHigh[];
double         ArrowsBufferLow[];
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
   SetIndexBuffer(0,ArrowsBufferHigh,INDICATOR_DATA);
   SetIndexBuffer(1,ArrowsBufferLow,INDICATOR_DATA);
//--- Define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,code);
   PlotIndexSetInteger(1,PLOT_ARROW,code);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-arrow_shift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,arrow_shift);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
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
         ArrowsBufferHigh[0]=0.0;
         ArrowsBufferLow[0]=0.0;
         continue;
        }
      if(CompareDoubles(high[i-1],open[i-1]) || CompareDoubles(high[i-1],close[i-1]))
         ArrowsBufferHigh[i-1]=high[i-1];
      else
         ArrowsBufferHigh[i-1]=0.0;
      //---
      if(CompareDoubles(low[i-1],open[i-1]) || CompareDoubles(low[i-1],close[i-1]))
         ArrowsBufferLow[i-1]=low[i-1];
      else
         ArrowsBufferLow[i-1]=0.0;
     }
   ArrowsBufferHigh[rates_total-1]=0.0;
   ArrowsBufferLow[rates_total-1]=0.0;
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
