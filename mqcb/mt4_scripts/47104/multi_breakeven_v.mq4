//+------------------------------------------------------------------+
//|                                              Wamek BreakEven.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script - 2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property strict
#property show_inputs

//+------------------------------------------------------------------+
//| Break-even trigger selection                                     |
//+------------------------------------------------------------------+
enum ChooseOption
  {
   UseTargetPrice  = 1,
   UseProfitPoints = 2
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ChooseOption TriggerMode   = UseProfitPoints;
input int          ProfitPoints  = 100;
input double       TargetPrice   = 1.03350;
input bool         FilterByMagic = false;
input int          MagicNumber   = 0;

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!IsTradeAllowed())
     {
      Alert("Trading is not allowed. Enable AutoTrading and check permissions.");
      return;
     }

   if(ProfitPoints < 0)
     {
      Alert("ProfitPoints cannot be negative.");
      return;
     }

   string trigger_description;

   if(TriggerMode == UseTargetPrice)
      trigger_description = StringFormat(
         "Target price: %s",
         DoubleToString(TargetPrice, Digits)
      );
   else
      trigger_description = StringFormat(
         "Profit trigger: %d points",
         ProfitPoints
      );

   string confirmation_text = StringFormat(
      "Move eligible positions on %s to break-even protection?\n\n%s",
      Symbol(),
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

   MovePositionsToBreakEven();
  }

//+------------------------------------------------------------------+
//| Process all eligible market positions on the current symbol      |
//+------------------------------------------------------------------+
void MovePositionsToBreakEven()
  {
   RefreshRates();

   int eligible_positions = 0;
   int modified_positions = 0;

   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      if(!OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(OrderSymbol() != Symbol())
         continue;

      if(OrderType() != OP_BUY && OrderType() != OP_SELL)
         continue;

      if(FilterByMagic && OrderMagicNumber() != MagicNumber)
         continue;

      eligible_positions++;

      if(ModifyPositionStopLoss())
         modified_positions++;
     }

   PrintFormat(
      "Break-even operation completed. Modified %d of %d eligible "
      "position(s) on %s.",
      modified_positions,
      eligible_positions,
      Symbol()
   );
  }

//+------------------------------------------------------------------+
//| Calculate and apply a valid Stop Loss for the selected position  |
//+------------------------------------------------------------------+
bool ModifyPositionStopLoss()
  {
   int ticket = OrderTicket();
   int order_type = OrderType();
   int digits = Digits;

   double open_price = OrderOpenPrice();
   double current_sl = OrderStopLoss();
   double current_tp = OrderTakeProfit();

   double new_sl = CalculateBreakEvenPrice(order_type, open_price);

   if(new_sl <= 0.0)
      return(false);

   new_sl = NormalizeDouble(new_sl, digits);

   if(!IsTriggerReached(order_type, open_price))
      return(false);

   // Break-even protection should not be placed on the losing side.
   if(order_type == OP_BUY && new_sl < open_price)
     {
      PrintFormat(
         "Position %d skipped: Buy Stop Loss %s is below entry %s.",
         ticket,
         DoubleToString(new_sl, digits),
         DoubleToString(open_price, digits)
      );
      return(false);
     }

   if(order_type == OP_SELL && new_sl > open_price)
     {
      PrintFormat(
         "Position %d skipped: Sell Stop Loss %s is above entry %s.",
         ticket,
         DoubleToString(new_sl, digits),
         DoubleToString(open_price, digits)
      );
      return(false);
     }

   // Never move an existing Stop Loss in the unfavorable direction.
   if(order_type == OP_BUY &&
      current_sl > 0.0 && new_sl <= current_sl)
      return(false);

   if(order_type == OP_SELL &&
      current_sl > 0.0 && new_sl >= current_sl)
      return(false);

   if(!IsStopLossAllowed(order_type, new_sl, ticket))
      return(false);

   ResetLastError();

   color arrow_color =
      (order_type == OP_BUY) ? clrBlue : clrPink;

   bool modified = OrderModify(ticket,open_price,new_sl,current_tp,0,arrow_color);

   if(!modified)
     {
      int error_code = GetLastError();

      PrintFormat(
         "Position %d modification failed. Error: %d - %s.",
         ticket,
         error_code,
         ErrorDescription(error_code)
      );
      return(false);
     }

   PrintFormat(
      "Position %d Stop Loss moved to %s.",
      ticket,
      DoubleToString(new_sl, digits)
   );

   return(true);
  }

//+------------------------------------------------------------------+
//| Calculate requested break-even protection price                  |
//+------------------------------------------------------------------+
double CalculateBreakEvenPrice(const int order_type,
                               const double open_price)
  {
   if(TriggerMode == UseTargetPrice)
      return(TargetPrice);

   if(order_type == OP_BUY)
      return(open_price + ProfitPoints * Point);

   if(order_type == OP_SELL)
      return(open_price - ProfitPoints * Point);

   return(0.0);
  }

//+------------------------------------------------------------------+
//| Check whether the market has reached the selected trigger        |
//+------------------------------------------------------------------+
bool IsTriggerReached(const int order_type,
                      const double open_price)
  {
   RefreshRates();

   if(TriggerMode == UseTargetPrice)
     {
      if(order_type == OP_BUY)
         return(Bid > TargetPrice);

      if(order_type == OP_SELL)
         return(Ask < TargetPrice);

      return(false);
     }

   if(order_type == OP_BUY)
      return(Bid > open_price + ProfitPoints * Point);

   if(order_type == OP_SELL)
      return(Ask < open_price - ProfitPoints * Point);

   return(false);
  }

//+------------------------------------------------------------------+
//| Verify that the broker accepts the new Stop Loss level           |
//+------------------------------------------------------------------+
bool IsStopLossAllowed(const int order_type,
                       const double new_sl,
                       const int ticket)
  {
   int stops_level = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   int freeze_level = (int)MarketInfo(Symbol(), MODE_FREEZELEVEL);
   int minimum_distance_points = MathMax(stops_level, freeze_level);
   double minimum_distance = minimum_distance_points * Point;

   RefreshRates();

   if(order_type == OP_BUY &&
      (Bid - new_sl) < minimum_distance)
     {
      PrintFormat(
         "Position %d skipped: Buy Stop Loss is too close to Bid.",
         ticket
      );
      return(false);
     }

   if(order_type == OP_SELL &&
      (new_sl - Ask) < minimum_distance)
     {
      PrintFormat(
         "Position %d skipped: Sell Stop Loss is too close to Ask.",
         ticket
      );
      return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Return readable descriptions for common MT4 errors               |
//+------------------------------------------------------------------+
string ErrorDescription(const int error_code)
  {
   switch(error_code)
     {
      case 0:    return("No error");
      case 1:    return("No error returned, but the result is unknown");
      case 2:    return("Common error");
      case 3:    return("Invalid trade parameters");
      case 4:    return("Trade server is busy");
      case 5:    return("Old terminal version");
      case 6:    return("No connection with trade server");
      case 8:    return("Too frequent requests");
      case 64:   return("Account disabled");
      case 65:   return("Invalid account");
      case 130:  return("Invalid stops");
      case 132:  return("Market is closed");
      case 133:  return("Trade is disabled");
      case 136:  return("No prices");
      case 137:  return("Broker is busy");
      case 146:  return("Trade context is busy");
      default:   return("Unknown MT4 trade error");
     }
  }
//+------------------------------------------------------------------+
