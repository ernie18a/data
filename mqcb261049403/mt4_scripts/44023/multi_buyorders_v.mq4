//+------------------------------------------------------------------+
//|                                        Wamek_BuyOrders.mq4       |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script - 2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property strict
#property show_inputs

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input double Lots             = 0.01;
input int    TakeProfitPoints = 400;
input int    StopLossPoints   = 200;
input int    NumberOfBuys     = 1;
input int    SlippagePoints   = 30;
input int    MagicNumber      = 1300;
input string orderComment     = "WM Buy";

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

   if(NumberOfBuys <= 0)
     {
      Alert("NumberOfBuys must be greater than zero.");
      return;
     }

   if(Lots <= 0.0 ||
      TakeProfitPoints < 0 ||
      StopLossPoints < 0 ||
      SlippagePoints < 0)
     {
      Alert("Lots, Stop Loss, Take Profit, and Slippage values are invalid.");
      return;
     }

   string confirmation_text = StringFormat(
      "You are about to open %d Buy order(s) on %s.\n\n"
      "Volume per order: %.2f\n"
      "Stop Loss: %d points\n"
      "Take Profit: %d points\n"
      "Slippage: %d points",
      NumberOfBuys,
      Symbol(),
      Lots,
      StopLossPoints,
      TakeProfitPoints,
      SlippagePoints
   );

   int answer = MessageBox(
      confirmation_text,
      "Confirm Buy Orders",
      MB_YESNO | MB_ICONQUESTION
   );

   if(answer != IDYES)
     {
      Print("Operation cancelled by user.");
      return;
     }

   int successful_orders = 0;

   for(int order_number = 1;
       order_number <= NumberOfBuys;
       order_number++)
     {
      if(PlaceBuyOrder(order_number))
         successful_orders++;
     }

   PrintFormat(
      "Completed. Successfully opened %d of %d Buy order(s).",
      successful_orders,
      NumberOfBuys
   );
  }

//+------------------------------------------------------------------+
//| Place one native MT4 Buy order                                   |
//+------------------------------------------------------------------+
bool PlaceBuyOrder(const int order_number)
  {
   RefreshRates();

   double ask = MarketInfo(Symbol(), MODE_ASK);
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);

   if(ask <= 0.0 || point <= 0.0)
     {
      PrintFormat(
         "Order %d failed: unable to retrieve valid market information.",
         order_number
      );
      return(false);
     }

   double volume = NormalizeVolume(Lots);

   if(volume <= 0.0)
     {
      PrintFormat(
         "Order %d failed: invalid volume after normalization.",
         order_number
      );
      return(false);
     }

   double entry_price = NormalizeDouble(ask, digits);
   double stop_loss = 0.0;
   double take_profit = 0.0;

   if(StopLossPoints > 0)
      stop_loss = NormalizeDouble(entry_price - StopLossPoints * point,digits);

   if(TakeProfitPoints > 0)
      take_profit = NormalizeDouble(entry_price + TakeProfitPoints * point,digits);

   if(!ValidateStops(entry_price, stop_loss, take_profit, order_number))
      return(false);

   ResetLastError();

   int ticket = OrderSend(Symbol(),OP_BUY,volume,entry_price,SlippagePoints,
      stop_loss,take_profit,orderComment,MagicNumber,0,clrGreen);

   if(ticket < 0)
     {
      int error_code = GetLastError();

      PrintFormat(
         "Order %d failed. Error: %d - %s. Entry: %s, SL: %s, TP: %s",
         order_number,
         error_code,
         ErrorDescription(error_code),
         DoubleToString(entry_price, digits),
         DoubleToString(stop_loss, digits),
         DoubleToString(take_profit, digits)
      );

      Alert(
         "Buy order failed. Error #",
         error_code,
         " - ",
         ErrorDescription(error_code)
      );
      return(false);
     }

   PrintFormat(
      "Order %d opened successfully. Ticket: %d, Entry: %s, SL: %s, TP: %s",
      order_number,
      ticket,
      DoubleToString(entry_price, digits),
      DoubleToString(stop_loss, digits),
      DoubleToString(take_profit, digits)
   );

   return(true);
  }

//+------------------------------------------------------------------+
//| Validate Buy Stop Loss and Take Profit levels                    |
//+------------------------------------------------------------------+
bool ValidateStops(const double entry_price,
                   const double stop_loss,
                   const double take_profit,
                   const int order_number)
  {
   int stops_level = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   int freeze_level = (int)MarketInfo(Symbol(), MODE_FREEZELEVEL);
   int minimum_distance_points = MathMax(stops_level, freeze_level);
   double minimum_distance = minimum_distance_points * Point;

   if(stop_loss > 0.0)
     {
      if(stop_loss >= entry_price ||
         (entry_price - stop_loss) < minimum_distance)
        {
         PrintFormat(
            "Order %d failed: invalid Buy Stop Loss or broker distance.",
            order_number
         );
         return(false);
        }
     }

   if(take_profit > 0.0)
     {
      if(take_profit <= entry_price ||
         (take_profit - entry_price) < minimum_distance)
        {
         PrintFormat(
            "Order %d failed: invalid Buy Take Profit or broker distance.",
            order_number
         );
         return(false);
        }
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Normalize volume to broker requirements                           |
//+------------------------------------------------------------------+
double NormalizeVolume(const double requested_volume)
  {
   double minimum_volume = MarketInfo(Symbol(), MODE_MINLOT);
   double maximum_volume = MarketInfo(Symbol(), MODE_MAXLOT);
   double volume_step = MarketInfo(Symbol(), MODE_LOTSTEP);

   if(minimum_volume <= 0.0 ||
      maximum_volume <= 0.0 ||
      volume_step <= 0.0)
     {
      Print("Unable to retrieve symbol volume settings.");
      return(0.0);
     }

   double volume = requested_volume;

   volume = MathMax(volume, minimum_volume);
   volume = MathMin(volume, maximum_volume);
   volume = MathRound(volume / volume_step) * volume_step;

   return(NormalizeDouble(volume, GetVolumeDigits(volume_step)));
  }

//+------------------------------------------------------------------+
//| Determine decimal places required for the lot step               |
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

   return(digits);
  }

//+------------------------------------------------------------------+
//| Return a readable description for common MT4 trade errors         |
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
      case 129:  return("Invalid price");
      case 130:  return("Invalid stops");
      case 131:  return("Invalid trade volume");
      case 132:  return("Market is closed");
      case 133:  return("Trade is disabled");
      case 134:  return("Not enough money");
      case 135:  return("Price changed");
      case 136:  return("No prices");
      case 137:  return("Broker is busy");
      case 138:  return("Requote");
      case 139:  return("Order is locked");
      case 146:  return("Trade context is busy");
      default:   return("Unknown MT4 trade error");
     }
  }
//+------------------------------------------------------------------+
