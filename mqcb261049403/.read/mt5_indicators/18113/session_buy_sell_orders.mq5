//+------------------------------------------------------------------+
//|                                      Session Buy Sell Orders.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "Number of Buy and Sell orders at the moment"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Buy
#property indicator_label1  "Buy orders"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Sell
#property indicator_label2  "Sell orders"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- indicator buffers
double         BufferBuy[];
double         BufferSell[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print(__FUNCTION__);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBuy,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSell,INDICATOR_DATA);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
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
   double sov_buy=(double)SymbolInfoInteger(Symbol(),SYMBOL_SESSION_BUY_ORDERS);
   double sov_sell=(double)SymbolInfoInteger(Symbol(),SYMBOL_SESSION_SELL_ORDERS);
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      ArrayInitialize(BufferBuy,0.0);
      ArrayInitialize(BufferSell,0.0);
      return(rates_total);
     }
   for(int i=limit;i<rates_total;i++) // в случае когда prev_calculated==0 или когда limit>1
     {
      BufferBuy[i]=sov_buy;
      BufferSell[i]=-sov_sell;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
