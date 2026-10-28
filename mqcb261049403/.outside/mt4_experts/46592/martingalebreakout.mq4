//+------------------------------------------------------------------+
//|                                           NewExpertformarket.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Müller Péter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.00"
#property strict

#include  <ExpertFunctions.mqh>

input int TakeProfPoints = 50;
input double BalancePercentageAvailable = 50;
input double TP_Percentage_of_Balance = 0.1;
input double SL_Percentage_of_Balance = 10;
input double Start_The_Recovery = 0.2;
input double TP_Points_Multiplier = 1;
input int MagicNumber = 89758029;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
{
   static double StopLoss = SL_Percentage_of_Balance*Start_The_Recovery*AccountBalance()/100;
   static double TakeProfit = TP_Percentage_of_Balance*AccountBalance()/100;
   double CurrentProfit = Profits(MagicNumber,_Symbol);
   static bool Recovering = false;
   double Balance = AccountBalance();
   if(CurrentProfit < -StopLoss || CurrentProfit > TakeProfit)
   {
      if(CurrentProfit < -StopLoss && StopLoss < SL_Percentage_of_Balance/100*Balance)
      {
         CloseAllOrders(_Symbol,MagicNumber);
         TakeProfit -= CurrentProfit;
         StopLoss = SL_Percentage_of_Balance/100*Balance;
         Recovering = true;
         return;
      }
      CloseAllOrders(_Symbol,MagicNumber);
      TakeProfit = TP_Percentage_of_Balance/100*Balance;
      StopLoss = SL_Percentage_of_Balance/100*Start_The_Recovery*Balance;
      Recovering = false;
      return;
   }
   if(!IsNewCandle() || TotalopenOrders(MagicNumber,_Symbol))
      return;
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(BullBreakout(_Symbol,PERIOD_CURRENT))
   {  
       double Vol;
      if(Recovering)
         Vol = RoundtoLots(CalcLotWithTP(TakeProfit,ask,ask+TakeProfPoints*TP_Points_Multiplier*_Point));
      else Vol = RoundtoLots(CalcLotWithTP(TakeProfit,ask,ask+TakeProfPoints*_Point));
      if(Vol*LotSize() < Balance*BalancePercentageAvailable/100 && CheckVolumeValue(Vol))
      {
         if(!OrderSend(_Symbol,OP_BUY,Vol,ask,500,0,0,"",MagicNumber))
            Print("Ordersend buy failed: " + IntegerToString(GetLastError()));
      }
   }
   if(BearBreakout(_Symbol,PERIOD_CURRENT))
   {
      double Vol;
      if(Recovering)
         Vol = RoundtoLots(CalcLotWithTP(TakeProfit,bid,bid-TakeProfPoints*TP_Points_Multiplier*_Point));
      else Vol = RoundtoLots(CalcLotWithTP(TakeProfit,bid,bid-TakeProfPoints*_Point));
      if(Vol*LotSize() < Balance*BalancePercentageAvailable/100 && CheckVolumeValue(Vol))
      {
         if(!OrderSend(_Symbol,OP_SELL,Vol,bid,500,0,0,"",MagicNumber))
            Print("Ordersend sell failed: " + IntegerToString(GetLastError()));
      }
   }
}
