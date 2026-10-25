//+------------------------------------------------------------------+
//|                                                    BrokerDST.mq5 |
//|                                        Copyright © 2026, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.500"
#property description "Detects whether the broker server follows the US, UK, AU, or no daylight saving time (DST) schedule."

#include "DetectBrokerDST.mqh"

//+------------------------------------------------------------------+
//| Script entry point.                                              |
//+------------------------------------------------------------------+
void OnStart()
  {
   const int offset = (int)(TimeTradeServer() - TimeGMT());

   Print("Server : ", AccountInfoString(ACCOUNT_SERVER));
   Print("Time   : ", TimeTradeServer());
   PrintFormat("Offset : GMT%+g", offset / 3600.0);

   ENUM_BROKER_DST schedule = DetectBrokerDST();

   switch(schedule)
     {
      case DST_ERROR:
         Print("DetectBrokerDST() failed.");
         break;

      case DST_AU:
         Print("DST_AU : server dst begins on the first Sunday of October (+1) and ends on the first Sunday of April (-1)");
         break;

      case DST_UK:
         Print("DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)");
         break;

      case DST_US:
         Print("DST_US : server dst begins on the second Sunday of March (+1) and ends on the first Sunday of November (-1)");
         break;

      case DST_NONE:
         PrintFormat("DST_NONE : server offset is GMT%+g year-round", offset / 3600.0);
         break;
     }

  }
//+------------------------------------------------------------------+

// sample output on different fx brokers

/*
 Server : ICMarketsSC-Demo
 Time   : 2024.03.30 02:36:09
 Offset : GMT+3
 DST_US : server dst begins on the second Sunday of March (+1) and ends on the first Sunday of November (-1)

 Server : Exness-MT5Trial
 Time   : 2024.03.29 23:37:05
 Offset : GMT+0
 DST_NONE

 Server : OctaFX-Demo
 Time   : 2024.03.30 01:37:14
 Offset : GMT+2
 DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)

 Server : AdmiralsSC-Demo
 Time   : 2024.03.30 01:37:52
 Offset : GMT+2
 DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)

 Server : RannForex-Server
 Time   : 2024.03.30 01:37:32
 Offset : GMT+2
 DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)

 Server : XMGlobal-MT5 7
 Time   : 2024.03.30 02:48:16
 Offset : GMT+2
 DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)

 Server : FxPro-MT5
 Time   : 2024.04.12 04:00:12
 Offset : GMT+3
 DST_UK : server dst begins on the last Sunday of March (+1) and ends on the last Sunday of October (-1)

 Server : FXOpen-MT5
 Time   : 2024.04.12 04:01:11
 Offset : GMT+3
 DST_US : server dst begins on the second Sunday of March (+1) and ends on the first Sunday of November (-1)

 Server : Tickmill-Demo
 Time   : 2024.04.12 04:02:13
 Offset : GMT+3
 DST_US : server dst begins on the second Sunday of March (+1) and ends on the first Sunday of November (-1)

 Server : Trading.comMarkets-MT5
 Time   : 2024.04.13 20:58:36
 Offset : GMT-4
 DST_US : server dst begins on the second Sunday of March (+1) and ends on the first Sunday of November (-1)
*/
