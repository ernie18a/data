//+------------------------------------------------------------------+
//|                       Wamek_SellLimitOrders_Improved.mq4         |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script - 2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property strict
#property show_inputs

//+------------------------------------------------------------------+
//| Sell Limit price selection                                       |
//+------------------------------------------------------------------+
enum ChooseOption
  {
   UseTargetPrice    = 1,
   UseDistanceFromBid = 2
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ChooseOption PriceMode             = UseDistanceFromBid;
input int          DistanceFromBidPoints = 400;
input double       TargetPrice           = 1.03350;
input double       Lots                  = 0.01;
input int          TakeProfitPoints      = 400;
input int          StopLossPoints        = 200;
input int          NumberOfSellLimits    = 1;
input int          SlippagePoints        = 3;
input int          MagicNumber           = 1400;
input string       OrderComment          = "WM Sell Limit";

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

   if(NumberOfSellLimits <= 0)
     {
      Alert("NumberOfSellLimits must be greater than zero.");
      return;
     }

   if(Lots <= 0.0)
     {
      Alert("Lots must be greater than zero.");
      return;
     }

   if(DistanceFromBidPoints < 0 ||
      TakeProfitPoints < 0 ||
      StopLossPoints < 0 ||
      SlippagePoints < 0)
     {
      Alert("Distance, Stop Loss, Take Profit, and Slippage values "
            "cannot be negative.");
      return;
     }

   string confirmation_text = StringFormat(
      "You are about to place %d Sell Limit order(s) on %s.\n\n"
      "Volume: %.2f\n"
      "Stop Loss: %d points\n"
      "Take Profit: %d points\n"
      "Slippage: %d points",
      NumberOfSellLimits,
      Symbol(),
      Lots,
      StopLossPoints,
      TakeProfitPoints,
      SlippagePoints
   );

   int answer = MessageBox(
      confirmation_text,
      "Confirm Sell Limit Orders",
      MB_YESNO | MB_ICONQUESTION
   );

   if(answer != IDYES)
     {
      Print("Operation cancelled by user.");
      return;
     }

   int successful_orders = 0;

   for(int order_number = 1;
       order_number <= NumberOfSellLimits;
       order_number++)
     {
      if(PlaceSellLimitOrder(order_number))
         successful_orders++;
     }

   PrintFormat(
      "Completed. Successfully placed %d of %d Sell Limit order(s).",
      successful_orders,
      NumberOfSellLimits
   );
  }

//+------------------------------------------------------------------+
//| Place one native MT4 Sell Limit order                            |
//+------------------------------------------------------------------+
bool PlaceSellLimitOrder(const int order_number)
  {
   RefreshRates();

   double bid = MarketInfo(Symbol(), MODE_BID);
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);

   if(bid <= 0.0 || point <= 0.0)
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

   double entry_price = CalculateEntryPrice(bid, point);
   entry_price = NormalizeDouble(entry_price, digits);

   if(entry_price <= 0.0)
     {
      PrintFormat(
         "Order %d failed: invalid entry price.",
         order_number
      );
      return(false);
     }

   // A Sell Limit must be above the current Bid price.
   if(entry_price <= bid)
     {
      PrintFormat(
         "Order %d failed: Sell Limit price %s must be above current Bid %s.",
         order_number,
         DoubleToString(entry_price, digits),
         DoubleToString(bid, digits)
      );
      return(false);
     }

   int minimum_distance_points = GetMinimumDistancePoints();
   double minimum_distance = minimum_distance_points * point;

   if((entry_price - bid) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: entry price is too close to Bid. "
         "Minimum distance is %d points.",
         order_number,
         minimum_distance_points
      );
      return(false);
     }

   double stop_loss = 0.0;
   double take_profit = 0.0;

   // For a sell order, Stop Loss is above entry and Take Profit below entry.
   if(StopLossPoints > 0)
      stop_loss = NormalizeDouble( entry_price + StopLossPoints * point,digits);

   if(TakeProfitPoints > 0)
      take_profit = NormalizeDouble(entry_price - TakeProfitPoints * point,digits);

   if(stop_loss > 0.0 &&
      (stop_loss - entry_price) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Stop Loss is below the broker's minimum distance.",
         order_number
      );
      return(false);
     }

   if(take_profit > 0.0 &&
      (entry_price - take_profit) < minimum_distance)
     {
      PrintFormat(
         "Order %d failed: Take Profit is below the broker's minimum distance.",
         order_number
      );
      return(false);
     }

   ResetLastError();

   int ticket = OrderSend(Symbol(),OP_SELLLIMIT,volume,entry_price,SlippagePoints,
      stop_loss,take_profit,OrderComment,MagicNumber,0,clrRed);

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
         "Sell Limit order failed. Error #",
         error_code,
         " - ",
         ErrorDescription(error_code)
      );
      return(false);
     }

   PrintFormat(
      "Order %d placed successfully. Ticket: %d, Entry: %s, SL: %s, TP: %s",
      order_number,
      ticket,
      DoubleToString(entry_price, digits),
      DoubleToString(stop_loss, digits),
      DoubleToString(take_profit, digits)
   );

   return(true);
  }

//+------------------------------------------------------------------+
//| Calculate Sell Limit entry price                                 |
//+------------------------------------------------------------------+
double CalculateEntryPrice(const double bid, const double point)
  {
   if(PriceMode == UseTargetPrice)
      return(TargetPrice);

   return(bid + DistanceFromBidPoints * point);
  }

//+------------------------------------------------------------------+
//| Get the greater of broker stop and freeze distances               |
//+------------------------------------------------------------------+
int GetMinimumDistancePoints()
  {
   int stops_level = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   int freeze_level = (int)MarketInfo(Symbol(), MODE_FREEZELEVEL);

   return(MathMax(stops_level, freeze_level));
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
//| Determine decimal places required for the lot step                |
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
      case 147:  return("Expiration denied by broker");
      case 148:  return("Too many orders");
      default:   return("Unknown MT4 trade error");
     }
  }
//+------------------------------------------------------------------+
