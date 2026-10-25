//+------------------------------------------------------------------+
//|                                                            5.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/ru/users/alex2356"
#property version   "1.00"
#property indicator_plots 0
#property indicator_chart_window

#include <CustomGUI\CustomGUI.mqh>
//+------------------------------------------------------------------+
//|  Входные параметры индикатора                                    |
//+------------------------------------------------------------------+
input int               period=10;                                //ADX Period
input double            maxval=50;                                //Max value
//---
CPyramid ind1;
CCircleSimple ind2;
int InpInd_Handle;
double adx[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора
   InpInd_Handle=iADX(Symbol(),PERIOD_CURRENT,period);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print("Failed to get indicator handle");
      return(INIT_FAILED);
     }
   ArraySetAsSeries(adx,true);
//---
   ind1.Size(250);
   ind1.Create("pyramid",200,0);
//---
   ind2.FontSize(ind1.FontSize());
   ind2.LabelSize(ind1.FontSize());
   ind2.Label("ADX");
   ind2.Radius(30);
   ind2.Create("label",ind1.X()-ind1.Size()/3,ind1.Y()-ind1.Size()/4);
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
   if(CopyBuffer(InpInd_Handle,0,0,2,adx)<=0)
      return(0);
   ind1.NewValue(adx[0],maxval);
   ind2.NewValue(adx[0]);
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
   ChartRedraw();
  }
//+------------------------------------------------------------------+
