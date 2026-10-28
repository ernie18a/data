//------------------------------------------------------------------------------------------
// Copyright © 2020, coocker71@gmail.com
// ------------------------------------------------------------------------------------------------
#property copyright "Copyright © 2020 PhoenixSykes"
#property link      "coocker71@gmail.com"
#property version   "1.00"
#property strict
//-- Include modules --
#include <stderror.mqh>
#include <stdlib.mqh>
//--- Inputs Expert Settings
input string SignalSetting  = "---------- Signal Setting ----------";
input int Distance          = 140, // Distance Envelopes And Price
          Envelope_Period   = 3; // Envelopes Period
input double Deviation      = 0.05; // Envelopes Deviation
input string OrderSetting   = "---------- Order Setting ----------";
input int StopLoss          = 250, //StopLoss in Points
          TakeProfit        = 0, //TakeProfit in Points
          TrailingStop      = 120; //TrailingStop in Points
input string MM             = "---------- Risk Management ----------";
input double FixedLots      = 0.01,
             Risk           = 70;
input string EA_            = "---------- Expert Setting ----------";
input int MaxSpread         = 25, //Max Spread in Points
          Slippage          = 3, //Slippage in Points
          Magic             = 777; //Expert ID
input bool InfoExpert       = False;
string ComSpread;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ChartSetInteger(0,CHART_SHOW_GRID,False);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Trading Criteria
   int direct = 0;
   double envup = iEnvelopes(NULL,0,Envelope_Period,MODE_LWMA,0,PRICE_MEDIAN,Deviation,MODE_UPPER,1),
          envdn = iEnvelopes(NULL,0,Envelope_Period,MODE_LWMA,0,PRICE_MEDIAN,Deviation,MODE_LOWER,1);
   if(envdn-Low[1] > Distance*Point && envdn-Bid > Distance*Point)
      direct = -1; // Signal Buy
   if(High[1]-envup > Distance*Point && Bid-envup > Distance*Point)
      direct = 1; // Signal Sell

//---
   int Count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         Count++;
         switch(OrderType())
           {
            case OP_BUY:
               if(TrailingStop>0)
                 {
                  if(Bid-OrderOpenPrice()>TrailingStop*Point)
                    {
                     if(OrderStopLoss()<Bid-TrailingStop*Point)
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,clrNONE))
                           Print("Trailing SL Buy Order Err : ",GetLastError());
                       }
                    }
                 }
            case OP_SELL:
               if(TrailingStop>0)
                 {
                  if((OrderOpenPrice()-Ask)>(TrailingStop*Point))
                    {
                     if((OrderStopLoss()>(Ask+TrailingStop*Point)) || (OrderStopLoss()==0))
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,clrNONE))
                           Print("Trailing SL Sell Order Err : ",GetLastError());
                       }
                    }
                 }
           }
        }
     }
//---
   double avgSprd = NormalizeDouble((Ask - Bid)/Point,0);
//---
   double Lots = FixedLots;
   double Amount = AccountFreeMargin()*Risk/100/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if(Risk>0)
      Lots=MathMin(MathMax(MarketInfo(Symbol(),MODE_MINLOT),MathRound(Amount/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),MarketInfo(Symbol(),MODE_MAXLOT));

//Open Orders
   if(Count == 0 && direct != 0 && avgSprd<MaxSpread)
     {
      RefreshRates();
      double vStopLoss=0,vTakeProfit=0;
      if(direct < 0)
        {
         if(StopLoss > 0)
            vStopLoss = NormalizeDouble(Ask - StopLoss * Point, Digits);
         if(TakeProfit > 0)
            vTakeProfit = NormalizeDouble(Ask + TakeProfit * Point, Digits);
         if(OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, vStopLoss, vTakeProfit, "-PhoenixSyk", Magic) == -1)
            Print("Error order send "+(string)GetLastError());
        }
      if(direct > 0)
        {
         if(StopLoss > 0)
            vStopLoss = NormalizeDouble(Bid + StopLoss * Point, Digits);
         if(TakeProfit > 0)
            vTakeProfit = NormalizeDouble(Bid - TakeProfit * Point, Digits);
         if(OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, vStopLoss, vTakeProfit, "-PhoenixSyk", Magic) == -1)
            Print("Error order send "+(string)GetLastError());
        }
     }
//--- expert info
   if(InfoExpert)
     {
      if(avgSprd<=MaxSpread)
         ComSpread = "EA Running OK!!!";
      else
         ComSpread = "Spread Over Limit !!! ( "+DoubleToStr(avgSprd,0)+" > "+DoubleToStr(MaxSpread,0)+" )";
      Comment("\n                 ",WindowExpertName(),
              "\n ----------------------------------------------------------------",
              "\n :: Spread  :  ", avgSprd," || Leverage  :  1 / ", AccountLeverage(),
              "\n :: Next Lots  :  ", Lots," || Equity  :  ", DoubleToStr(AccountEquity(),2)," ",AccountCurrency(),
              "\n ",
              "\n :: ",ComSpread,
              "\n ----------------------------------------------------------------");
     }
  }
//+------------------------------------------------------------------+
