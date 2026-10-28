//+------------------------------------------------------------------+
//|                                              CustomIndicator.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_plots 0
#property indicator_chart_window

#include <\CustomGUI\CustomGUI.mqh>
//---
CHexagon ind1,ind2,ind3,ind4,ind5,ind6,ind7,ind8,ind9,ind10,ind11,ind12,ind13,ind14;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---   
   ind1.BgColor(clrWhite);
   ind1.Size(110);
   ind1.Create("hex1",300,200);
   ind2.BgColor(C'60,170,220');
   ind2.Create("hex2",300,200);
//---
   ind3.BgColor(clrWhite);
   ind3.Size(110);
   ind3.Create("hex3",300,80);
   ind4.BgColor(C'230,80,25');
   ind4.Create("hex4",300,80);
//---
   ind5.BgColor(clrWhite);
   ind5.Size(110);
   ind5.Create("hex5",300,320);
   ind6.BgColor(C'150,190,15');
   ind6.Create("hex6",300,320);
//---
   ind7.BgColor(clrWhite);
   ind7.Size(110);
   ind7.Create("hex7",180,140);
   ind8.BgColor(C'10,115,185');
   ind8.Create("hex8",180,140);
//---
   ind9.BgColor(clrWhite);
   ind9.Size(110);
   ind9.Create("hex9",420,140);
   ind10.BgColor(C'20,150,150');
   ind10.Create("hex10",420,140);
//---
   ind11.BgColor(clrWhite);
   ind11.Size(110);
   ind11.Create("hex11",420,280);
   ind12.BgColor(C'225,0,80');
   ind12.Create("hex12",420,280);
//---
   ind13.BgColor(clrWhite);
   ind13.Size(110);
   ind13.Create("hex13",180,280);
   ind14.BgColor(C'240,145,5');
   ind14.Create("hex14",180,280);
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
   ind5.Delete();
   ind6.Delete();
   ind7.Delete();
   ind8.Delete();
   ind9.Delete();
   ind10.Delete();
   ind11.Delete();
   ind12.Delete();
   ind13.Delete();
   ind14.Delete();
  }
//+------------------------------------------------------------------+
