//+------------------------------------------------------------------+
//|                                                 MoveStopLoss.mq5 |
//|                        Copyright 2026, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Wamek TrailingStop EA-2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property strict
#property description "<< Moves the stoploss along with ask/bid at a>>"
#property description "<< predetermined distance or ATR-based distance >>"

#include <Trade\Trade.mqh>

input bool   AllowAutoTrade    = false; // true = ATR-based trailing, false = fixed points
input int    InpDistance2Trail = 500;   // fixed trailing distance in points
input int    AtrPeriod         = 20;    // ATR period
input double AtrMultiplier     = 2.0;   // ATR multiplier

CTrade trade;
int    atr_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Alert("Enable AutoTrading Please");
      return(INIT_FAILED);
   }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Alert("Algo Trading is disabled for this EA");
      return(INIT_FAILED);
   }

   if(AtrPeriod < 1)
   {
      Alert("AtrPeriod must be at least 1");
      return(INIT_PARAMETERS_INCORRECT);
   }

   if(AtrMultiplier <= 0.0)
   {
      Alert("AtrMultiplier must be greater than 0");
      return(INIT_PARAMETERS_INCORRECT);
   }

   atr_handle = iATR(_Symbol, PERIOD_CURRENT, AtrPeriod);

   if(atr_handle == INVALID_HANDLE)
   {
      PrintFormat("Failed to create ATR handle. Error %d", GetLastError());
      return(INIT_FAILED);
   }

   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(10);
   trade.SetAsyncMode(false);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(atr_handle);
      atr_handle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   MoveStopLoss();
}

//+------------------------------------------------------------------+
//| Determine distance to move stoploss                              |
//+------------------------------------------------------------------+
double GetTrailingDistance()
{
   if(!AllowAutoTrade)
      return NormalizeDouble(InpDistance2Trail * _Point, _Digits);

   double atr_buf[];

   if(CopyBuffer(atr_handle, 0, 0, 1, atr_buf) <= 0)
   {
      Print("ATR copy failed. Falling back to fixed distance.");
      return NormalizeDouble(InpDistance2Trail * _Point, _Digits);
   }

   double atr = atr_buf[0];

   if(atr <= 0.0)
   {
      Print("ATR invalid. Falling back to fixed distance.");
      return NormalizeDouble(InpDistance2Trail * _Point, _Digits);
   }

   return NormalizeDouble(AtrMultiplier * atr, _Digits);
}

//+------------------------------------------------------------------+
//| Prevent the stop-loss from moving backward                       |
//+------------------------------------------------------------------+
bool IsNewStopBetter(const long position_type, const double new_sl)
{
   double current_sl = PositionGetDouble(POSITION_SL);

   if(position_type == POSITION_TYPE_BUY)
      return(current_sl == 0.0 || new_sl > current_sl);

   if(position_type == POSITION_TYPE_SELL)
      return(current_sl == 0.0 || new_sl < current_sl);

   return(false);
}

//+------------------------------------------------------------------+
//| Moves stoploss to desired distance                               |
//+------------------------------------------------------------------+
void MoveStopLoss()
{
   double trail_distance = GetTrailingDistance();

   if(trail_distance <= 0.0)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      long type = PositionGetInteger(POSITION_TYPE);

      if(type != POSITION_TYPE_BUY && type != POSITION_TYPE_SELL)
         continue;

      MqlTick tick;

      if(!SymbolInfoTick(_Symbol, tick))
         continue;

      double open_price  = PositionGetDouble(POSITION_PRICE_OPEN); // <-- fixed
      double take_profit = PositionGetDouble(POSITION_TP);

      if(type == POSITION_TYPE_BUY)
      {
         if(tick.bid <= open_price)
            continue;

         double new_sl = NormalizeDouble(tick.bid - trail_distance, _Digits);

         if(new_sl <= 0.0)
            continue;

         if(!IsNewStopBetter(POSITION_TYPE_BUY, new_sl))
            continue;

         if(!IsStopLossAllowed(POSITION_TYPE_BUY, new_sl, ticket))
            continue;

         if(!trade.PositionModify(ticket, new_sl, take_profit))
         {
            PrintFormat("PositionModify failed for BUY ticket %I64u. Retcode %u: %s",
                        ticket,
                        trade.ResultRetcode(),
                        trade.ResultRetcodeDescription());
         }
      }
      else if(type == POSITION_TYPE_SELL)
      {
         if(tick.ask >= open_price)
            continue;

         double new_sl = NormalizeDouble(tick.ask + trail_distance, _Digits);

         if(new_sl <= 0.0)
            continue;

         if(!IsNewStopBetter(POSITION_TYPE_SELL, new_sl))
            continue;

         if(!IsStopLossAllowed(POSITION_TYPE_SELL, new_sl, ticket))
            continue;

         if(!trade.PositionModify(ticket, new_sl, take_profit))
         {
            PrintFormat("PositionModify failed for SELL ticket %I64u. Retcode %u: %s",
                        ticket,
                        trade.ResultRetcode(),
                        trade.ResultRetcodeDescription());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Verify broker distance requirements                              |
//+------------------------------------------------------------------+
bool IsStopLossAllowed(const long position_type,
                       const double new_sl,
                       const ulong ticket)
{
   int stops_level  = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   int minimum_distance_points = (int)MathMax(stops_level, freeze_level);
   double minimum_distance = minimum_distance_points * _Point;

   MqlTick tick;

   if(!SymbolInfoTick(_Symbol, tick))
      return(false);

   if(position_type == POSITION_TYPE_BUY &&
      (tick.bid - new_sl) < minimum_distance)
   {
      PrintFormat(
         "Position %I64u skipped: Buy Stop Loss is too close to Bid.",
         ticket
      );
      return(false);
   }

   if(position_type == POSITION_TYPE_SELL &&
      (new_sl - tick.ask) < minimum_distance)
   {
      PrintFormat(
         "Position %I64u skipped: Sell Stop Loss is too close to Ask.",
         ticket
      );
      return(false);
   }

   return(true);
}
//+------------------------------------------------------------------+