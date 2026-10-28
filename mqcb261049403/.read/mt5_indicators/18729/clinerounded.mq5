//+------------------------------------------------------------------+
//|                                                     Example1.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_plots 0
#property indicator_chart_window

#include <CustomGUI\CustomGUI.mqh>
//---
CLineRounded ind1,ind2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ind1.XSizeInd(350);
   ind1.YSizeInd(30);
   ind1.Create("line1",300,100);
//---
   ind2.XSizeInd(350);
   ind2.YSizeInd(30);
   ind2.ScaleColor(clrFireBrick);
   ind2.Create("line2",300,150);
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
   ind1.NewValue(50,100,2);
   ind2.NewValue(50,200,2);
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
  }
//+------------------------------------------------------------------+