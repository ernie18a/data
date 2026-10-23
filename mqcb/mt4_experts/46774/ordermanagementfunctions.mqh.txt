//+------------------------------------------------------------------+
//|                                     OrderManagementFunctions.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>

int Buys, Sells, HedgeBuys, HedgeSells;
int PendingBuys, PendingSells, HedgePendingBuys, HedgePendingSells;
double BuyLots, SellLots, HedgeBuyLots, HedgeSellLots;
double PendingBuyLots, PendingSellLots, HedgePendingBuyLots, HedgePendingSellLots;
double Profit;

int BuyTickets[];
int SellTickets[];
int PendingBuyTickets[];
int PendingSellTickets[];
int HedgeBuyTickets[];
int HedgeSellTickets[];
int HedgePendingBuyTickets[];
int HedgePendingSellTickets[];

datetime BuyOpenTimes[];
datetime SellOpenTimes[];
datetime PendingBuyOpenTimes[];
datetime PendingSellOpenTimes[];
datetime HedgeBuyOpenTimes[];
datetime HedgeSellOpenTimes[];
datetime HedgePendingBuyOpenTimes[];
datetime HedgePendingSellOpenTimes[];

double BuyOpenPrices[];
double SellOpenPrices[];
double PendingBuyOpenPrices[];
double PendingSellOpenPrices[];
double HedgeBuyOpenPrices[];
double HedgeSellOpenPrices[];
double HedgePendingBuyOpenPrices[];
double HedgePendingSellOpenPrices[];

double BuyOrderLots[];
double SellOrderLots[];
double PendingBuyOrderLots[];
double PendingSellOrderLots[];
double HedgeBuyOrderLots[];
double HedgeSellOrderLots[];
double HedgePendingBuyOrderLots[];
double HedgePendingSellOrderLots[];

