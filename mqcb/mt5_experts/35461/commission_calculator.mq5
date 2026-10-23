//+------------------------------------------------------------------+
//|                                        Commission Calculator.mq5 |
//|                                       Copyright 2021, Dark Ryd3r |
//|                                   https://twitter.com/DarkrRyd3r |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkrRyd3r"
#property version   "1.00"
#property description   "Calculates Commission Fee such as Brokerage charged by Brokers in the end of calculation in Strategy Tester"

#include <Trade\Trade.mqh>
CTrade trade;
double Fee=0;
double LastFee=0;
double TotalFee=0;

bool bln_find_order=false;
ulong ul_find_order=0;

input double qty = 0.001; //Enter quantity for order
input double entryprice = 31365; //Enter Entry Price
input double Sl = 31200;// Enter Stop Loss
input double Tp = 32100; // Enter Take Profit
input double CommissionRate = 0.04; //Fee in percentage

enum BuyorSell {
   None,
   Buy, //Market Order Buy
   Sell, //Market Order Sell
   BuyLimit, //Limit Buy Order
   SellLimit, //Limit Sell Order
   BuyStop, //Buy Stop Order
   SellStop //Sell Stop Order
};

input BuyorSell SelectMode = None;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Print(
      "Initial Balance: "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), _Digits), ", "
      "Brokerage Fee: "+DoubleToString(+TotalFee+LastFee, 8), ", "
      "Final Balance (including Fee): "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)-TotalFee+LastFee, 8)
   );
//---
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   if(bln_find_order) {
      static long counter=0;
      ResetLastError();
      if(HistoryOrderSelect(ul_find_order)) {
         long type_order=HistoryOrderGetInteger(ul_find_order,ORDER_TYPE);
         if(type_order==ORDER_TYPE_BUY || type_order==ORDER_TYPE_BUY_LIMIT || type_order==ORDER_TYPE_BUY_STOP || type_order==ORDER_TYPE_BUY_STOP_LIMIT ||
               type_order==ORDER_TYPE_SELL || type_order==ORDER_TYPE_SELL_LIMIT || type_order==ORDER_TYPE_SELL_STOP || type_order==ORDER_TYPE_SELL_STOP_LIMIT) {

            ExecuteStatus();
            bln_find_order=false;
            counter=0;
            return;
         } else {

            bln_find_order=false;
            return;
         }
      } else {
         Print("Order ",ul_find_order," is not found, error#",GetLastError());
      }
      counter++;
   }

//---
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

//Market
   if (SelectMode== Buy) {
      if ( (OrdersTotal()==0 ) && (PositionsTotal()==0) )  {
         trade.Buy(qty,_Symbol,Ask,Sl,Tp,"Market order : Buy Executed");
      }
   }
   if (SelectMode== Sell) {
      if ( (OrdersTotal()==0 ) && (PositionsTotal()==0) )  {
         trade.Sell(qty,_Symbol,Bid,Sl,Tp,"Market order : Sell Executed");
      }
   }

//Limit
   if (SelectMode== BuyLimit) {
      if( (OrdersTotal()==0 ) && (PositionsTotal()<1) ) {
         trade.BuyLimit(qty, entryprice,_Symbol,Sl,Tp,ORDER_TIME_GTC,0,"Limit Order : Buy Executed");
      }
   }
   if (SelectMode== SellLimit) {
      if ( (OrdersTotal()==0 ) && (PositionsTotal()==0) )  {
         trade.SellLimit(qty, entryprice,_Symbol,Sl,Tp,ORDER_TIME_GTC,0,"Limit Order : Sell Executed");
      }
   }

//Stop
   if (SelectMode== BuyStop) {
      if( (OrdersTotal()==0 ) && (PositionsTotal()==0) ) {
         trade.BuyStop(qty, entryprice,_Symbol,Sl,Tp,ORDER_TIME_GTC,0,"Stop Order : Buy Executed");
      }
   }
   if (SelectMode== SellStop) {
      if( (OrdersTotal()==0 ) && (PositionsTotal()==0) ) {
         trade.SellStop(qty, entryprice,_Symbol,Sl,Tp,ORDER_TIME_GTC,0,"Stop Order : Sell Executed");
      }
   }

}

//+------------------------------------------------------------------+
//|  Calculate the Brokerage                                         |
//+------------------------------------------------------------------+
void ExecuteStatus () {
   if (HistorySelect(0, INT_MAX) && (HistoryDealsTotal() > 0)) {
      double ExPricelast=0;
      double ExPriceQty = 0;
      double ExPriceProfit =0;
      uint   total=HistoryDealsTotal();

      ulong ticket = HistoryDealGetTicket(total -1);
      ExPricelast = HistoryDealGetDouble(ticket, DEAL_PRICE);
      ExPriceQty = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      ExPriceProfit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      Fee = ExPricelast*ExPriceQty*(CommissionRate/100);
      long deal_type          =HistoryDealGetInteger(ticket,DEAL_TYPE);
      long deal_entry         =HistoryDealGetInteger(ticket,DEAL_ENTRY);
      string deal_comment     =HistoryDealGetString(ticket,DEAL_COMMENT);
      Print("Brokerage Fee: ", Fee, ", Profit: ", ExPriceProfit);


      TotalFee += Fee;
   }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
   if(type==TRADE_TRANSACTION_DEAL_ADD) {
      bln_find_order=true;
      ul_find_order=trans.order;
      string   deal_comment      ="";
      long     deal_entry        =-1;
      if(HistoryDealSelect(trans.deal)) {

         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         Print("D: ", deal_comment);
      }
   }
}
//+------------------------------------------------------------------+
double OnTester() {
   if (HistorySelect(TimeCurrent(), INT_MAX) && HistoryDealsTotal()) {
      const ulong Ticket = HistoryDealGetTicket(HistoryDealsTotal() - 1);

      string deal_C = HistoryDealGetString(Ticket,DEAL_COMMENT);

      if(deal_C=="end of test") {
         double LastPricelast = HistoryDealGetDouble(Ticket, DEAL_PRICE);
         double LastPriceQty = HistoryDealGetDouble(Ticket, DEAL_VOLUME);
         double LastPriceProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT);
         LastFee =  LastPricelast*LastPriceQty*(CommissionRate/100);
      } else {
         Print("Error : end of test not found");
      }
   }

   return(0);
}
//+------------------------------------------------------------------+
