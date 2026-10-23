//+------------------------------------------------------------------+
//|                                                      AeTypes.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Shared vocabulary for the Alpha Engine port.                     |
//|                                                                  |
//|  This is a faithful translation of Golub, Glattfelder & Olsen,   |
//|  "The Alpha Engine: Designing an Automated Trading Algorithm"    |
//|  (SSRN 2951348), following the author's reference Java in        |
//|  AlphaEngine/LimitOrders. The engine is a counter-trending       |
//|  coastline trader: it opens into overshoots, cascades (adds) as  |
//|  price runs against it, de-cascades (trims at a profit) as price |
//|  reverts, and closes the whole position once its return reaches  |
//|  the trader's own directional-change threshold delta.            |
//|                                                                  |
//|  Prices are bid/ask pairs; a limit buy is considered filled when |
//|  the ask trades through its level, a limit sell when the bid     |
//|  does. Everything the classes exchange - a tick, an intrinsic    |
//|  event code - lives here so the runner, the liquidity indicator, |
//|  the orders and the trader all speak the same language.          |
//+------------------------------------------------------------------+

//--- intrinsic-event codes returned by a runner, matching the sign
//--- convention of the reference: directional changes are +/-1, the
//--- overshoot ticks that punctuate a trend are +/-2, 0 is a quiet
//--- update. Sign is the direction: up events positive, down negative.
#define AE_EVENT_NONE     0
#define AE_EVENT_DC_UP    1
#define AE_EVENT_DC_DOWN (-1)
#define AE_EVENT_OS_UP    2
#define AE_EVENT_OS_DOWN (-2)

//+------------------------------------------------------------------+
//| One bid/ask quote with its time stamp.                           |
//|                                                                  |
//|  The reference carries a full Price object so a filled order can |
//|  remember the quote it was opened against; this mirrors it with  |
//|  the fields the engine actually reads.                           |
//+------------------------------------------------------------------+
struct SAeTick
  {
   double            bid;
   double            ask;
   datetime          time;

   double            Mid(void) const { return 0.5*(bid+ask); }
  };

//+------------------------------------------------------------------+
//| Build a tick in one expression.                                  |
//+------------------------------------------------------------------+
SAeTick AeTick(const double bid,const double ask,const datetime time)
  {
   SAeTick t;
   t.bid =bid;
   t.ask =ask;
   t.time=time;
   return t;
  }
//+------------------------------------------------------------------+