//+------------------------------------------------------------------+
int Count(int OrdersArraySize, int OrdersMagicNumber, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   ArrayResize(BuyTickets, OrdersArraySize);
   ArrayResize(SellTickets, OrdersArraySize);
   ArrayResize(PendingBuyTickets, OrdersArraySize);
   ArrayResize(PendingSellTickets, OrdersArraySize);
   ArrayResize(BuyOpenTimes, OrdersArraySize);
   ArrayResize(SellOpenTimes, OrdersArraySize);
   ArrayResize(PendingBuyOpenTimes, OrdersArraySize);
   ArrayResize(PendingSellOpenTimes, OrdersArraySize);
   ArrayResize(BuyOpenPrices, OrdersArraySize);
   ArrayResize(SellOpenPrices, OrdersArraySize);
   ArrayResize(PendingBuyOpenPrices, OrdersArraySize);
   ArrayResize(PendingSellOpenPrices, OrdersArraySize);
   ArrayResize(BuyOrderLots, OrdersArraySize);
   ArrayResize(SellOrderLots, OrdersArraySize);
   ArrayResize(PendingBuyOrderLots, OrdersArraySize);
   ArrayResize(PendingSellOrderLots, OrdersArraySize);
//---
   ArrayResize(HedgeBuyTickets, OrdersArraySize);
   ArrayResize(HedgeSellTickets, OrdersArraySize);
   ArrayResize(HedgePendingBuyTickets, OrdersArraySize);
   ArrayResize(HedgePendingSellTickets, OrdersArraySize);
   ArrayResize(HedgeBuyOpenTimes, OrdersArraySize);
   ArrayResize(HedgeSellOpenTimes, OrdersArraySize);
   ArrayResize(HedgePendingBuyOpenTimes, OrdersArraySize);
   ArrayResize(HedgePendingSellOpenTimes, OrdersArraySize);
   ArrayResize(HedgeBuyOpenPrices, OrdersArraySize);
   ArrayResize(HedgeSellOpenPrices, OrdersArraySize);
   ArrayResize(HedgePendingBuyOpenPrices, OrdersArraySize);
   ArrayResize(HedgePendingSellOpenPrices, OrdersArraySize);
   ArrayResize(HedgeBuyOrderLots, OrdersArraySize);
   ArrayResize(HedgeSellOrderLots, OrdersArraySize);
   ArrayResize(HedgePendingBuyOrderLots, OrdersArraySize);
   ArrayResize(HedgePendingSellOrderLots, OrdersArraySize);
//---
   ArrayFill(BuyTickets, 0, OrdersArraySize, -1);
   ArrayFill(SellTickets, 0, OrdersArraySize, -1);
   ArrayFill(PendingBuyTickets, 0, OrdersArraySize, -1);
   ArrayFill(PendingSellTickets, 0, OrdersArraySize, -1);
   ArrayFill(BuyOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(SellOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(PendingBuyOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(PendingSellOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(BuyOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(SellOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(PendingBuyOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(PendingSellOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(BuyOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(SellOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(PendingBuyOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(PendingSellOrderLots, 0, OrdersArraySize, 0);
//---
   ArrayFill(HedgeBuyTickets, 0, OrdersArraySize, -1);
   ArrayFill(HedgeSellTickets, 0, OrdersArraySize, -1);
   ArrayFill(HedgePendingBuyTickets, 0, OrdersArraySize, -1);
   ArrayFill(HedgePendingSellTickets, 0, OrdersArraySize, -1);
   ArrayFill(HedgeBuyOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(HedgeSellOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingBuyOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingSellOpenTimes, 0, OrdersArraySize, 0);
   ArrayFill(HedgeBuyOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(HedgeSellOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingBuyOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingSellOpenPrices, 0, OrdersArraySize, 0);
   ArrayFill(HedgeBuyOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(HedgeSellOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingBuyOrderLots, 0, OrdersArraySize, 0);
   ArrayFill(HedgePendingSellOrderLots, 0, OrdersArraySize, 0);
//---
   Profit = 0;
//---
   Buys = 0;
   Sells = 0;
   BuyLots = 0;
   SellLots = 0;
   PendingBuys = 0;
   PendingSells = 0;
   PendingBuyLots = 0;
   PendingSellLots = 0;
//---
   HedgeBuys = 0;
   HedgeSells = 0;
   HedgeBuyLots = 0;
   HedgeSellLots = 0;
   HedgePendingBuys = 0;
   HedgePendingSells = 0;
   HedgePendingBuyLots = 0;
   HedgePendingSellLots = 0;
//---
   int FirstMarketOrderTicket=-1;
   datetime orderOpenTime = 0;
   int buffersIndexBuys = 0, buffersIndexSells = 0, buffersIndexPendingBuys = 0, buffersIndexPendingSells = 0;
//---
   for(int i=0; i<=OrdersTotal(); i++)
     {

      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         continue;
        }

      if(OrderSymbol()==Symbol())
        {
         if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
           {
            continue;
           }

         if(OrderType()==OP_SELL)
           {
            SellLots+=OrderLots();
            Sells++;
            SellTickets[buffersIndexSells]=OrderTicket();
            SellOrderLots[buffersIndexSells]=OrderLots();
            SellOpenTimes[buffersIndexSells]=OrderOpenTime();
            SellOpenPrices[buffersIndexSells]=OrderOpenPrice();

            if(StringFind(OrderComment(), "_HEDGE_", 0) >= 0)
              {
               HedgeSellLots+=OrderLots();
               HedgeSells++;
               HedgeSellTickets[buffersIndexSells]=OrderTicket();
               HedgeSellOrderLots[buffersIndexSells]=OrderLots();
               HedgeSellOpenTimes[buffersIndexSells]=OrderOpenTime();
               HedgeSellOpenPrices[buffersIndexSells]=OrderOpenPrice();
              }

            buffersIndexSells++;

            Profit+=OrderProfit()+OrderSwap()+OrderCommission();

            if(orderOpenTime == 0 || OrderOpenTime() < orderOpenTime)
              {
               FirstMarketOrderTicket = OrderTicket();
              }
           }

         if(OrderType()==OP_BUY)
           {
            BuyLots+=OrderLots();
            Buys++;
            BuyTickets[buffersIndexBuys]=OrderTicket();
            BuyOrderLots[buffersIndexBuys]=OrderLots();
            BuyOpenTimes[buffersIndexBuys]=OrderOpenTime();
            BuyOpenPrices[buffersIndexBuys]=OrderOpenPrice();

            if(StringFind(OrderComment(), "_HEDGE_", 0) >= 0)
              {
               HedgeBuyLots+=OrderLots();
               HedgeBuys++;
               HedgeBuyTickets[buffersIndexBuys]=OrderTicket();
               HedgeBuyOrderLots[buffersIndexBuys]=OrderLots();
               HedgeBuyOpenTimes[buffersIndexBuys]=OrderOpenTime();
               HedgeBuyOpenPrices[buffersIndexBuys]=OrderOpenPrice();
              }

            buffersIndexBuys++;

            Profit+=OrderProfit()+OrderSwap()+OrderCommission();

            if(orderOpenTime == 0 || OrderOpenTime() < orderOpenTime)
              {
               FirstMarketOrderTicket = OrderTicket();
              }
           }

         if(OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
           {
            PendingSellLots+=OrderLots();
            PendingSells++;
            PendingSellTickets[buffersIndexPendingSells]=OrderTicket();
            PendingSellOrderLots[buffersIndexPendingSells]=OrderLots();
            PendingSellOpenTimes[buffersIndexPendingSells]=OrderOpenTime();
            PendingSellOpenPrices[buffersIndexPendingSells]=OrderOpenPrice();

            if(StringFind(OrderComment(), "_HEDGE_", 0) >= 0)
              {
               HedgePendingSellLots+=OrderLots();
               HedgePendingSells++;
               HedgePendingSellTickets[buffersIndexPendingSells]=OrderTicket();
               HedgePendingSellOrderLots[buffersIndexPendingSells]=OrderLots();
               HedgePendingSellOpenTimes[buffersIndexPendingSells]=OrderOpenTime();
               HedgePendingSellOpenPrices[buffersIndexPendingSells]=OrderOpenPrice();
              }

            buffersIndexPendingSells++;
           }

         if(OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT)
           {
            PendingBuyLots+=OrderLots();
            PendingBuys++;
            PendingBuyTickets[buffersIndexPendingBuys]=OrderTicket();
            PendingBuyOrderLots[buffersIndexPendingBuys]=OrderLots();
            PendingBuyOpenTimes[buffersIndexPendingBuys]=OrderOpenTime();
            PendingBuyOpenPrices[buffersIndexPendingBuys]=OrderOpenPrice();

            if(StringFind(OrderComment(), "_HEDGE_", 0) >= 0)
              {
               HedgePendingBuyLots+=OrderLots();
               HedgePendingBuys++;
               HedgePendingBuyTickets[buffersIndexPendingBuys]=OrderTicket();
               HedgePendingBuyOrderLots[buffersIndexPendingBuys]=OrderLots();
               HedgePendingBuyOpenTimes[buffersIndexPendingBuys]=OrderOpenTime();
               HedgePendingBuyOpenPrices[buffersIndexPendingBuys]=OrderOpenPrice();
              }

            buffersIndexPendingBuys++;
           }
        }//if
     }//for

   return(FirstMarketOrderTicket);
  }
//+------------------------------------------------------------------+
string GetOrderTypeString(int OrderTypeNum)
  {
   switch(OrderTypeNum)
     {
      case OP_BUY:
         return "OP_BUY";
      case OP_BUYLIMIT:
         return "OP_BUYLIMIT";
      case OP_BUYSTOP:
         return "OP_BUYSTOP";
      case OP_SELL:
         return "OP_SELL";
      case OP_SELLLIMIT:
         return "OP_SELLLIMIT";
      case OP_SELLSTOP:
         return "OP_SELLSTOP";
     }
   return "UNKNOWN";
  }
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {

   if(AccountBalance() < 10)
     {
      Comment("minimum balances is $10");
      return(false);
     }

//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, int type)
  {
   double free_margin = AccountFreeMarginCheck(symb, type, lots);
//-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }

//+------------------------------------------------------------------+
// Basic round 0.5-> 1 0.49 -> 0
double Round(double value, int decimals)
  {
   double timesten, truevalue;
   if(decimals < 0)
     {
      Print("Wrong decimals input parameter, paramater cant be below 0");
      return 0;
     }
   timesten = value * MathPow(10,decimals);
   timesten = MathRound(timesten);
   truevalue = timesten/MathPow(10,decimals);
   return truevalue;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RoundDown(double val,int decim)
  {
   if(Round(val,decim) > val)
      return Round(val,decim)-MathPow(10,-decim);
   else
      return Round(val,decim);
  }

// Rounds the parameter to a valid Lot amount
double RoundtoLots(double Val)
  {
   double ret = 0.0;
   Val = Round(Val,6);
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) == 0.01)
      ret = RoundDown(Val,2);
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) == 0.1)
      ret = RoundDown(Val,1);
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) == 0.001)
      ret = RoundDown(Val,3);
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) == 0.001)
      ret = RoundDown(Val,0);
   return MathMax(ret,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckLotSize(double FixedLotSize)
  {
   double lotSize = RoundtoLots(FixedLotSize);
   double minLotSize = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLotSize = MarketInfo(Symbol(), MODE_MAXLOT);

   if(lotSize < minLotSize)
     {
      Print("Warning: Lot size is too small. Minimum lot size for ", Symbol(), " is ", minLotSize);
      return minLotSize;
     }
   else
      if(lotSize > maxLotSize)
        {
         Print("Warning: Lot size is too large. Maximum lot size for ", Symbol(), " is ", maxLotSize);
         return maxLotSize;
        }

// Lot size is within the valid range
   return lotSize;
  }
//+------------------------------------------------------------------+
bool CanOpenOrder(int OrderTypeCode, double FixedLotSize)
  {
// Add your conditions here to determine if it's suitable to open an order.
// For example, you can check additional trading criteria or risk management rules.

// Return true if the conditions are met.
   string description = "";
   if(CheckVolumeValue(CheckLotSize(FixedLotSize), description) && CheckMoneyForTrade(Symbol(), CheckLotSize(FixedLotSize), OrderTypeCode))
      return true;
   Print("Could not Open Order of type: ",GetOrderTypeString(OrderTypeCode)," with Lots: ",FixedLotSize," - There's not enough volume for that!");
   return false;
  }
//+------------------------------------------------------------------+
double CheckStopLoss(double Price, double StopLoss, int OrderTypeCode)
  {
   if(StopLoss > 0)
     {
      double minStopDistance = 10 * Point + MarketInfo(Symbol(), MODE_STOPLEVEL) * Point + MarketInfo(Symbol(), MODE_SPREAD) * Point;

      Print("CheckStopLoss price:",Price,", - stopLoss:",StopLoss," - minStopDistance:",NormPrice(minStopDistance/Point)," - orderType:",GetOrderTypeString(OrderTypeCode));
      double _stopLoss = NormPrice(StopLoss);
      switch(OrderTypeCode)
        {
         case OP_BUY:
         case OP_BUYSTOP:
         case OP_BUYLIMIT:
            Print("CheckStopLoss price - minStopDistance:",(Price - minStopDistance));
            _stopLoss = NormPrice(MathMin(StopLoss, Price - minStopDistance));
            _stopLoss = MathMin(_stopLoss, NormPrice(Bid - minStopDistance));
            break;
         case OP_SELL:
         case OP_SELLSTOP:
         case OP_SELLLIMIT:
            Print("CheckStopLoss price + minStopDistance:",(Price + minStopDistance));
            _stopLoss = NormPrice(MathMax(StopLoss, Price + minStopDistance));
            _stopLoss = MathMax(_stopLoss, NormPrice(Ask + minStopDistance));
            break;
        }

      Print("CheckStopLoss _stopLoss:",_stopLoss," -- ",NormPrice(MathAbs(_stopLoss - Price)/Point)," > ",(minStopDistance/Point));
      return _stopLoss;
     }
   return StopLoss;
  }
//---------------------------------------------------------------------------
double NormPrice(double Price)
  {
   return(NormalizeDouble(Price, Digits));
  }
//+------------------------------------------------------------------+
int GetBarIndexLastOrderClosed(int OrdersMagicNumber, bool ManageAllOrders = false)
  {
   int totalOrders = OrdersHistoryTotal();
   datetime lastCloseTime = 0;
   int lastClosedBarIndex = -1;

   for(int i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol())
           {
            if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
              {
               continue;
              }
            // Check if the order was closed (not pending or active)
            if(OrderType() <= OP_SELL && OrderCloseTime() > lastCloseTime)
              {
               lastCloseTime = OrderCloseTime();
               lastClosedBarIndex = iBarShift(Symbol(), 0, lastCloseTime);
              }
           }
        }
     }

   return lastClosedBarIndex;
  }

//+------------------------------------------------------------------+
void GetLastOrderTypeAndOpenPrice(int& _Type, double& _OrderOpenPrice, double& _OrderLots, int OrdersMagicNumber, bool ManageAllOrders = false)
  {
   int orderTicket = -1;
   int lastOrderTicket = -1;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
            continue;
      if(OrderSymbol() == Symbol())
        {
         orderTicket = OrderTicket();
         if(orderTicket > lastOrderTicket)
           {
            _Type = OrderType();
            _OrderOpenPrice = OrderOpenPrice();
            _OrderLots = OrderLots();
            lastOrderTicket = orderTicket;
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool ModifyPendingOrder(int Ticket, double NewPrice = 0.0, double NewStopLoss = 0.0, double NewTakeProfit = 0.0, datetime NewExpiration = 0)
  {
   RefreshRates();
   if(OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double newStopLoss = (NewStopLoss > 0.0 ? CheckStopLoss(NewPrice,NewStopLoss,OrderType()) : CheckStopLoss(NewPrice,OrderStopLoss(),OrderType()));
      if(OrderOpenPrice() != NewPrice || OrderStopLoss() != newStopLoss || OrderTakeProfit() != NewTakeProfit || OrderExpiration() != NewExpiration)
        {
         if(OrderModify(OrderTicket(), NewPrice, newStopLoss, NewTakeProfit, NewExpiration, clrCoral))
           {
            Print("OK modifying ",GetOrderTypeString(OrderType())," order ticket", OrderTicket(), "!");
            return true;
           }
         else
           {
            int error = GetLastError();
            if(error == 1)
              {
               Print("Error 1 (ERR_NO_RESULT) while modifying Pending order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Price: ",NewPrice);
               Print("Order Type: ", GetOrderTypeString(OrderType()));
               Print("Stop Loss: ", newStopLoss);
               Print("Take Profit: ", NewTakeProfit);
              }
            if(error == 130)
              {
               Print("Error 130 (ERR_INVALID_STOPS) while modifying Pending order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Price: ",NewPrice);
               Print("Order Type: ", GetOrderTypeString(OrderType()));
               Print("Stop Loss: ", newStopLoss);
               Print("Take Profit: ", NewTakeProfit);
              }
            else
               if(error > 0)
                 {
                  Print("Error modifying ",OrderType()," order. Error code: ", error, " - ", ErrorDescription(error));
                  Print("Details: ", ErrorDescription(error));
                  Print("Order Price: ",NewPrice);
                  Print("Order Type: ", GetOrderTypeString(OrderType()));
                  Print("Stop Loss: ", newStopLoss);
                  Print("Take Profit: ", NewTakeProfit);
                 }
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
int OpenOrder(double LotOpenSize, int Type, double Price = 0.0, double StopLoss = 0.0, double TakeProfit = 0.0, bool Hedged = false, int PriceSlippage = 2, string OrdersComments = "", int OrdersMagicNumber = 0, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   string _hedgeComment = (Hedged == true ? "_HEDGE_" : "");
   int    Error = GetLastError(), ticket = -1;
   double LotOpenValue = CheckLotSize(LotOpenSize);
//---
   if(AccountFreeMargin()>0)
     {
      if(Type==OP_BUY && CanOpenOrder(OP_BUY, LotOpenValue))
        {
         ticket=OrderSend(Symbol(),OP_BUY,LotOpenValue,NormPrice(Price),PriceSlippage,0.0,0.0,OrdersComments+_hedgeComment,OrdersMagicNumber,0,clrBlue);
         if(ticket <= 0 || !OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
           {
            Print("Failed to send BUY order: Error ", ErrorDescription(GetLastError()));
           }
         else
           {
            double takeProfit = (TakeProfit > 0 ? NormPrice(TakeProfit + MarketInfo(Symbol(), MODE_SPREAD) * Point) : OrderTakeProfit());
            double stopLoss = (StopLoss > 0 ? NormPrice(StopLoss - MarketInfo(Symbol(), MODE_SPREAD) * Point) : OrderStopLoss());
            double newStopLossBuy = CheckStopLoss(Price, stopLoss, OP_BUY);
            if((OrderStopLoss() == 0 && newStopLossBuy > 0) || (newStopLossBuy > 0 && newStopLossBuy != OrderStopLoss()))
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newStopLossBuy, takeProfit, 0, clrBlue))
                 {
                  Print("OK modifying BUY order ticket", OrderTicket(), "!");
                 }
               else
                 {
                  int error = GetLastError();
                  if(error == 1)
                    {
                     Print("Error 1 (ERR_NO_RESULT) while modifying BUY order. Details:");
                     Print("Details: ", ErrorDescription(error));
                     Print("Order Type: OP_BUY");
                     Print("Order OpenPrice:", NormPrice(Price));
                     Print("Order Lots: ", LotOpenValue);
                     Print("Stop Loss: ", newStopLossBuy, " vs. ", OrderStopLoss());
                     Print("Take Profit: ", takeProfit);
                    }
                  if(error == 130)
                    {
                     Print("Error 130 (ERR_INVALID_STOPS) while modifying BUY order. Details:");
                     Print("Details: ", ErrorDescription(error));
                     Print("Order Type: OP_BUY");
                     Print("Order OpenPrice:", NormPrice(Price));
                     Print("Order Lots: ", LotOpenValue);
                     Print("Stop Loss: ", newStopLossBuy, " vs. ", OrderStopLoss());
                     Print("Take Profit: ", takeProfit);
                    }
                  else
                     if(error > 0)
                       {
                        Print("Error modifying BUY order. Error code: ", error, " - ", ErrorDescription(error));
                        Print("Details: ", ErrorDescription(error));
                        Print("Order Type: OP_BUY");
                        Print("Order OpenPrice:", NormPrice(Price));
                        Print("Order Lots: ", LotOpenValue);
                        Print("Stop Loss: ", newStopLossBuy, " vs. ", OrderStopLoss());
                        Print("Take Profit: ", takeProfit);
                       }
                 }
           }
        }

      if(Type==OP_BUYSTOP && CanOpenOrder(OP_BUY, LotOpenValue))
        {
         if(Price < Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point + MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
            return -1;
         double takeProfit = (TakeProfit > 0 ? NormPrice(TakeProfit + MarketInfo(Symbol(), MODE_SPREAD) * Point) : 0.0);
         double stopLoss = (StopLoss > 0 ? NormPrice(StopLoss - MarketInfo(Symbol(), MODE_SPREAD) * Point) : 0.0);
         double newStopLossBuy = CheckStopLoss(Price, stopLoss, OP_BUY);
         ticket=OrderSend(Symbol(),OP_BUYSTOP,LotOpenValue,NormPrice(Price),PriceSlippage,newStopLossBuy,takeProfit,OrdersComments+_hedgeComment,OrdersMagicNumber,0,clrBlue);
         if(ticket <= 0 || !OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
           {
            int error = GetLastError();
            Print("Failed to send BUYSTOP order: Error ", ErrorDescription(error));
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_BUYSTOP");
            Print("Order OpenPrice:", NormPrice(Price));
            Print("Order Lots: ", LotOpenValue);
            Print("Stop Loss: ", newStopLossBuy);
            Print("Take Profit: ", takeProfit);
           }
         else
           {
            int error = GetLastError();
            if(error == 1)
              {
               Print("Error 1 (ERR_NO_RESULT) while modifying BUYSTOP order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Type: OP_BUYSTOP");
               Print("Order OpenPrice:", NormPrice(Price));
               Print("Order Lots: ", LotOpenValue);
               Print("Stop Loss: ", newStopLossBuy);
               Print("Take Profit: ", takeProfit);
              }
            if(error == 130)
              {
               Print("Error 130 (ERR_INVALID_STOPS) while modifying BUYSTOP order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Type: OP_BUYSTOP");
               Print("Order OpenPrice:", NormPrice(Price));
               Print("Order Lots: ", LotOpenValue);
               Print("Stop Loss: ", newStopLossBuy);
               Print("Take Profit: ", takeProfit);
              }
            else
               if(error > 0)
                 {
                  Print("Error opening BUYSTOP order. Error code: ", error, " - ", ErrorDescription(error));
                  Print("Details: ", ErrorDescription(error));
                  Print("Order Type: OP_BUYSTOP");
                  Print("Order OpenPrice:", NormPrice(Price));
                  Print("Order Lots: ", LotOpenValue);
                  Print("Stop Loss: ", newStopLossBuy);
                  Print("Take Profit: ", takeProfit);
                 }
           }
        }

      if(Type==OP_SELL && CanOpenOrder(OP_SELL, LotOpenValue))
        {
         ticket=OrderSend(Symbol(),OP_SELL,LotOpenValue,NormPrice(Price),PriceSlippage,0.0,0.0,OrdersComments+_hedgeComment,OrdersMagicNumber,0,clrRed);
         if(ticket <= 0 || !OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
           {
            Print("Failed to send SELL order: Error ", ErrorDescription(GetLastError()));
           }
         else
           {
            double takeProfit = (TakeProfit > 0 ? NormPrice(TakeProfit - MarketInfo(Symbol(), MODE_SPREAD) * Point) : OrderTakeProfit());
            double stopLoss = (StopLoss > 0 ? NormPrice(StopLoss + MarketInfo(Symbol(), MODE_SPREAD) * Point) : OrderStopLoss());
            double newStopLossSell = CheckStopLoss(Price, stopLoss, OP_SELL);
            if((OrderStopLoss() == 0 && newStopLossSell > 0) || (newStopLossSell > 0 && newStopLossSell != OrderStopLoss()))
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newStopLossSell, takeProfit, 0, clrRed))
                 {
                  Print("OK modifying SELL order ticket", OrderTicket(), "!");
                 }
               else
                 {
                  int error = GetLastError();
                  if(error == 1)
                    {
                     Print("Error 1 (ERR_NO_RESULT) while modifying SELL order. Details:");
                     Print("Details: ", ErrorDescription(error));
                     Print("Order Type: OP_SELL");
                     Print("Order OpenPrice:", NormPrice(Price));
                     Print("Order Lots: ", LotOpenValue);
                     Print("Stop Loss: ", newStopLossSell);
                     Print("Take Profit: ", takeProfit);
                    }
                  if(error == 130)
                    {
                     Print("Error 130 (ERR_INVALID_STOPS) while modifying SELL order. Details:");
                     Print("Details: ", ErrorDescription(error));
                     Print("Order Type: OP_SELL");
                     Print("Order OpenPrice:", NormPrice(Price));
                     Print("Order Lots: ", LotOpenValue);
                     Print("Stop Loss: ", newStopLossSell);
                     Print("Take Profit: ", takeProfit);
                    }
                  else
                     if(error > 0)
                       {
                        Print("Error modifying SELL order. Error code: ", error, " - ", ErrorDescription(error));
                        Print("Details: ", ErrorDescription(error));
                        Print("Order Type: OP_SELL");
                        Print("Order OpenPrice:", NormPrice(Price));
                        Print("Order Lots: ", LotOpenValue);
                        Print("Stop Loss: ", newStopLossSell);
                        Print("Take Profit: ", takeProfit);
                       }
                 }
           }
        }

      if(Type==OP_SELLSTOP && CanOpenOrder(OP_SELL, LotOpenValue))
        {
         if(Price > Bid - MarketInfo(Symbol(),MODE_SPREAD)*Point - MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
            return -1;
         double takeProfit = (TakeProfit > 0 ? NormPrice(TakeProfit - MarketInfo(Symbol(), MODE_SPREAD) * Point) : 0.0);
         double stopLoss = (StopLoss > 0 ? NormPrice(StopLoss + MarketInfo(Symbol(), MODE_SPREAD) * Point) : 0.0);
         double newStopLossSell = CheckStopLoss(Price, stopLoss, OP_SELL);
         ticket=OrderSend(Symbol(),OP_SELLSTOP,LotOpenValue,NormPrice(Price),PriceSlippage,newStopLossSell,takeProfit,OrdersComments+_hedgeComment,OrdersMagicNumber,0,clrRed);
         if(ticket <= 0 || !OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
           {
            int error = GetLastError();
            Print("Failed to send SELLSTOP order: Error ", ErrorDescription(error));
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_SELLSTOP");
            Print("Order OpenPrice:", NormPrice(Price));
            Print("Order Lots: ", LotOpenValue);
            Print("Stop Loss: ", newStopLossSell);
            Print("Take Profit: ", takeProfit);
           }
         else
           {
            int error = GetLastError();
            if(error == 1)
              {
               Print("Error 1 (ERR_NO_RESULT) while modifying SELLSTOP order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Type: OP_SELLSTOP");
               Print("Order OpenPrice:", NormPrice(Price));
               Print("Order Lots: ", LotOpenValue);
               Print("Stop Loss: ", newStopLossSell);
               Print("Take Profit: ", takeProfit);
              }
            if(error == 130)
              {
               Print("Error 130 (ERR_INVALID_STOPS) while modifying SELLSTOP order. Details:");
               Print("Details: ", ErrorDescription(error));
               Print("Order Type: OP_SELLSTOP");
               Print("Order OpenPrice:", NormPrice(Price));
               Print("Order Lots: ", LotOpenValue);
               Print("Stop Loss: ", newStopLossSell);
               Print("Take Profit: ", takeProfit);
              }
            else
               if(error > 0)
                 {
                  Print("Error opening SELLSTOP order. Error code: ", error, " - ", ErrorDescription(error));
                  Print("Details: ", ErrorDescription(error));
                  Print("Order Type: OP_SELLSTOP");
                  Print("Order OpenPrice:", NormPrice(Price));
                  Print("Order Lots: ", LotOpenValue);
                  Print("Stop Loss: ", newStopLossSell);
                  Print("Take Profit: ", takeProfit);
                 }
           }
        }
     }

   return ticket;
  }
//---------------------------------------------------------------------------
void CloseAll(int OrdersMagicNumber, int PriceSlippage, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   bool   Result=false;
   int    i,Pos,Error=GetLastError();
   int    Total=OrdersTotal();

   if(Total>0)
     {
      for(i=Total-1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == TRUE)
           {
            if(OrderSymbol()==Symbol())
              {
               if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
                 {
                  continue;
                 }
               Pos=OrderType();
               if(Pos==OP_BUY)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Bid, PriceSlippage, Blue);
                 }
               if(Pos==OP_SELL)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Ask, PriceSlippage, Red);
                 }
               if((Pos==OP_BUYSTOP)||(Pos==OP_SELLSTOP)||(Pos==OP_BUYLIMIT)||(Pos==OP_SELLLIMIT))
                 {
                  Result=OrderDelete(OrderTicket(), CLR_NONE);
                 }
               //-----------------------
               if(Result!=true)
                 {
                  Error=GetLastError();
                  Print("LastError = ",ErrorDescription(Error));
                 }
               else
                  Error=0;
               //-----------------------
              }//if
           }//if
        }//for
     }//if

   Sleep(20);
   return;
  }
//+------------------------------------------------------------------+
void CloseLosers(int OrdersMagicNumber, int PriceSlippage, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   bool   Result=false;
   int    i,Pos,Error=GetLastError();
   int    Total=OrdersTotal();

   if(Total>0)
     {
      for(i=Total-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && OrderProfit() < 0)
              {
               if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
                 {
                  continue;
                 }
               Pos=OrderType();
               if(Pos==OP_BUY)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Bid, PriceSlippage, clrBlue);
                 }
               if(Pos==OP_SELL)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Ask, PriceSlippage, clrRed);
                 }
               //-----------------------
               if(Result!=true)
                 {
                  Error=GetLastError();
                 }
               else
                  Error=0;
               //-----------------------
              }//if
           }//if
        }//for
     }//if

   Sleep(20);
   return;
  }
//+------------------------------------------------------------------+
int CloseHedge(int OrdersMagicNumber, int PriceSlippage, int OrderTypeCode, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   bool   Result=false;
   int    i,Pos,Error=GetLastError();
   int    Total=OrdersTotal();
   int    countClosed = 0;

   if(Total>0)
     {
      for(i=Total-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && OrderType() == OrderTypeCode && StringFind(OrderComment(), "_HEDGE_", 0) >= 0)
              {
               if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
                 {
                  continue;
                 }
               Pos=OrderType();
               if(Pos==OP_BUY)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Bid, PriceSlippage, clrBlue);
                  if(Result)
                    {
                     countClosed++;
                    }
                 }
               if(Pos==OP_SELL)
                 {
                  Result=OrderClose(OrderTicket(), OrderLots(), Ask, PriceSlippage, clrRed);
                  if(Result)
                    {
                     countClosed++;
                    }
                 }
               //-----------------------
               if(Result!=true)
                 {
                  Error=GetLastError();
                 }
               else
                  Error=0;
               //-----------------------
              }//if
           }//if
        }//for
     }//if

   Sleep(20);
   return countClosed;
  }
//---------------------------------------------------------------------------
void DeleteAllPendingOrders(int OrdersMagicNumber, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   bool   Result=false;
   int    i,Pos,Error=GetLastError();
   int    Total=OrdersTotal();

   if(Total>0)
     {
      for(i=Total-1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == TRUE)
           {
            if(OrderSymbol()==Symbol())
              {
               if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
                 {
                  continue;
                 }
               Pos=OrderType();
               if((Pos==OP_BUYSTOP)||(Pos==OP_SELLSTOP)||(Pos==OP_BUYLIMIT)||(Pos==OP_SELLLIMIT))
                 {
                  Result=OrderDelete(OrderTicket(), CLR_NONE);
                 }
               //-----------------------
               if(Result!=true)
                 {
                  Error=GetLastError();
                  Print("LastError = ",ErrorDescription(Error));
                 }
               else
                  Error=0;
               //-----------------------
              }//if
           }//if
        }//for
     }//if
   return;
  }
//---------------------------------------------------------------------------
void ResetPendingOrders(int Type, int OrdersMagicNumber, bool ManageAllOrders = false)
  {
   RefreshRates();
//---
   bool   Result=false;
   int    i,Pos,Error=GetLastError();
   int    Total=OrdersTotal();

   if(Total>0)
     {
      for(i=Total-1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == TRUE)
           {
            if(OrderSymbol()==Symbol() && OrderType() == Type)
              {
               if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
                 {
                  continue;
                 }
               Pos=OrderType();
               if((Pos==OP_BUYSTOP)||(Pos==OP_SELLSTOP)||(Pos==OP_BUYLIMIT)||(Pos==OP_SELLLIMIT))
                 {
                  Result=OrderDelete(OrderTicket(), CLR_NONE);
                 }
               //-----------------------
               if(Result!=true)
                 {
                  Error=GetLastError();
                  Print("LastError = ",ErrorDescription(Error));
                 }
               else
                  Error=0;
               //-----------------------
              }//if
           }//if
        }//for
     }//if
   return;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Lot Size Computation Functions                                   |
//+------------------------------------------------------------------+

enum LotSizeCalcMode { ByFixedSize, ByAccountPercentageToRisk, ByAmountToRisk, ByPercentageToRisk, ByPerecentageToRiskAndStopLoss };

//---------------------------------------------------------------------------
double CalcLotWithTP(double TakeProfit, double StartPrice, double EndPrice)
  {
// Calculating the Lotsize of a Trade with a TakeProfit Parameter in Monetary amount
   if(StartPrice == EndPrice)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double ret = TakeProfit/SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE)/MathAbs(StartPrice-EndPrice)*Point();
   double roundedVal  = 0.0;
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP) == 0.01)
      roundedVal = Round(ret,2) >= ret? Round(ret,2) : Round(ret,2)+ 0.01;
   else
      if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP) == 0.1)
         roundedVal = Round(ret,1) >= ret? Round(ret,1) : Round(ret,1)+ 0.1;
      else
         if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP) == 0.001)
            roundedVal = Round(ret,3) >= ret? Round(ret,3) : Round(ret,3)+ 0.001;
         else
            roundedVal = Round(ret,0) >= ret? Round(ret,0) : Round(ret,0)+ 1;
   if(roundedVal < SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN))
      return SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   return roundedVal;
  }
