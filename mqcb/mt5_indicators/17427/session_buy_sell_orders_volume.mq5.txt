//+------------------------------------------------------------------+
//|                               Session Buy Sell Orders Volume.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.003"
#property description "Session Orders Volume: Open and Sell"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Max
#property indicator_label1  "Max"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Сurrent
#property indicator_label2  "Min"
#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- indicator buffers
double         BufferMaxUp[];
double         BufferMaxDown[];
double         BufferMinUp[];
double         BufferMinDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print(__FUNCTION__);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMaxUp,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMaxDown,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMinUp,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMinDown,INDICATOR_DATA);
   ArraySetAsSeries(BufferMaxUp,true);
   ArraySetAsSeries(BufferMaxDown,true);
   ArraySetAsSeries(BufferMinUp,true);
   ArraySetAsSeries(BufferMinDown,true);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
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
   double sov_buy=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_BUY_ORDERS_VOLUME);
   double sov_sell=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_SELL_ORDERS_VOLUME);
   double difference=sov_buy-sov_sell;
//---
   int limit=rates_total-prev_calculated;
   for(int i=0;i<limit;i++) // в случае когда prev_calculated==0 или когда limit>1
     {
      BufferMaxUp[i]=difference;
      BufferMaxDown[i]=difference;
      BufferMinUp[i]=difference;
      BufferMinDown[i]=difference;
     }
//---
   if(difference>BufferMaxUp[0])
     {
      BufferMaxUp[0]=difference;
     }
   if(difference<BufferMinDown[0])
     {
      BufferMinDown[0]=difference;
     }
   BufferMaxDown[0]=BufferMinUp[0]=difference;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
