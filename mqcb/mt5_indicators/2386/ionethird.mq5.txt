//+------------------------------------------------------------------+
//|                                                   i-OneThird.mq5 |
//|                                          Copyright © 2007, RickD | 
//|                                                   www.e2e-fx.net | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, RickD"
#property link "www.e2e-fx.net"
#property description "Bullish and bearish patterns in the style of HeikenAshi"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 5
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator drawing parameters                 |
//+----------------------------------------------+
//--- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
//---- the following colors are used as the indicator colors
#property indicator_color1  clrTeal,clrDeepPink
//--- displaying the indicator label
#property indicator_label1  "open;high;low;close"
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   min_rates_total=1;
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="i-OneThird";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtLowBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtOpenBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      //---
      double third=(high[bar]-low[bar])/3;
      //---
      if(close[bar]>high[bar]-third)
        {
         ExtLowBuffer[bar]=low[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtOpenBuffer[bar]=MathMin(open[bar],close[bar]);
         ExtCloseBuffer[bar]=MathMax(open[bar],close[bar]);
        }
      //---
      if(close[bar]<low[bar]+third)
        {
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtOpenBuffer[bar]=MathMax(open[bar],close[bar]);
         ExtCloseBuffer[bar]=MathMin(open[bar],close[bar]);
        }
      //--- candlesticks coloring
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
