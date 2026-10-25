//+------------------------------------------------------------------+
//|                                                   PivotPoint.mq5 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrDeepSkyBlue

double PPBuffer[];
int hLine;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, PPBuffer);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   hLine = ObjectCreate(0, "PivotPointLine", OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, "PivotPointLine", OBJPROP_COLOR, clrGold);
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
   if(rates_total < 2) return(0);

   double highPrice = high[rates_total - 2];
   double lowPrice = low[rates_total - 2];
   double closePrice = close[rates_total - 12];

   double PP = (highPrice + lowPrice + closePrice) / 3.0;

   for(int i = prev_calculated; i < rates_total; i++)
     {
      PPBuffer[i] = PP;
     }

   ObjectSetDouble(0, "PivotPointLine", OBJPROP_PRICE, PP);

   return(rates_total);
  }
//+------------------------------------------------------------------+