//---------------------------------------------------------------------------
double CalcLotByDistance(double TakeProfit, double DistanceToCompensate, double LotsToCompensate, double LotsMuxRecovery = 1)
  {
   if(LotsMuxRecovery == 0 || LotsToCompensate == 0)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double targetProfitPoints = TakeProfit*Point + MarketInfo(Symbol(), MODE_SPREAD)*Point;
   double pipsDistance = DistanceToCompensate*Point;
   if(MathMod(Digits,2) == 1)
     {
      pipsDistance /= 10.0;
     }
   double lotSize = MathMax(CheckLotSize(LotsMuxRecovery * LotsToCompensate), CheckLotSize((LotsMuxRecovery * pipsDistance * LotsToCompensate) / targetProfitPoints));

   return lotSize;
  }
//---------------------------------------------------------------------------
double CalcLotByAmountToRisk(double BalancePercentagePerTrade, double DollarsAtRisk)
  {
   if(BalancePercentagePerTrade == 0 || DollarsAtRisk == 0)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double lotSize = CheckLotSize((AccountBalance() * (BalancePercentagePerTrade / 100.0)) / DollarsAtRisk);

   return lotSize;
  }
//---------------------------------------------------------------------------
double CalcLotByPercentageToRisk(double DollarsPerTrade, double BalancePercentageAtRisk)
  {
   if(DollarsPerTrade == 0 || BalancePercentageAtRisk == 0)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double balanceAtRisk = (AccountBalance() * (BalancePercentageAtRisk / 100.0));
   double lotSize = CheckLotSize(DollarsPerTrade / balanceAtRisk);

   return lotSize;
  }
