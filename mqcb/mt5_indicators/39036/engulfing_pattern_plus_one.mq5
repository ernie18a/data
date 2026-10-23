//+------------------------------------------------------------------+
//|                                   Engulfing Pattern Plus One.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot BUY
#property indicator_label1  "BUY"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SELL
#property indicator_label2  "SELL"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "Arrows"
input uchar                Inp_BUY_ArrowCode       = 116;      // Arrow 'BUY': code (font Wingdings)
input int                  Inp_BUY_ArrowShift      = 10;       // Arrow 'BUY': vertical shift in pixel
input uchar                Inp_SELL_ArrowCode      = 116;      // Arrow 'SELL': code (font Wingdings)
input int                  Inp_SELL_ArrowShift     = 10;       // Arrow 'SELL': vertical shift in pixel
//--- indicator buffers
double   BUYBuffer[];
double   SELLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BUYBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SELLBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,Inp_BUY_ArrowCode);
   PlotIndexSetInteger(1,PLOT_ARROW,Inp_SELL_ArrowCode);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,Inp_BUY_ArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-Inp_SELL_ArrowShift);
//--- an empty value for plotting, for which there is no drawing
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
   if(rates_total<3)
      return(0);
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=2;
      for(int i=0; i<limit; i++)
        {
         BUYBuffer[i]=0.0;
         SELLBuffer[i]=0.0;
        }
     }
   for(int i=limit; i<rates_total; i++)
     {
      BUYBuffer[i]=0.0;
      SELLBuffer[i]=0.0;
      if(high[i]>=high[i-1] && high[i]>=high[i-2])
         if(low[i]<=low[i-1] && low[i]<=low[i-2])
           {
            if(open[i]<close[i])
               BUYBuffer[i]=low[i];
            else
               SELLBuffer[i]=high[i];
           }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
