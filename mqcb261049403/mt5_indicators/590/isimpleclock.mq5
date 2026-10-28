//+------------------------------------------------------------------+
//|                                                 iSimpleClock.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/ru/users/integer"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

datetime BarTime=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- indicator buffers mapping
   Comment("");
//---
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

   BarTime=time[rates_total-1];
   OnTimer();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnTimer event handler                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(Period()==PERIOD_W1 || Period()==PERIOD_MN1)
     {
      return;
     }
   if(BarTime==0)
     {
      Comment("Waiting for the price change...");
      return;
     }
   datetime tc=TimeCurrent();
   datetime tf=tc-BarTime;
   datetime tt=PeriodSeconds(Period())-tf;
   if(tt<0)
     {
      Comment("Waiting for a new bar...");
      return;
     }

   Comment(TimeToString(tc,TIME_SECONDS)+" - "+
           TimeToString(tf,TIME_SECONDS)+" - "+
           TimeToString(tt,TIME_SECONDS)
           );

  }
//+------------------------------------------------------------------+
