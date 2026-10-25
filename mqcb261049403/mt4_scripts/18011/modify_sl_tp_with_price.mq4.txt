//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq4 |
//|                                          Copyright 2017,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "1.00"
#property strict
#property show_inputs
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ORDERTYPE
  {
   BUY=0,
   SELL=1
  };

input ENUM_ORDERTYPE SelectOrderType=BUY;
input double InpStopLoss=0.0; // StopLoss in Price
input double InpTakeProfit=0.0; //TakeProfit in Price
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

   if(OrdersTotal()==0)  return;

   if(!IsTradeAllowed()){Alert("Autotrade is NOT allowed.");  return;}

   if(StopLoss==0 && TakeProfit==0){Alert(" No SL/TP need to be modified");return;}

   double tpbuy = NormalizeDouble(TakeProfit,Digits);
   double slbuy = NormalizeDouble(StopLoss,Digits);

   double tpsell = NormalizeDouble(TakeProfit,Digits);
   double slsell = NormalizeDouble(StopLoss,Digits);

   double sl=0.0,tp=0.0;

   if(StopLoss>0 || TakeProfit>0)
     {
      for(int i=OrdersTotal()-1;i>=0;i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))break;
         if(OrderSymbol()==Symbol() && OrderType()<2)
           {
            if(OrderType()==0 && SelectOrderType==BUY)
              {
               if(StopLoss  !=0)sl = slbuy;else sl =OrderStopLoss();   sl=NormalizeDouble(sl,Digits);
               if(TakeProfit!=0)tp = tpbuy;else tp=OrderTakeProfit(); tp=NormalizeDouble(tp,Digits); clr=clrBlue;
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
                  Print("Ticket#",OrderTicket(),",OrderModify Error: ",ErrorDescription(GetLastError()));
              }
            else if(OrderType()==1 && SelectOrderType==SELL)
              {
               if(StopLoss  !=0) sl=slsell;else sl=OrderStopLoss();    sl=NormalizeDouble(sl,Digits);
               if(TakeProfit!=0) tp=tpsell;else tp=OrderTakeProfit();  tp=NormalizeDouble(tp,Digits);  clr=clrRed;
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,clr))
                 Print("Ticket#",OrderTicket(),",OrderModify Error: ",ErrorDescription(GetLastError()));
              }
           }
        }//for
     }

  }
//+------------------------------------------------------------------+
