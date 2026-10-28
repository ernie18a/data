//+------------------------------------------------------------------+
//|                                      Candles without shadows.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot ColorCandles
#property indicator_label1  "ColorCandles"
#property indicator_type1   DRAW_COLOR_CANDLES
//--- Define 8 colors for coloring candlesticks (they are stored in the special array)
#property indicator_color1  clrLavender,clrLimeGreen,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
//---
//--- Indicator buffers
double   BufferOpen[];
double   BufferHigh[];
double   BufferLow[];
double   BufferClose[];
double   BufferColors[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- An empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- The name of the symbol, for which the bars are drawn
   string symbol=Symbol();
//--- Set the display of the symbol
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_COLOR_CANDLES("+symbol+")");
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
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      BufferOpen[i]=open[i];
      BufferClose[i]=close[i];
      if(open[i]<close[i])
        {
         BufferHigh[i]=close[i];
         BufferLow[i]=open[i];
         BufferColors[i]=0.0;
        }
      else
        {
         BufferHigh[i]=open[i];
         BufferLow[i]=close[i];
         if(open[i]>close[i])
           {
            BufferColors[i]=1.0;
           }
         else
            BufferColors[i]=2.0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
