//+------------------------------------------------------------------+
//|                                              Pending_tread.mq5   |
//|                                              Mir Mostofa Kamal   |
//|                               https://www.mql5.com/en/users/bokul|
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Mir Mostofa Kamal"
#property link      "https://www.mql5.com/en/users/bokul"
#property version   "1.00"
#property description "Pending tread EA."
#property description "This EA will work on all time frames. Good for Scalping in XAUUSD."
#property description "WARNING: Use this software at your own risk."
#property description "The creator of this script cannot be held responsible for any damage or loss."
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
input string Genaral_Settings        = "=== Genaral Settings ===";
input double PipStep = 100;                    // Distance between orders (pips):
input double TakeProfitPips = 75;              // Take Profit in pips:
input double StopLossPips = 50;                // Stop Loss in pips:
input double LotSize = 0.10;                   // Lot size:
input int Slippage = 3;                        // Slippage:
input bool EnableBuyGrid  = true;              // Enable Buy grid:
input string AboveMarketTradeType = "BUY";     // Above market trade type (BUY/SELL):
input bool EnableSellGrid = true;              // Enable Sell grid:
input string BelowMarketTradeType = "SELL";    // Below market trade type (BUY/SELL):

input bool EnableStopLoss = true;              // Enable Stop Loss:
input double MinimumEquity = 100.0;            // Minimum equity to allow trading:

input bool EnableEquityLossProtection = true;  // Enable 20% loss protection:
input double MaxLossPercent = 20.0;            // Max % loss of balance allowed:
input int MagicNumber = 10072025;                // Magic number:

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+
int totalOrdersPerSide = 10;
datetime lastOrderTime = 0;
double startingBalance = 0;
CTrade trade;

//+------------------------------------------------------------------+
//| Normalize lot size to match broker specs                         |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   lot = MathMax(minLot, MathMin(lot, maxLot));
   return NormalizeDouble(lot, (int)MathLog10(1.0 / step));
  }

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("✅ Pending_tread EA initialized. Starting balance: ", startingBalance);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(EnableEquityLossProtection && CheckEquityLossExceeded())
     {
      Print("🛑 Equity drawdown limit exceeded. Closing all trades and orders...");
      CloseAllTradesAndOrders();
      return;
     }

   MaintainAllPendingGrids();
  }

//+------------------------------------------------------------------+
//| Check if equity has dropped below loss threshold                 |
//+------------------------------------------------------------------+
bool CheckEquityLossExceeded()
  {
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double limitEquity = startingBalance * (1.0 - MaxLossPercent / 100.0);
   return currentEquity <= limitEquity;
  }

//+------------------------------------------------------------------+
//| Close all open positions and pending orders                      |
//+------------------------------------------------------------------+
void CloseAllTradesAndOrders()
  {
// Close open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) > 0)
        {
         string symbol = PositionGetString(POSITION_SYMBOL);
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         double volume = PositionGetDouble(POSITION_VOLUME);
         trade.PositionClose(symbol, Slippage);
        }
     }

// Delete pending orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber)
            trade.OrderDelete(ticket);
        }
     }
   Print("✅ All trades and orders closed.");
  }

//+------------------------------------------------------------------+
//| Main grid management                                             |
//+------------------------------------------------------------------+
void MaintainAllPendingGrids()
  {
   if(TradeIsBusy())
     {
      Print("⚠️ Trade context busy, skipping this tick...");
      return;
     }

   if(AccountInfoDouble(ACCOUNT_EQUITY) < MinimumEquity)
     {
      PrintFormat("⚠️ Equity %.2f below minimum required %.2f", AccountInfoDouble(ACCOUNT_EQUITY), MinimumEquity);
      return;
     }

   if(TimeCurrent() - lastOrderTime < 5)
      return;

   lastOrderTime = TimeCurrent();

   if(EnableBuyGrid)
      MaintainPendingGrid(true);

   if(EnableSellGrid)
      MaintainPendingGrid(false);
  }

//+------------------------------------------------------------------+
//| Determine if trade context is busy                               |
//+------------------------------------------------------------------+
bool TradeIsBusy()
  {
   uint code = trade.ResultRetcode();
   return (code == 10010 || code == 10011 || code == 10006);
  }

