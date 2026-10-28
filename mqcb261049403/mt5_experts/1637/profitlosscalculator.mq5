//+------------------------------------------------------------------+
//|                                         ProfitLossCalculator.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Profit Loss Calculator"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "ProfitLossCalculator.mqh"
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CProfitLossCalculator calculator;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   ResetLastError();
   if ( !calculator.Create(0, "Profit Loss Calculator", 0, 20, 20, 366, 166) ) {
      Print("Creating calculator failed. Error #", GetLastError());
      return(-1);
   }
   calculator.Run();
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   calculator.Destroy(reason);
//---   
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
   calculator.ChartEvent(id, lparam, dparam, sparam);
   calculator.OnEventLine(id, lparam, dparam, sparam);
//---   
}
//+------------------------------------------------------------------+
