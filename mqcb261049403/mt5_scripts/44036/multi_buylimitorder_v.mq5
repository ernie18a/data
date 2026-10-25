//+------------------------------------------------------------------+
//|                                   Wamek_BuyLimitOrders.mq4       |
//|                        Copyright 2023, MetaQuotes Software Corp. |
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
//| Order price selection                                            |
//+------------------------------------------------------------------+
enum ChooseOption
  {
   UseTargetPrice = 1,
   UseDistanceFromAsk = 2
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ChooseOption PriceMode = UseDistanceFromAsk;

input int      DistanceFromAskPoints = 400;
input double   TargetPrice           = 1.03350;

input double   Lots                  = 0.01;
input int      TakeProfitPoints      = 400;
input int      StopLossPoints        = 200;
input int      NumberOfBuyLimits     = 1;

input int      SlippagePoints        = 20;
input ulong    MagicNumber           = 202609;
input string   OrderComment          = "WM BuyLimit";

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

   if(NumberOfBuyLimits <= 0)
     {
      Alert("NumberOfBuyLimits must be greater than zero.");
      return;
     }

   if(Lots <= 0.0)
     {
      Alert("Lots must be greater than zero.");
      return;
     }

   string confirmation_text =
      StringFormat(
         "You are about to place %d BuyLimit order(s) on %s.\n\n"
         "Volume: %s\n",
         NumberOfBuyLimits,
         _Symbol,
         DoubleToString(Lots, 2)
      );

   int answer = MessageBox(
      confirmation_text,
      "Confirm Buy Limit Orders",
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

   for(int i = 0; i < NumberOfBuyLimits; i++)
     {
      if(PlaceBuyLimitOrder(i + 1))
         successful_orders++;
     }

   PrintFormat(
      "Completed. Successfully placed %d of %d Buy Limit order(s).",
      successful_orders,
      NumberOfBuyLimits
   );
  }

//+------------------------------------------------------------------+
//| Place one Buy Limit order                                        |
//+------------------------------------------------------------------+
bool PlaceBuyLimitOrder(const int order_number)
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

   double entry_price = CalculateEntryPrice(tick.ask);

   if(entry_price <= 0.0)
     {
      PrintFormat(
         "Order %d failed: invalid entry price.",
         order_number
      );
      return false;
     }

   entry_price = NormalizePrice(entry_price);

   // A Buy Limit must be below the current Ask price.
   if(entry_price >= tick.ask)
     {
      PrintFormat(
         "Order %d failed: Buy Limit price %s must be below current Ask %s.",
         order_number,
         DoubleToString(entry_price, _Digits),
         DoubleToString(tick.ask, _Digits)
      );
      return false;
     }

   long stop_level_points = 0;
   long freeze_level_points = 0;

   SymbolInfoInteger( _Symbol,SYMBOL_TRADE_STOPS_LEVEL,stop_level_points);

   SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL,freeze_level_points);

   long minimum_distance_points = MathMax(stop_level_points, freeze_level_points);

   double minimum_distance = minimum_distance_points * _Point;

   if((tick.ask - entry_price) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: entry price is too close to Ask. "
         "Minimum distance is %d points.",
         order_number,
         minimum_distance_points
      );
      return false;
     }

   double stop_loss = 0.0;
   double take_profit = 0.0;

   if(StopLossPoints > 0) stop_loss = NormalizePrice(entry_price - StopLossPoints * _Point);

   if(TakeProfitPoints > 0) take_profit = NormalizePrice(entry_price + TakeProfitPoints * _Point );

   // Validate the stop-loss distance from the entry price.
   if(stop_loss > 0.0 && (entry_price - stop_loss) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Stop Loss is below the broker's minimum distance.",
         order_number
      );
      return false;
     }

   // Validate the take-profit distance from the entry price.
   if(take_profit > 0.0 && (take_profit - entry_price) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Take Profit is below the broker's minimum distance.",
         order_number
      );
      return false;
     }

   string comment = StringFormat( "%s #%d", OrderComment, order_number );

   ResetLastError();

   bool placed = trade.BuyLimit(volume,entry_price, _Symbol, stop_loss, take_profit, ORDER_TIME_GTC, 0, comment);

   if(!placed)
     {
      PrintFormat( "Order %d failed. Retcode: %u - %s. Last error: %d",
         order_number,trade.ResultRetcode(),trade.ResultRetcodeDescription(),
         GetLastError()
      );
      return false;
     }

   PrintFormat(
      "Order %d placed successfully. Ticket: %I64u, Entry: %s, "
      "SL: %s, TP: %s",
      order_number, trade.ResultOrder(),
      DoubleToString(entry_price, _Digits),
      DoubleToString(stop_loss, _Digits),
      DoubleToString(take_profit, _Digits)
   );

   return true;
  }

//+------------------------------------------------------------------+
//| Calculate Buy Limit entry price                                  |
//+------------------------------------------------------------------+
double CalculateEntryPrice(const double ask_price)
  {
   if(PriceMode == UseTargetPrice)
      return TargetPrice;

   return ask_price - DistanceFromAskPoints * _Point;
  }

//+------------------------------------------------------------------+
//| Normalize price according to symbol digits                       |
//+------------------------------------------------------------------+
double NormalizePrice(const double price)
  {
   return NormalizeDouble(price, (int)_Digits);
  }

//+------------------------------------------------------------------+
//| Normalize volume according to broker requirements                 |
//+------------------------------------------------------------------+
double NormalizeVolume(const double requested_volume)
  {
   double minimum_volume = 0.0;
   double maximum_volume = 0.0;
   double volume_step = 0.0;

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

   int volume_digits = GetVolumeDigits(volume_step);

   return NormalizeDouble(volume, volume_digits);
  }

//+------------------------------------------------------------------+
//| Determine decimal places required for volume step                 |
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