//+------------------------------------------------------------------+
//| Get pending order type                                           |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetPendingOrderType(bool above, string direction)
  {
   if(direction == "BUY")
      return above ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT;
   else
      return above ? ORDER_TYPE_SELL_LIMIT : ORDER_TYPE_SELL_STOP;
  }

//+------------------------------------------------------------------+
//| Manage single grid                                               |
//+------------------------------------------------------------------+
void MaintainPendingGrid(bool above)
  {
   string direction = above ? AboveMarketTradeType : BelowMarketTradeType;
   ENUM_ORDER_TYPE pendingType = GetPendingOrderType(above, direction);

   double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double stopLevelPoints = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double stopDistance = stopLevelPoints * pointSize;
   double marketPrice = above ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pipMultiplier = (digits == 3 || digits == 5) ? 10.0 : 1.0;

   double pipStepPoints = PipStep * pipMultiplier * pointSize;
   double tpOffset = TakeProfitPips * pipMultiplier * pointSize;
   double slOffset = StopLossPips * pipMultiplier * pointSize;

   int existingCount = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_TYPE) == pendingType &&
            OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
           {
            existingCount++;
           }
        }
     }

   for(int j = existingCount; j < totalOrdersPerSide; j++)
     {
      double orderPrice = 0.0, takeProfit = 0.0, stopLoss = 0.0;

      switch(pendingType)
        {
         case ORDER_TYPE_BUY_STOP:
            orderPrice = NormalizeDouble(marketPrice + (j + 1) * pipStepPoints, digits);
            if((orderPrice - marketPrice) < stopDistance)
               continue;
            takeProfit = NormalizeDouble(orderPrice + tpOffset, digits);
            if(EnableStopLoss)
               stopLoss = NormalizeDouble(orderPrice - slOffset, digits);
            break;

         case ORDER_TYPE_SELL_STOP:
            orderPrice = NormalizeDouble(marketPrice - (j + 1) * pipStepPoints, digits);
            if((marketPrice - orderPrice) < stopDistance)
               continue;
            takeProfit = NormalizeDouble(orderPrice - tpOffset, digits);
            if(EnableStopLoss)
               stopLoss = NormalizeDouble(orderPrice + slOffset, digits);
            break;

         case ORDER_TYPE_BUY_LIMIT:
            orderPrice = NormalizeDouble(marketPrice - (j + 1) * pipStepPoints, digits);
            if((marketPrice - orderPrice) < stopDistance)
               continue;
            takeProfit = NormalizeDouble(orderPrice + tpOffset, digits);
            if(EnableStopLoss)
               stopLoss = NormalizeDouble(orderPrice - slOffset, digits);
            break;

         case ORDER_TYPE_SELL_LIMIT:
            orderPrice = NormalizeDouble(marketPrice + (j + 1) * pipStepPoints, digits);
            if((orderPrice - marketPrice) < stopDistance)
               continue;
            takeProfit = NormalizeDouble(orderPrice - tpOffset, digits);
            if(EnableStopLoss)
               stopLoss = NormalizeDouble(orderPrice + slOffset, digits);
            break;
        }

      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      ZeroMemory(result);

      request.action       = TRADE_ACTION_PENDING;
      request.symbol       = _Symbol;
      request.volume       = NormalizeLot(LotSize);
      request.price        = orderPrice;
      request.sl           = stopLoss;
      request.tp           = takeProfit;
      request.deviation    = Slippage;
      request.magic        = MagicNumber;
      request.type         = pendingType;
      request.type_filling = ORDER_FILLING_RETURN;
      request.type_time    = ORDER_TIME_GTC;
      request.comment      = "Grid EA";

      if(!OrderSend(request, result))
        {
         PrintFormat("❌ OrderSend failed: %d", GetLastError());
         ResetLastError();
        }
      else
        {
         if(result.retcode == TRADE_RETCODE_DONE)
            PrintFormat("✅ Placed %s at %.5f", direction, orderPrice);
         else
            PrintFormat("❌ OrderSend retcode: %d", result.retcode);
        }
     }
  }
//+--------------------------Code end by Mir Mostofa Kamal----------------------------------------+
