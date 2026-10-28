//+------------------------------------------------------------------+
//|                                                   PeriodNext.mq5 |
//|                                                        J.S. 2013 |
//|                                     http://www.eselstreckdich.de |
//+------------------------------------------------------------------+
#property copyright "J.S. 2013"
#property link      "http://www.eselstreckdich.de"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   long id=ChartFirst();
   ENUM_TIMEFRAMES period=ChartPeriod(id);
   if(period<PERIOD_M5) period=PERIOD_M5;
   else
      if(period<PERIOD_M15) period=PERIOD_M15;
   else
      if(period<PERIOD_M30) period=PERIOD_M30;
   else
      if(period<PERIOD_H1) period=PERIOD_H1;
   else
      if(period<PERIOD_H4) period=PERIOD_H4;
   else
      if(period<PERIOD_D1) period=PERIOD_D1;
   else
      if(period<PERIOD_W1) period=PERIOD_W1;
   else
      period=PERIOD_M5;

   while(id!=-1)
     {
      string symbol=ChartSymbol(id);
      ChartSetSymbolPeriod(id,symbol,period);
      id=ChartNext(id);
     }
  }
//+------------------------------------------------------------------+
