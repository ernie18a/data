//+------------------------------------------------------------------+
//|                                                 allclosetest.mq5 |
//|                               Copyright 2023, RootCauseMarketing |
//|                      https://www.mql5.com/en/users/mt4kabukimono |
//+------------------------------------------------------------------+
#property copyright   "Copyright, Feel free to copy, distribute, and modify this work."
#property link        "https://www.mql5.com/en/users/mt4kabukimono"
#property description "This is a sample program for async/sync all close."

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   ulong st = GetMicrosecondCount(); // for monitor

   CTrade sTrade;
   sTrade.SetAsyncMode(true); // true:Async, false:Sync

   for(int cnt = PositionsTotal()-1; cnt >= 0 && !IsStopped(); cnt--)
     {
      ulong wTicket = PositionGetTicket(cnt);
      if(PositionSelectByTicket(wTicket))
        {
         //Close process
         sTrade.PositionClose(wTicket);
         uint code = sTrade.ResultRetcode();
         Print(IntegerToString(code)); // 10008 TRADE_RETCODE_PLACED : OK
        }
     }

//Monitor status until all positions are closed. or Timeout.
   for(int i=0; i<100; i++)
     {
      Print(IntegerToString(GetMicrosecondCount()-st) +"micro "+ IntegerToString(PositionsTotal()));
      if(PositionsTotal()<=0)
        {
         break;
        }
      Sleep(100);
     }
  }
//+------------------------------------------------------------------+
