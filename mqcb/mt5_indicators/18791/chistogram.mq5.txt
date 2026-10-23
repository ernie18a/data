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

input int                  RSIPeriod1=10;        //Period of the indicator1
input int                  RSIPeriod2=14;        //Period of the indicator2
input int                  RSIPeriod3=18;        //Period of the indicator3
input ENUM_TYPE_HISTOGRAM  Type=RECTANGLE;       //Type Histogram
//---
CHistogram ind;
int InpInd_Handle1,InpInd_Handle2,InpInd_Handle3;
double rsi1[],rsi2[],rsi3[],ex[3];
string descr[3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора
   InpInd_Handle1=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod1,PRICE_CLOSE);
   InpInd_Handle2=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod2,PRICE_CLOSE);
   InpInd_Handle3=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod3,PRICE_CLOSE);
   if(InpInd_Handle1==INVALID_HANDLE ||
      InpInd_Handle2==INVALID_HANDLE ||
      InpInd_Handle3==INVALID_HANDLE
      )
     {
      Print("Failed to get indicator handle");
      return(INIT_FAILED);
     }
//---
   descr[0]="RSI("+IntegerToString(RSIPeriod1)+")";
   descr[1]="RSI("+IntegerToString(RSIPeriod2)+")";
   descr[2]="RSI("+IntegerToString(RSIPeriod3)+")";
   ind.NumGrid(10);
   ind.YMax(100);
   ind.Type(Type);
   ind.Create("rsi",350,250);
   ind.SetArrayLabel(descr);
//---
   ArraySetAsSeries(rsi1,true);
   ArraySetAsSeries(rsi2,true);
   ArraySetAsSeries(rsi3,true);
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
   if(CopyBuffer(InpInd_Handle1,0,0,1,rsi1)<=0   ||
      CopyBuffer(InpInd_Handle2,0,0,1,rsi2)<=0   ||
      CopyBuffer(InpInd_Handle3,0,0,1,rsi3)<=0
      )
      return(0);
   ex[0]=rsi1[0];
   ex[1]=rsi2[0];
   ex[2]=rsi3[0];
   ind.SetArrayValue(ex);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ind.Delete();
   ChartRedraw();
  }
//+------------------------------------------------------------------+