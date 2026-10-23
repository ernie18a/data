//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq4 |
//|                                          Copyright 2017,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "2.00"
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
   double  TakeProfit=0.0;
   double  StopLoss=0.0;
   int     Slippage=0.0;
   color   clr=clrNONE;

   StopLoss   = InpStopLoss;
   TakeProfit = InpTakeProfit;

   if(Digits()==5 || Digits()==3)
     {
      TakeProfit*=10;
      StopLoss*=10;
     }
   if(OrdersTotal()==0)  return;

   if(!IsTradeAllowed()){Alert("Autotrade is NOT allowed.");  return;}

   if(StopLoss==0 && TakeProfit==0){Alert(" No SL/TP need to be modified");return;}

   double tpbuy = NormalizeDouble(Bid + TakeProfit*Point,Digits);
   double slbuy = NormalizeDouble(Bid - StopLoss*Point,Digits);

   double tpsell = NormalizeDouble(Bid - TakeProfit*Point,Digits);
   double slsell = NormalizeDouble(Bid + StopLoss*Point,Digits);

   double sl=0.0,tp=0.0;

   if(StopLoss>0 || TakeProfit>0)
     {
      for(int i=OrdersTotal()-1;i>=0;i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))break;
         if(OrderSymbol()==Symbol() && OrderType()<2)
           {
            if(OrderType()==0)
              {
               if(StopLoss  !=0)sl = slbuy;else sl =OrderStopLoss();   sl=NormalizeDouble(sl,Digits);
               if(TakeProfit!=0)tp = tpbuy;else tp=OrderTakeProfit(); tp=NormalizeDouble(tp,Digits); clr=clrBlue;
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
                  Print("OrderModify Error: ",ErrorDescription(GetLastError()));
              }
            else if(OrderType()==1)
              {
               if(StopLoss  !=0) sl=slsell;else sl=OrderStopLoss();    sl=NormalizeDouble(sl,Digits);
               if(TakeProfit!=0) tp=tpsell;else tp=OrderTakeProfit();  tp=NormalizeDouble(tp,Digits);  clr=clrRed;
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
                  Print("OrderModify Error: ",ErrorDescription(GetLastError()));
              }
           }
        }//for
     }

  }
//+------------------------------------------------------------------+
