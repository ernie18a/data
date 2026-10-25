//+------------------------------------------------------------------+
//|                                             Multi_SellOrders.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script - 2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property script_show_inputs
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input double Lots             = 0.01;
input int    TakeProfitPoints = 400;
input int    StopLossPoints   = 200;
input int    NumberOfSells    = 1;
input ulong  SlippagePoints   = 3;
input ulong  MagicNumber      = 2024008;
input string OrderComment     = "WM Sell Market";

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

   if(NumberOfSells <= 0)
     {
      Alert("NumberOfSells must be greater than zero.");
      return;
     }

   if(Lots <= 0.0)
     {
      Alert("Lots must be greater than zero.");
      return;
     }

   if(StopLossPoints < 0 || TakeProfitPoints < 0)
     {
      Alert("StopLossPoints and TakeProfitPoints cannot be negative.");
      return;
     }

   string confirmation_text = StringFormat(
      "You are about to open %d Sell market order(s) on %s.\n\n"
      "Volume per order: %s\n"
      "Stop Loss: %d points\n"
      "Take Profit: %d points\n"
      "Maximum deviation: %d points",
      NumberOfSells,
      _Symbol,
      DoubleToString(Lots, 2),
      StopLossPoints,
      TakeProfitPoints,
      SlippagePoints
   );

   int answer = MessageBox(
      confirmation_text,
      "Confirm Sell Orders",
      MB_YESNO | MB_ICONQUESTION
   );

   if(answer != IDYES)
     {
      Print("Operation cancelled by user.");
      return;
     }

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(SlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   int successful_orders = 0;

   for(int order_number = 1;
       order_number <= NumberOfSells;
       order_number++)
     {
      if(PlaceSellOrder(order_number))
         successful_orders++;
     }

   PrintFormat(
      "Completed. Successfully opened %d of %d Sell order(s).",
      successful_orders,
      NumberOfSells
   );
  }

//+------------------------------------------------------------------+
//| Place one market Sell order                                      |
//+------------------------------------------------------------------+
bool PlaceSellOrder(const int order_number)
  {
   MqlTick tick;

   if(!SymbolInfoTick(_Symbol, tick))
     {
      PrintFormat(
         "Order %d failed: unable to retrieve current market prices.",
         order_number
      );
      return false;
     }

   double volume = NormalizeVolume(Lots);

   if(volume <= 0.0)
     {
      PrintFormat(
         "Order %d failed: invalid volume after normalization.",
         order_number
      );
      return false;
     }

   double entry_price = NormalizePrice(tick.bid);
   double stop_loss   = 0.0;
   double take_profit = 0.0;

   if(StopLossPoints > 0)
      stop_loss = NormalizePrice(entry_price + StopLossPoints * _Point);

   if(TakeProfitPoints > 0)
      take_profit = NormalizePrice(entry_price - TakeProfitPoints * _Point);

   if(!ValidateStops(entry_price, stop_loss, take_profit,order_number))
      return false;

   string comment = StringFormat("%s #%d",OrderComment,order_number);

   ResetLastError();

   bool opened = trade.Sell(volume,_Symbol,entry_price,stop_loss,take_profit,comment);

   uint retcode = trade.ResultRetcode();

   if(!opened ||
      (retcode != TRADE_RETCODE_DONE &&
       retcode != TRADE_RETCODE_DONE_PARTIAL))
     {
      PrintFormat(
         "Order %d failed. Retcode: %u - %s. Last error: %d",
         order_number,
         retcode,
         trade.ResultRetcodeDescription(),
         GetLastError()
      );
      return false;
     }

   PrintFormat(
      "Order %d opened successfully. Deal: %I64u, Entry: %s, "
      "SL: %s, TP: %s",
      order_number,
      trade.ResultDeal(),
      DoubleToString(entry_price, _Digits),
      DoubleToString(stop_loss, _Digits),
      DoubleToString(take_profit, _Digits)
   );

   return true;
  }

//+------------------------------------------------------------------+
//| Validate stop levels against broker requirements                 |
//+------------------------------------------------------------------+
bool ValidateStops(const double entry_price,
                   const double stop_loss,
                   const double take_profit,
                   const int order_number)
  {
   long stops_level_points  = 0;
   long freeze_level_points = 0;

   SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL,stops_level_points);

   SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL,freeze_level_points);

   long minimum_distance_points =
      MathMax(stops_level_points, freeze_level_points);

   double minimum_distance = minimum_distance_points * _Point;

   if(stop_loss > 0.0 &&
      (stop_loss - entry_price) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Stop Loss is below the broker's minimum distance.",
         order_number
      );
      return false;
     }

   if(take_profit > 0.0 &&
      (entry_price - take_profit) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Take Profit is below the broker's minimum distance.",
         order_number
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
//| Normalize volume according to broker requirements                |
//+------------------------------------------------------------------+
double NormalizeVolume(const double requested_volume)
  {
   double minimum_volume = 0.0;
   double maximum_volume = 0.0;
   double volume_step    = 0.0;

   if(!SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN, minimum_volume) ||
      !SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX, maximum_volume) ||
      !SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP, volume_step))
     {
      Print("Unable to retrieve symbol volume settings.");
      return 0.0;
     }

   if(volume_step <= 0.0)
      return 0.0;

   double volume = requested_volume;

   volume = MathMax(volume, minimum_volume);
   volume = MathMin(volume, maximum_volume);
   volume = MathRound(volume / volume_step) * volume_step;

   return NormalizeDouble(volume, GetVolumeDigits(volume_step));
  }

//+------------------------------------------------------------------+
//| Determine decimal places required for volume step                |
//+------------------------------------------------------------------+
int GetVolumeDigits(const double volume_step)
  {
   int digits = 0;
   double step = volume_step;

   while(digits < 8 && MathAbs(step - MathRound(step)) > 0.00000001)
     {
      step *= 10.0;
      digits++;
     }

   return digits;
  }
//+------------------------------------------------------------------+