//+------------------------------------------------------------------+
double CalcLotByPerecentageToRiskAndStopLoss(double BalancePercentageAtRisk, double StopLossPointsPerTrade)
  {
   if(BalancePercentageAtRisk == 0 || StopLossPointsPerTrade == 0)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double lotSize = MarketInfo(Symbol(), MODE_MINLOT);
   if(StopLossPointsPerTrade > 0)
     {
      lotSize = CheckLotSize((AccountBalance() * (BalancePercentageAtRisk / 100.0)) / StopLossPointsPerTrade);
      Print("[CalcLotByPerecentageToRiskAndStopLoss] Risk(%): ",(AccountBalance() * (BalancePercentageAtRisk / 100.0))," - StopLossPointsPerTrade:",StopLossPointsPerTrade," - Lots: ",lotSize);
     }

   return lotSize;
  }
//---------------------------------------------------------------------------
double CalcLotByAccountPercentageToRisk(double BalancePercentagePerTrade)
  {
   if(BalancePercentagePerTrade == 0)
      return MarketInfo(Symbol(), MODE_MINLOT);
   double dollarsPerTrade = (AccountBalance() * (BalancePercentagePerTrade / 100.0));
   double lotSize = CheckLotSize(dollarsPerTrade / AccountBalance());

   return lotSize;
  }
