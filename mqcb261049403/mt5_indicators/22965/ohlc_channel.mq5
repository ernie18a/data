//+------------------------------------------------------------------+
//|                                                 OHLC Channel.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot High
#property indicator_label1  "Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrChartreuse
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Low
#property indicator_label2  "Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//---
enum ENUM_PRICE
  {
   open_price     = 0,  // Open
   high_price     = 1,  // High
   low_price      = 2,  // Low
   close_price    = 3,  // Close
  };
//--- input parameters
input ENUM_PRICE  InpUp    = high_price;
input ENUM_PRICE  InpDown  = low_price;
//--- indicator buffers
double            HighBuffer[];
double            LowBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowBuffer,INDICATOR_DATA);
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
//--- by default in the MQL5 indicator on the chart: 
//    left bar                | right bar
//    D'1980.07.19 12:30:27'  | D'2018.07.19 12:30:27'
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit;i<rates_total;i++)
     {
      switch(InpUp)
        {
         case open_price:
            HighBuffer[i]=open[i];
            break;
         case high_price:
            HighBuffer[i]=high[i];
            break;
         case low_price:
            HighBuffer[i]=low[i];
            break;
         case close_price:
            HighBuffer[i]=close[i];
            break;
        }
      switch(InpDown)
        {
         case open_price:
            LowBuffer[i]=open[i];
            break;
         case high_price:
            LowBuffer[i]=high[i];
            break;
         case low_price:
            LowBuffer[i]=low[i];
            break;
         case close_price:
            LowBuffer[i]=close[i];
            break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
