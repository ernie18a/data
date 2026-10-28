//+------------------------------------------------------------------+
//|                                                Pending_tread.mq4 |
//|                                                Mir Mostofa Kamal |
//|                             https://www.mql5.com/en/users/bokul  |
//+------------------------------------------------------------------+


#property copyright "Copyright 2025, Mir Mostofa Kamal"
#property link      "https://www.mql5.com/en/users/bokul"
#property version   "1.00"
#property description "Pending tread EA."
#property description "This EA will work on all time frames. Good for Scalping."
#property description "WARNING: Use this software at your own risk."
#property description "The creator of this script cannot be held responsible for any damage or loss."
#property strict


//+------------------------------------------------------------------+
//|  Inputs:                                                         |
//+------------------------------------------------------------------+
input string General_Settings     = "=== General Settings ===";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern double PipStep = 12;                     // distance between orders (Pips):
extern double TakeProfitPips = 10;              // TP per trade (Pips):
extern double LotSize = 0.01;                    // Lot size :
extern int Slippage = 3;                          // Slippage :
extern string AboveMarketTradeType = "BUY";      // Above Market Trade Type (Buy/Sell):
extern string BelowMarketTradeType = "SELL";     // Below Market Trade Type (Buy/Sell):
extern int MagicNumber = 123456;                  // EA Magic Number for orders

int totalOrdersPerSide = 10;
datetime lastOrderTime = 0;



//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Pending_tread EA started.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   MaintainAllPendingGrids();
  }
//+------------------------------------------------------------------+
void MaintainAllPendingGrids()
  {
   if(IsTradeContextBusy())
     {
      Print("Trade context busy, skipping this tick...");
      return;
     }

   if(TimeCurrent() - lastOrderTime < 5)   // throttle once per 5 seconds
      return;

   lastOrderTime = TimeCurrent();

   MaintainPendingGrid(true);   // Above market
   MaintainPendingGrid(false);  // Below market
  }
//+------------------------------------------------------------------+
// Fixed pending order type logic:
int GetPendingOrderType(bool above, string direction)
  {
   if(direction == "BUY")
      return above ? OP_BUYSTOP : OP_BUYLIMIT;
   else // direction == "SELL"
      return above ? OP_SELLLIMIT : OP_SELLSTOP;
  }
//+------------------------------------------------------------------+
string PendingTypeToString(int type)
  {
   switch(type)
     {
      case OP_BUYSTOP:
         return "BUY STOP";
      case OP_SELLSTOP:
         return "SELL STOP";
      case OP_BUYLIMIT:
         return "BUY LIMIT";
      case OP_SELLLIMIT:
         return "SELL LIMIT";
      default:
         return "UNKNOWN";
     }
  }
//+------------------------------------------------------------------+
void MaintainPendingGrid(bool above)
  {
   string direction = above ? AboveMarketTradeType : BelowMarketTradeType;
   int pendingType = GetPendingOrderType(above, direction);
   double pointSize = MarketInfo(Symbol(), MODE_POINT);
   int digits = MarketInfo(Symbol(), MODE_DIGITS);
   int stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double stopDistance = stopLevel * pointSize;

   double marketPrice = above ? Ask : Bid;
   double tpOffset = (TakeProfitPips*10) * pointSize;

   PrintFormat("--- MaintainPendingGrid: above=%s, direction=%s, pendingType=%s ---",
               above ? "true" : "false", direction, PendingTypeToString(pendingType));
   PrintFormat("Market price used: %.5f (Ask: %.5f, Bid: %.5f), StopLevel (points): %d, stopDistance: %.5f",
               marketPrice, Ask, Bid, stopLevel, stopDistance);

// Count existing pending orders of this type for this symbol and MagicNumber
   int existingCount = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderType() == pendingType && OrderMagicNumber() == MagicNumber)
           {
            existingCount++;
           }
        }
     }
   PrintFormat("Existing pending orders of type %s: %d", PendingTypeToString(pendingType), existingCount);

   for(int j = existingCount; j < totalOrdersPerSide; j++)
     {
      double orderPrice = 0;
      double takeProfit = 0;

      switch(pendingType)
        {
         case OP_BUYSTOP:
            orderPrice = NormalizeDouble(Ask + (j + 1) * (PipStep*10) * pointSize, digits);
            if((orderPrice - Ask) < stopDistance)
              {
               Print("Skipping BUY STOP too close to Ask");
               continue;
              }
            takeProfit = NormalizeDouble(orderPrice + tpOffset, digits);
            break;

         case OP_SELLSTOP:
            orderPrice = NormalizeDouble(Bid - (j + 1) * (PipStep*10) * pointSize, digits);
            if((Bid - orderPrice) < stopDistance)
              {
               Print("Skipping SELL STOP too close to Bid");
               continue;
              }
            takeProfit = NormalizeDouble(orderPrice - tpOffset, digits);
            break;

         case OP_BUYLIMIT:
            orderPrice = NormalizeDouble(Ask - (j + 1) * (PipStep*10) * pointSize, digits);
            if((Ask - orderPrice) < stopDistance)
              {
               Print("Skipping BUY LIMIT too close to Ask");
               continue;
              }
            takeProfit = NormalizeDouble(orderPrice + tpOffset, digits);
            break;

         case OP_SELLLIMIT:
            orderPrice = NormalizeDouble(Bid + (j + 1) * (PipStep*10) * pointSize, digits);
            if((orderPrice - Bid) < stopDistance)
              {
               Print("Skipping SELL LIMIT too close to Bid");
               continue;
              }
            takeProfit = NormalizeDouble(orderPrice - tpOffset, digits);
            break;

         default:
            Print("Unknown pending order type");
            continue;
        }

      PrintFormat("Trying to place %s at price=%.5f with TP=%.5f", PendingTypeToString(pendingType), orderPrice, takeProfit);

      int ticket = OrderSend(Symbol(), pendingType, LotSize, orderPrice, Slippage, 0, takeProfit, "Grid EA", MagicNumber, 0, clrBlue);
      if(ticket < 0)
        {
         int err = GetLastError();
         PrintFormat("❌ OrderSend failed. Price: %.5f, Error: %d", orderPrice, err);
         ResetLastError();
        }
      else
        {
         PrintFormat("✅ Pending order placed at %.5f (ticket: %d)", orderPrice, ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