//+------------------------------------------------------------------+
//| Trailing Stop Functions                                          |
//+------------------------------------------------------------------+
enum TakeProfitType { CloseAtProfit, TrailAtProfit };
enum TrailingProfitType { Instrumented, ByATR, ByFractals, ByMA };

//+------------------------------------------------------------------+
void InstrumentedTrailingStop(int OrdersMagicNumber, bool ManageAllOrders = false, double TrailingStopActivationPoints = 0.0, double TrailingStopDeltaPoints = 40.0)
  {
   ResetLastError();
//---
   int totalOrders = OrdersTotal();

   double currentProfit = AccountEquity() - AccountBalance();
   double newStopLossBuy = 0.0;
   double newStopLossSell = 0.0;

   for(int i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
              {
               continue;
              }
            if(OrderType() == OP_BUY)
              {
               if(TrailingStopActivationPoints > 0 && Bid > OrderOpenPrice() + TrailingStopActivationPoints * Point + MarketInfo(Symbol(), MODE_SPREAD) * Point)
                 {
                  newStopLossBuy = CheckStopLoss(Bid, Bid + TrailingStopDeltaPoints, OP_BUY);
                 }
               if((OrderStopLoss() == 0 && newStopLossBuy > 0) || (newStopLossBuy > 0 && newStopLossBuy > OrderStopLoss()))
                  if(OrderModify(OrderTicket(), 0, newStopLossBuy, OrderTakeProfit(), 0, clrNONE))
                    {
                     Print("OK modifying BUY order ticket", OrderTicket(), "!");
                    }
                  else
                    {
                     int error = GetLastError();
                     if(error == 1)
                       {
                        Print("Error 1 (ERR_NO_RESULT) while modifying BUY order. Details:");
                        Print("Details: ", ErrorDescription(error));
                        Print("Order Type: OP_BUY");
                        Print("Stop Loss: ", newStopLossBuy);
                        Print("Take Profit: ", OrderTakeProfit());
                       }
                     if(error == 130)
                       {
                        Print("Error 130 (ERR_INVALID_STOPS) while modifying BUY order. Details:");
                        Print("Details: ", ErrorDescription(error));
                        Print("Order Type: OP_BUY");
                        Print("Stop Loss: ", newStopLossBuy);
                        Print("Take Profit: ", OrderTakeProfit());
                       }
                     else
                        if(error > 0)
                          {
                           Print("Error modifying BUY order. Error code: ", error, " - ", ErrorDescription(error));
                          }
                    }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  if(TrailingStopActivationPoints > 0 && Ask < OrderOpenPrice() - TrailingStopActivationPoints * Point - MarketInfo(Symbol(), MODE_SPREAD) * Point)
                    {
                     newStopLossSell = CheckStopLoss(Ask, Ask - TrailingStopDeltaPoints, OP_SELL);
                    }
                  if((OrderStopLoss() == 0 && newStopLossSell > 0) || (newStopLossSell > 0 && newStopLossSell < OrderStopLoss()))
                     if(OrderModify(OrderTicket(), 0, newStopLossSell, OrderTakeProfit(), 0, clrNONE))
                       {
                        Print("OK modifying SELL order ticket", OrderTicket(), "!");
                       }
                     else
                       {
                        int error = GetLastError();
                        if(error == 1)
                          {
                           Print("Error 1 (ERR_NO_RESULT) while modifying SELL order. Details:");
                           Print("Details: ", ErrorDescription(error));
                           Print("Order Type: OP_SELL");
                           Print("Stop Loss: ", newStopLossSell);
                           Print("Take Profit: ", OrderTakeProfit());
                          }
                        if(error == 130)
                          {
                           Print("Error 130 (ERR_INVALID_STOPS) while modifying SELL order. Details:");
                           Print("Details: ", ErrorDescription(error));
                           Print("Order Type: OP_SELL");
                           Print("Stop Loss: ", newStopLossSell);
                           Print("Take Profit: ", OrderTakeProfit());
                          }
                        else
                           if(error > 0)
                             {
                              Print("Error modifying SELL order. Error code: ", error, " - ", ErrorDescription(error));
                             }
                       }
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Trailing by ATR (ref. https://www.mql5.com/en/code/7108 by Yuri Dzyuban)
// Parameters:
//  atr_timeframe - the timeframe to calculate the ATR value (options - 1, 5, 15, 30, 60, 240, 1440, 10080, 43200);
//  atr1_period - the period of the first ATR (greater than 0; can be same as atr2_period, but it is recommended to set it to a different value, as mentioned above);
//  atr1_shift - the "window" shift for the first ATR, in which the ATR value is calculated, specified number of bars back (non-negative integer) relative to the current bar;
//  atr2_period - the period of the second ATR (greater than 0);
//  atr2_shift - the "window" shift for the second ATR in which the ATR value is calculated, specified number of bars back (non-negative integer) relative to the current bar;
//  coeff - the stop loss is calculated as ATR*coeff, i.e. this is the coefficient for determining the number of the ATR distances from the current price to place the stop loss;
//  trlinloss - >whether to move the stop loss in an "unprofitable" area, i.e. in the interval between the initial stop loss and the opening price (true - trail, false - trailing is only activated if the new stop loss is "better" than the opening price, "in profit").
//+------------------------------------------------------------------+
void TrailingByATR(int OrdersMagicNumber, bool ManageAllOrders = false, int atr_timeframe = PERIOD_CURRENT, int atr1_period = 5, int atr1_shift = 1, int atr2_period = 36, int atr2_shift = 1, double coeff = 1, bool trlinloss = false)
  {
   ResetLastError();
//---
   if((atr1_period<1) || (atr2_period<1) || (coeff<=0) || (atr1_shift<0) || (atr2_shift<0))
     {
      Print("[TrailingByATR] Invalid Parameter");
      return;
     }

   double curr_atr1;
   double curr_atr2;
   double best_atr;
   double atrXcoeff;
   double newstop;

   curr_atr1 = iATR(Symbol(),atr_timeframe,atr1_period,atr1_shift);
   curr_atr2 = iATR(Symbol(),atr_timeframe,atr2_period,atr2_shift);

   best_atr = MathMax(curr_atr1,curr_atr2);
   atrXcoeff = best_atr * coeff;

   int totalOrders = OrdersTotal();
   for(int i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
              {
               continue;
              }
            if(OrderType()==OP_BUY)
              {
               newstop = CheckStopLoss(OrderClosePrice(),Bid - atrXcoeff,OP_BUY);
               if(newstop > 0 && OrderStopLoss() != newstop)
                 {
                  if(trlinloss==true)
                    {
                     if((OrderStopLoss()==0) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                     else
                       {
                        if((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                           if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                              Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                  else
                    {
                     if((OrderStopLoss()==0) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                     else
                       {
                        if((newstop>OrderStopLoss()) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                           if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                              Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                 }
              }

            if(OrderType()==OP_SELL)
              {
               newstop = CheckStopLoss(OrderClosePrice(),Ask + atrXcoeff,OP_SELL);
               if(newstop > 0 && OrderStopLoss() != newstop)
                 {
                  if(trlinloss==true)
                    {
                     if((OrderStopLoss()==0) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                     else
                       {
                        if((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                           if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                              Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                  else
                    {
                     if((OrderStopLoss()==0) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                     else
                       {
                        if((newstop<OrderStopLoss()) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                           if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
                              Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Trailing by X-bar fractals (ref. https://www.mql5.com/en/code/7108 by Yuri Dzyuban)
// Parameters:
//  tmfrm - the timeframe, the bars of which are used for trailing;
//  bars_n - the number of bars included in the fractal (not less than 3);
//  indent - the indent(in points) from the extremum of the latest fractal to place the stop loss (not less than 0);
//  trlinloss - whether to move the stop loss in an "unprofitable" area, i.e. in the interval between the initial stop loss and the opening price (true - trail, false - trailing is only activated if the new stop loss is "better" than the opening price, "in profit").
//+------------------------------------------------------------------+
void TrailingByFractals(int OrdersMagicNumber, bool ManageAllOrders = false, int tmfrm = PERIOD_CURRENT, int frktl_bars = 5, int indent = 3, bool trlinloss = false)
  {
   int i, z;
   int extr_n;
   double temp;
   int after_x, be4_x;
   int ok_be4, ok_after;
   int sell_peak_n = 0, buy_peak_n = 0;

   if((frktl_bars<=3) || (indent<0))
     {
      Print("[TrailingByFractals] Invalid Parameter");
      return;
     }

   temp = frktl_bars;

   if(MathMod(frktl_bars,2)==0)
      extr_n = int(temp/2);
   else
      extr_n = int(MathRound(temp/2));

   after_x = frktl_bars - extr_n;
   if(MathMod(frktl_bars,2)!=0)
      be4_x = frktl_bars - extr_n;
   else
      be4_x = frktl_bars - extr_n - 1;

   int totalOrders = OrdersTotal();
   for(i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
              {
               continue;
              }
            if(OrderType()==OP_BUY)
              {
               for(i=extr_n; i<iBars(Symbol(),tmfrm); i++)
                 {
                  ok_be4 = 0;
                  ok_after = 0;

                  for(z=1; z<=be4_x; z++)
                    {
                     if(iLow(Symbol(),tmfrm,i)>=iLow(Symbol(),tmfrm,i-z))
                       {
                        ok_be4 = 1;
                        break;
                       }
                    }

                  for(z=1; z<=after_x; z++)
                    {
                     if(iLow(Symbol(),tmfrm,i)>iLow(Symbol(),tmfrm,i+z))
                       {
                        ok_after = 1;
                        break;
                       }
                    }

                  if((ok_be4==0) && (ok_after==0))
                    {
                     sell_peak_n = i;
                     break;
                    }
                 }

               double newStopLoss = CheckStopLoss(OrderClosePrice(),iLow(Symbol(),tmfrm,sell_peak_n)-(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OP_BUY);
               if(newStopLoss > 0 && OrderStopLoss() != newStopLoss)
                 {
                  if(trlinloss==true)
                    {
                     if((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                  else
                    {
                     if((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>OrderOpenPrice()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                 }
              }

            if(OrderType()==OP_SELL)
              {
               for(i=extr_n; i<iBars(Symbol(),tmfrm); i++)
                 {
                  ok_be4 = 0;
                  ok_after = 0;

                  for(z=1; z<=be4_x; z++)
                    {
                     if(iHigh(Symbol(),tmfrm,i)<=iHigh(Symbol(),tmfrm,i-z))
                       {
                        ok_be4 = 1;
                        break;
                       }
                    }

                  for(z=1; z<=after_x; z++)
                    {
                     if(iHigh(Symbol(),tmfrm,i)<iHigh(Symbol(),tmfrm,i+z))
                       {
                        ok_after = 1;
                        break;
                       }
                    }

                  if((ok_be4==0) && (ok_after==0))
                    {
                     buy_peak_n = i;
                     break;
                    }
                 }

               double newStopLoss = CheckStopLoss(OrderClosePrice(),iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OP_SELL);
               if(newStopLoss > 0 && OrderStopLoss() != newStopLoss)
                 {
                  if(trlinloss==true)
                    {
                     if(((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0)) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                  else
                    {
                     if((((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0))) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderOpenPrice()) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                           Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Trailing by moving average (ref. https://www.mql5.com/en/code/7108 by Yuri Dzyuban)
// Parameters:
//  iTmFrme - the chart period to calculate the moving average; allowed input options: 1 (M1), 5 (M5), 15 (M15), 30 (M30), 60 (H1), 240 (H4), 1440 (D), 10080 (W), 43200 (MN);
//  iMAPeriod - the period of averaging for calculation of the moving average;
//  iMAShift - shift of the indicator relative to the price chart;
//  iMAMethod - method of averaging; allowed input options: 0 (MODE_SMA), 1 (MODE_EMA), 2 (MODE_SMMA), 3 (MODE_LWMA);
//  iApplPrice - applied price; input options: 0 (PRICE_CLOSE), 1 (PRICE_OPEN), 2 (PRICE_HIGH), 3 (PRICE_LOW), 4 (PRICE_MEDIAN), 5 (PRICE_TYPICAL), 6 (PRICE_WEIGHTED);
//  iShift - shift relative to the current bar by the specified number of periods back;
//  iIndent - the indent (in points) from the MA value to place the stop loss.
//+------------------------------------------------------------------+
void TrailingByMA(int OrdersMagicNumber, bool ManageAllOrders = false, int iTmFrme = PERIOD_CURRENT, int iMAPeriod = 21, int iMAShift = 0, int MAMethod = 0, int iApplPrice = 0, int iShift = 1, int iIndent = 3)
  {
   if((iMAPeriod<2) || (MAMethod<0) || (MAMethod>3) || (iApplPrice<0) || (iApplPrice>6) || (iShift<0) || (iIndent<0))
     {
      Print("[TrailingByMA] Invalid Parameter");
      return;
     }

   double dMA;

   dMA = iMA(Symbol(),iTmFrme,iMAPeriod,iMAShift,MAMethod,iApplPrice,iShift);

   int totalOrders = OrdersTotal();
   for(int i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(!ManageAllOrders && OrderMagicNumber()!=OrdersMagicNumber)
              {
               continue;
              }
            if(OrderType()==OP_BUY)
              {
               double newStopLoss = CheckStopLoss(OrderClosePrice(),dMA-(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point,OP_BUY);
               if(newStopLoss > 0 && OrderStopLoss() != newStopLoss)
                 {
                  if((OrderStopLoss()<dMA-iIndent*Point) && (dMA-(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                        Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                    }
                 }
              }

            if(OrderType()==OP_SELL)
              {
               double newStopLoss = CheckStopLoss(OrderClosePrice(),dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point,OP_SELL);
               if(newStopLoss > 0 && OrderStopLoss() != newStopLoss)
                 {
                  if(((OrderStopLoss()==0) || (OrderStopLoss()>dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point)) && (dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),OrderExpiration()))
                        Print("Failed to modify order #",OrderTicket(),". Error: ",GetLastError());
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
