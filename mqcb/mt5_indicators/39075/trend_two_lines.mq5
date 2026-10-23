//+------------------------------------------------------------------+
//|                                              Trend Two Lines.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 3.0
#property indicator_buffers 4
#property indicator_plots   2
//--- plot High
#property indicator_label1  "High"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrRed,clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Low
#property indicator_label2  "Low"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrRed,clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      Input1=9;
//--- indicator buffers
double   HighBuffer[];
double   HighColors[];
double   LowBuffer[];
double   LowColors[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,LowColors,INDICATOR_COLOR_INDEX);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,174);
   PlotIndexSetInteger(1,PLOT_ARROW,174);
//--- set as an empty value 0
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
      HighBuffer[0]=0.0;
      HighColors[0]=0.0;
      LowBuffer[0]=0.0;
      LowColors[0]=0.0;
      limit=1;
     }
   for(int i=limit; i<rates_total; i++)
     {
      HighBuffer[i]=0.0;
      HighColors[i]=0.0;
      LowBuffer[i]=0.0;
      LowColors[i]=0.0;
      if(high[i]>high[i-1])
        {
         HighBuffer[i]=1.0;
         HighColors[i]=1.0;
        }
      if(high[i]<high[i-1])
        {
         HighBuffer[i]=1.0;
         HighColors[i]=0.0;
        }
      if(low[i]>low[i-1])
        {
         LowBuffer[i]=2.0;
         LowColors[i]=1.0;
        }
      if(low[i]<low[i-1])
        {
         LowBuffer[i]=2.0;
         LowColors[i]=0.0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
