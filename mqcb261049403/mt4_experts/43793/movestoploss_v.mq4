//+------------------------------------------------------------------+
//|                                                 MoveStopLoss.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Wamek TrailingStop EA-2026"
#property link      "eawamek@gmail.com"
#property version   "1.50"
#property strict
#property description "<< Moves the stoploss along with ask/bid at a  >>"
#property description "<< predetermined distance or ATR-based distance >>"

input bool   AllowAutoTrade    = false; // true = ATR-based trailing, false = fixed points
input int    InpDistance2Trail = 500;   // fixed trailing distance in points
input int    AtrPeriod         = 20;
input double AtrMultiplier     = 2.0;  // Atr multiplier

int OnInit()
{
   HideTestIndicators(true);

   if(!IsTradeAllowed())
   {
      Alert("Enable AutoTrading Please");
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

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

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
      return NormalizeDouble(InpDistance2Trail * Point, Digits);

   double atr = iATR(Symbol(), Period(), AtrPeriod, 0);

   if(atr <= 0.0 || atr == EMPTY_VALUE)
   {
      Print("ATR invalid. Falling back to fixed distance.");
      return NormalizeDouble(InpDistance2Trail * Point, Digits);
   }

   return NormalizeDouble(AtrMultiplier * atr, Digits);
}

//+------------------------------------------------------------------+
//| Prevent the stop-loss from moving backward and forward           |
//+------------------------------------------------------------------+

bool IsNewStopBetter(const int order_type, const double new_sl)
{
   double current_sl = OrderStopLoss();

   if(order_type == OP_BUY)
      return(current_sl == 0.0 || new_sl > current_sl);

   if(order_type == OP_SELL)
      return(current_sl == 0.0 || new_sl < current_sl);

   return(false);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoveStopLoss()
{
   double trail_distance = GetTrailingDistance();

   if(trail_distance <= 0.0)
      return;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      int ticket = OrderTicket();
      int type   = OrderType();
      if(type != OP_BUY && type != OP_SELL)
         continue;

      RefreshRates();

      if(type == OP_BUY)
      {
         if(Bid <= OrderOpenPrice())
            continue;
         double new_sl = NormalizeDouble(Bid - trail_distance, Digits);

         if(new_sl <= 0.0)
            continue;

         if(!IsNewStopBetter(OP_BUY, new_sl)) //Ensure stoploss move in the direction of increasing protection
            continue;

         if(!IsStopLossAllowed(OP_BUY, new_sl, ticket)) //check whether stoploss allowed
            continue;

         if(!OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, clrNONE))
         {
            int err = GetLastError();
            PrintFormat("OrderModify failed for BUY ticket %d. Error %d: %s",
                        ticket, err, ErrorDescription(err));
         }
      }
      else if(type == OP_SELL)
      {
         if(Ask >= OrderOpenPrice())
            continue;

         double new_sl = NormalizeDouble(Ask + trail_distance, Digits);

         if(!IsNewStopBetter(OP_SELL, new_sl))
            continue;

         if(!IsStopLossAllowed(OP_SELL, new_sl, ticket))
            continue;

         if(!OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, clrNONE))
         {
            int err = GetLastError();
            PrintFormat("OrderModify failed for SELL ticket %d. Error %d: %s",
                        ticket, err, ErrorDescription(err));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Verify broker distance requirements                              |
//+------------------------------------------------------------------+
bool IsStopLossAllowed(const int order_type,
                       const double new_sl,
                       const int ticket)
{
   int stops_level = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   int freeze_level = (int)MarketInfo(Symbol(), MODE_FREEZELEVEL);
   int minimum_distance_points = (int)MathMax(stops_level, freeze_level);
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