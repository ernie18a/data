//+------------------------------------------------------------------+
//|                                              CustomIndicator.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_plots 0
#property indicator_chart_window

#include <CustomGUI\CustomGUI.mqh>
//---
CPetal ind1,ind2,ind3,ind4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int b=2;
//---   
   ind1.BgColor(C'230,80,80');
   ind1.Orientation(BOTHLEFT);
   ind1.Create("petal1",200-b,100-b);

   ind2.BgColor(C'35,170,190');
   ind2.Orientation(BOTHRIGHT);
   ind2.Create("petal2",300+b,100-b);

   ind3.BgColor(C'245,155,70');
   ind3.Orientation(BOTHRIGHT);
   ind3.Create("petal3",200-b,200+b);

   ind4.BgColor(C'90,200,130');
   ind4.Orientation(BOTHLEFT);
   ind4.Create("petal4",300+b,200+b);
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

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ind1.Delete();
   ind2.Delete();
   ind3.Delete();
   ind4.Delete();
  }
//+------------------------------------------------------------------+