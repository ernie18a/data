//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq4 |
//|                                          Copyright 2017,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
//Modify_SL_TP_ALL_Symbol  --- Modify all symbols with the same inputs
//https://www.mql5.com/en/code/18011
#property copyright "Copyright 2017,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "1.00"
#property strict
#property show_inputs
#include <stdlib.mqh>
input double InpStopLoss=200.0; // StopLoss Pips
input double InpTakeProfit=200.0; //TakeProfit Pips
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(OrdersTotal()==0)  return;
   if(!IsTradeAllowed()){Alert("Autotrade is NOT allowed.");  return;}

   double  TakeProfit=0.0;
   double  StopLoss=0.0;
   int     Slippage=0.0;
   color   clr=clrNONE;

   StopLoss   = InpStopLoss;
   TakeProfit = InpTakeProfit;

   if(StopLoss==0 && TakeProfit==0){Alert(" No SL/TP need to be modified");return;}

   double sl=0.0,tp=0.0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))break;

      string sym = OrderSymbol();
      double bid = SymbolInfoDouble(sym,SYMBOL_BID);
      double point=SymbolInfoDouble(sym,SYMBOL_POINT);
      int    digits=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
      int pt=1;
      if(digits==5 || digits==3)pt=10;

      double tpbuy = NormalizeDouble(bid + TakeProfit*pt*point,digits);
      double slbuy = NormalizeDouble(bid - StopLoss*pt*point,digits);

      double tpsell = NormalizeDouble(bid - TakeProfit*pt*point,digits);
      double slsell = NormalizeDouble(bid + StopLoss*pt*point,digits);

      //if(OrderType()<2)
        {
         if(OrderType()==0 || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
           {
            if(StopLoss  !=0)sl = slbuy;else sl =OrderStopLoss();   sl=NormalizeDouble(sl,digits);
            if(TakeProfit!=0)tp = tpbuy;else tp=OrderTakeProfit(); tp=NormalizeDouble(tp,digits); clr=clrNONE;
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
               Print("Ticket#",OrderTicket(),",OrderModify Error: ",ErrorDescription(GetLastError()));
           }
         else if(OrderType()==1 || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
           {
            if(StopLoss  !=0) sl=slsell;else sl=OrderStopLoss();    sl=NormalizeDouble(sl,digits);
            if(TakeProfit!=0) tp=tpsell;else tp=OrderTakeProfit();  tp=NormalizeDouble(tp,digits);  clr=clrNONE;
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
               Print("Ticket#",OrderTicket(),",OrderModify Error: ",ErrorDescription(GetLastError()));
           }
        }
     }//for

  }
//+------------------------------------------------------------------+
