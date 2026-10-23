//+------------------------------------------------------------------+
//|                                              Wamek BreakEven.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script - 2025"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property script_show_inputs
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Break-even trigger selection                                     |
//+------------------------------------------------------------------+
enum ChooseOption
  {
   UseTargetPrice = 1,
   UseProfitPoints = 2
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ChooseOption TriggerMode       = UseProfitPoints;
input int          ProfitPoints      = 100;
input double       TargetPrice       = 1.03350;
input ulong        MagicNumber       = 0;
input bool         FilterByMagic     = false;

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Trading is not allowed in the terminal. Enable AutoTrading.");
      return;
     }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      Alert("Trading is not allowed for this script.");
      return;
     }

   if(ProfitPoints < 0)
     {
      Alert("ProfitPoints cannot be negative.");
      return;
     }

   string trigger_description =
      (TriggerMode == UseTargetPrice)
      ? StringFormat("Target price: %s", DoubleToString(TargetPrice, _Digits))
      : StringFormat("Profit trigger: %d points", ProfitPoints);

   string confirmation_text = StringFormat(
      "Move eligible %s positions on %s to break-even protection?\n\n"
      "%s",
      _Symbol,
      _Symbol,
      trigger_description
   );

   int answer = MessageBox(
      confirmation_text,
      "Confirm Break-Even Modification",
      MB_YESNO | MB_ICONQUESTION
   );

   if(answer != IDYES)
     {
      Print("Operation cancelled by user.");
      return;
     }

   trade.SetTypeFillingBySymbol(_Symbol);
   MovePositionsToBreakEven();
  }

//+------------------------------------------------------------------+
//| Process all eligible positions on the current symbol             |
//+------------------------------------------------------------------+
void MovePositionsToBreakEven()
  {
   int modified_positions = 0;
   int eligible_positions = 0;

   for(int index = PositionsTotal() - 1; index >= 0; index--)
     {
      ulong ticket = PositionGetTicket(index);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if(FilterByMagic &&
         (ulong)PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue;

      eligible_positions++;

      if(ModifyPositionStopLoss(ticket))
         modified_positions++;
     }

   PrintFormat(
      "Break-even operation completed. Modified %d of %d eligible "
      "position(s) on %s.",
      modified_positions,
      eligible_positions,
      _Symbol
   );
  }

//+------------------------------------------------------------------+
//| Calculate and apply a valid Stop Loss for one position           |
//+------------------------------------------------------------------+
bool ModifyPositionStopLoss(const ulong ticket)
  {
   MqlTick tick;

   if(!SymbolInfoTick(_Symbol, tick))
     {
      PrintFormat(
         "Position %I64u skipped: unable to retrieve current prices.",
         ticket
      );
      return false;
     }

   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_tp = PositionGetDouble(POSITION_TP);

   ENUM_POSITION_TYPE position_type =
      (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   double new_sl = CalculateBreakEvenPrice(position_type, open_price);

   if(new_sl <= 0.0)
      return false;

   new_sl = NormalizePrice(new_sl);

   if(!IsTriggerReached(position_type, open_price, tick))
      return false;

   // Never move an existing Stop Loss in the unfavorable direction.
   if(position_type == POSITION_TYPE_BUY)
     {
      if(current_sl > 0.0 && new_sl <= current_sl)
         return false;
     }
   else if(position_type == POSITION_TYPE_SELL)
     {
      if(current_sl > 0.0 && new_sl >= current_sl)
         return false;
     }
   else
      return false;

   if(!IsStopLossAllowed(position_type, new_sl, tick, ticket))
      return false;

   ResetLastError();

   bool modified = trade.PositionModify(ticket,new_sl,current_tp);

   uint retcode = trade.ResultRetcode();

   if(!modified ||
      (retcode != TRADE_RETCODE_DONE &&
       retcode != TRADE_RETCODE_NO_CHANGES))
     {
      PrintFormat(
         "Position %I64u modification failed. Retcode: %u - %s. "
         "Last error: %d",
         ticket,
         retcode,
         trade.ResultRetcodeDescription(),
         GetLastError()
      );
      return false;
     }

   PrintFormat(
      "Position %I64u Stop Loss moved to %s.",
      ticket,
      DoubleToString(new_sl, _Digits)
   );

   return true;
  }

//+------------------------------------------------------------------+
//| Calculate the requested break-even protection price              |
//+------------------------------------------------------------------+
double CalculateBreakEvenPrice(const ENUM_POSITION_TYPE position_type,
                               const double open_price)
  {
   if(TriggerMode == UseTargetPrice)
      return TargetPrice;

   if(position_type == POSITION_TYPE_BUY)
      return open_price + ProfitPoints * _Point;

   if(position_type == POSITION_TYPE_SELL)
      return open_price - ProfitPoints * _Point;

   return 0.0;
  }

//+------------------------------------------------------------------+
//| Check whether the market has reached the selected trigger        |
//+------------------------------------------------------------------+
bool IsTriggerReached(const ENUM_POSITION_TYPE position_type,
                      const double open_price,
                      const MqlTick &tick)
  {
   if(TriggerMode == UseTargetPrice)
     {
      if(position_type == POSITION_TYPE_BUY)
         return tick.bid > TargetPrice;

      if(position_type == POSITION_TYPE_SELL)
         return tick.ask < TargetPrice;

      return false;
     }

   if(position_type == POSITION_TYPE_BUY)
      return tick.bid > open_price + ProfitPoints * _Point;

   if(position_type == POSITION_TYPE_SELL)
      return tick.ask < open_price - ProfitPoints * _Point;

   return false;
  }

//+------------------------------------------------------------------+
//| Verify that the broker accepts the new Stop Loss level           |
//+------------------------------------------------------------------+
bool IsStopLossAllowed(const ENUM_POSITION_TYPE position_type,
                       const double new_sl,
                       const MqlTick &tick,
                       const ulong ticket)
  {
   long stops_level_points  = 0;
   long freeze_level_points = 0;

   SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL,stops_level_points);

   SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL,freeze_level_points);

   long minimum_distance_points =
      MathMax(stops_level_points, freeze_level_points);

   double minimum_distance = minimum_distance_points * _Point;

   if(position_type == POSITION_TYPE_BUY && (tick.bid - new_sl) < minimum_distance)
     {
      PrintFormat(
         "Position %I64u skipped: Buy Stop Loss is too close to Bid.",
         ticket
      );
      return false;
     }

   if(position_type == POSITION_TYPE_SELL && (new_sl - tick.ask) < minimum_distance)
     {
      PrintFormat(
         "Position %I64u skipped: Sell Stop Loss is too close to Ask.",
         ticket
      );
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Normalize price according to symbol digits                       |
//+------------------------------------------------------------------+
double NormalizePrice(const double price)
  {
   return NormalizeDouble(price, (int)_Digits);
  }
//+------------------------------------------------------------------+
