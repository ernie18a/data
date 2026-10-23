//+------------------------------------------------------------------+
//|                                            OnNewBarCalculate.mq5 |
//|                                            Copyright 2010, Lizar |
//|                                                    Lizar@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Lizar"
#property link      "Lizar@mail.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#include <OnNewBarCalculate.mqh> // here is the secret of call of OnNewBarCalculate() function
//+------------------------------------------------------------------+
//| The "new bar" event handler for the indicator                    |
//+------------------------------------------------------------------+
int OnNewBarCalculate(const int rates_total,
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
//--- here you can write the code, similar to OnCalculate();
//--- but this function will be called only if a new bar has appeared (not at every tick)

   PrintFormat("Новый бар: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
