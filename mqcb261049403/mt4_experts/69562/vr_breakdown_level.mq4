//+------------------------------------------------------------------+
//|                                           VR Breakdown level.mq4 |
//|                                      Copyright 2026, Trading-Go. |
//+------------------------------------------------------------------+
#property copyright "@ Voldemar"                                      // Copyright information
#property link      "https://www.mql5.com/en/channels/tradingo-go-en" // Website link
#property version   "26.020"                                          // Expert Advisor version
#property strict                                                     // Strict compilation mode

//+------------------------------------------------------------------+
//| Input parameters                                                |
//+------------------------------------------------------------------+
input double          iLots        = 0.01;           // Trading volume in lots
input ENUM_TIMEFRAMES iTimeFrame   = PERIOD_CURRENT; // Timeframe for analysis
input int             iTakeProfit  = 400;            // Take Profit in points
input int             iStopLoss    = 200;            // Stop Loss in points
input int             iMagicNumber = 227;            // Unique identifier for EA orders
input int             iSlippage    = 30;             // Maximum slippage in points

double lt       = 0;    // Corrected lot size after checking step and min limits
double level_up = 0;    // Upper breakdown level (previous bar high)
double level_dw = 0;    // Lower breakdown level (previous bar low)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Get the minimum lot step for the symbol
   double stepvol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(stepvol > 0)
      // Calculate lot size rounded to the nearest step
      lt = stepvol * (int)(iLots / stepvol);
//---
   // Check if calculated lot is less than minimum allowed lot
   if(lt < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      lt = 0.0;  // Set to 0 if below minimum (invalid)
//---
   return(INIT_SUCCEEDED);  // Return successful initialization
  }
//+------------------------------------------------------------------+
//| Expert tick function - executes on every new tick               |
//+------------------------------------------------------------------+
void OnTick()
  {
   int total = OrdersTotal();  // Get total number of open orders/positions
   
   // Check if a new bar has formed
   if(NewBar())
     {
      // Update breakdown levels with previous bar's high and low
      level_up = iHigh(_Symbol, iTimeFrame, 1);  // High of previous bar
      level_dw = iLow(_Symbol,  iTimeFrame, 1);  // Low of previous bar
     }
   
   // Get current Ask and Bid prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Check BUY condition: price breaks above previous bar's high
   if(ask > 0 && level_up > 0 && ask >= level_up)
      if(lt > 0)  // Check if lot size is valid
        {
         // Send BUY order
         int ticket = OrderSend(_Symbol, OP_BUY, lt, ask, iSlippage, 0, 0, NULL, iMagicNumber, 0, clrNONE);
         if(ticket > 0)  // If order placed successfully
           {
            level_up = 0;  // Reset upper level to prevent multiple entries
            return;        // Exit tick processing
           }
        }
   
   // Check SELL condition: price breaks below previous bar's low
   if(bid > 0 && level_dw > 0 && bid <= level_dw)
      if(lt > 0)  // Check if lot size is valid
        {
         // Send SELL order
         int ticket = OrderSend(_Symbol, OP_SELL, lt, bid, iSlippage, 0, 0, NULL, iMagicNumber, 0, clrNONE);
         if(ticket > 0)  // If order placed successfully
           {
            level_dw = 0;  // Reset lower level to prevent multiple entries
            return;        // Exit tick processing
           }
        }
   
   // Loop through all orders to modify SL/TP for existing positions
   for(int i = 0; i < total; i++)
     {
      // Select order by index position
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Check if order belongs to current symbol and this EA
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == iMagicNumber)
           {
            // Get order opening price
            double op = OrderOpenPrice();
            // Get current Take Profit and Stop Loss values
            double tp = NormalizeDouble(OrderTakeProfit(), Digits);
            double sl = NormalizeDouble(OrderStopLoss(), Digits);
            // Initialize new SL/TP with current values
            double new_sl = sl;
            double new_tp = tp;
            
            // Handle BUY position
            if(OrderType() == OP_BUY)
              {
               // Calculate new Stop Loss if enabled
               if(iStopLoss > 0)
                  new_sl = NormalizeDouble(op - iStopLoss * Point, Digits);
               // Calculate new Take Profit if enabled
               if(iTakeProfit > 0)
                  new_tp = NormalizeDouble(op + iTakeProfit * Point, Digits);
              }
            
            // Handle SELL position
            if(OrderType() == OP_SELL)
              {
               // Calculate new Stop Loss if enabled
               if(iStopLoss > 0)
                  new_sl = NormalizeDouble(op + iStopLoss * Point, Digits);
               // Calculate new Take Profit if enabled
               if(iTakeProfit > 0)
                  new_tp = NormalizeDouble(op - iTakeProfit * Point, Digits);
              }
            
            // If SL or TP needs to be updated
            if(new_sl != sl && new_tp != tp)
               // Check if new levels are valid according to broker rules
               if(CheckSL_TP(OrderType(), new_sl, new_tp))
                  // Modify the order with new SL and TP
                  bool res = OrderModify(OrderTicket(), op, new_sl, new_tp, 0, clrNONE);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  // Called when EA is removed from chart
  {
   // No cleanup needed
  }
//+------------------------------------------------------------------+
//| Function to detect new bar formation                            |
//+------------------------------------------------------------------+
bool NewBar(void)
  {
   // Get open time of current bar (index 0)
   datetime new_time = iTime(_Symbol, iTimeFrame, 0);
   // Static variable to store previous bar time
   static datetime old_time = new_time;
   
   // Compare current bar time with previous bar time
   if(new_time != old_time)
      // Update old_time and return true (new bar detected)
      if((old_time = new_time) != NULL)
         return(true);
   // No new bar
   return(false);
  }
//+------------------------------------------------------------------+
//| Check if Stop Loss and Take Profit levels are valid            |
//+------------------------------------------------------------------+
bool CheckSL_TP(int type, double aSL, double aTP)
  {
   // Get minimum stop level required by broker
   int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   // Get current Ask and Bid prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Check validity based on position type
   switch(type)
     {
      case OP_BUY:  // For BUY positions
        {
         // SL must be below Bid by at least stops_level
         // TP must be above Bid by at least stops_level
         return((bid - aSL > stops_level * Point) && (aTP - bid > stops_level * Point));
        }
      case OP_SELL:  // For SELL positions
        {
         // TP must be below Ask by at least stops_level
         // SL must be above Ask by at least stops_level
         return((ask - aTP > stops_level * Point) && (aSL - ask > stops_level * Point));
        }
     }
   return (false);  // Return false if position type is unknown
  }
//+------------------------------------------------------------------+