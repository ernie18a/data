//------------------------------------------------------------------------------------------
// Copyright © 2020, coocker71@gmail.com
// ------------------------------------------------------------------------------------------------
#property copyright "Copyright © 2020 PhoenixSykes"
#property link      "coocker71@gmail.com"
#property version   "1.01"
#property strict
//--- Inputs Expert Settings
input string SignalSetting  = "---------- Signal Setting ----------";
input int Rsi_Period        = 14, 
          Fast_Sma          = 2,
          Slow_Sma          = 6,
          Fast_Cci          = 34, 
          Slow_Cci          = 175;
input string OrderSetting   = "---------- Order Setting ----------";
input int StopLoss          = 60, // StopLoss in Point
          TakeProfit        = 0, // TakeProfit in Point
          TrailingStop      = 20; // TrailingStop in Point
input double DynamicLot     = 0.01,
             MaxSpread      = 18.0;
input string EA_            = "---------- Expert Setting ----------";
input int Slippage          = 3,
          Magic             = 777;
input bool InfoExpert       = False;
string ComSpread;
//+------------------------------------------------------------------+
int init()
  {
//--- Set Default Chart theme
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,false);
   ChartSetInteger(ChartID(),CHART_MODE,CHART_CANDLES);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
//--- Indicator used for Signal
   double prevRsi = iRSI(Symbol(),0,Rsi_Period,PRICE_CLOSE,1),
          currRSi = iRSI(Symbol(),0,Rsi_Period,PRICE_CLOSE,0),
          Fma = iMA(Symbol(),0,Fast_Sma,0,MODE_SMMA,PRICE_OPEN,0),
          Sma = iMA(Symbol(),0,Slow_Sma,0,MODE_EMA,PRICE_OPEN,0),
          Fcci = iCCI(Symbol(),0,Fast_Cci,PRICE_TYPICAL,0),
          Scci = iCCI(Symbol(),0,Slow_Cci,PRICE_TYPICAL,0);
//--- Check Order and do the trailing stoploss
   int Ord=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
        {
         Ord++;
         switch(OrderType())
           {
            case OP_BUY:
               if(TrailingStop>0 && OrderOpenPrice()<Bid-TrailingStop*Point && OrderStopLoss()<Bid-TrailingStop*Point)
                 {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing SL Buy Order Err : ",GetLastError());
                 }
            case OP_SELL:
               if(TrailingStop>0 && OrderOpenPrice()>Ask+TrailingStop*Point && OrderStopLoss()>Ask+TrailingStop*Point)
                 {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing SL Sell Order Err : ",GetLastError());
                 }
           }
        }
     }
//--- simple dynamic lotsize, use your best MM
   double LotSize = NormalizeDouble(DynamicLot*MathSqrt(AccountEquity()/10),2);//FixedLot*MathSqrt(AccountEquity()/1000);
//--- if avg spread < maxspread and no open order, then expert will open trade by signal
   double NewSL=0,NewTP=0;
   if(Ord<=0 && MarketInfo(Symbol(),MODE_SPREAD)<MaxSpread)
     {
      if(Fma>Sma && prevRsi<55 && currRSi>55 && Fcci>0 && Scci>0)
        {
         if(StopLoss!=0)
            NewSL=Bid-StopLoss*Point;
         if(TakeProfit!=0)
            NewTP=Ask+TakeProfit*Point;
         if(!OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,NewSL,NewTP,"-PhoenixSyk",Magic,0,clrNONE))
            Print("Buy Order Err : ",GetLastError());
        }
      if(Fma<Sma && prevRsi>45 && currRSi<45 && Fcci<0 && Scci<0)
        {
         if(StopLoss!=0)
            NewSL=Ask+StopLoss*Point;
         if(TakeProfit!=0)
            NewTP=Bid-TakeProfit*Point;
         if(!OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,NewSL,NewTP,"-PhoenixSyk",Magic,0,clrNONE))
            Print("Sell Order Err : ",GetLastError());
        }
     }
//--- expert info
   if(InfoExpert)
     {
      if(MarketInfo(_Symbol,MODE_SPREAD)<=MaxSpread)
         ComSpread = "Spread to Limit : "+DoubleToStr((MarketInfo(Symbol(), MODE_SPREAD)-MaxSpread),0)+" - EA Running OK!!!";
      else
         ComSpread = "Spread Over Limit !!! ( "+DoubleToStr(MarketInfo(_Symbol,MODE_SPREAD),0)+" > "+DoubleToStr(MaxSpread,0)+" )";
      Comment("\n ------------------------------------------------",
              "\n ","               -PhoenixSyk-",
              "\n ------------------------------------------------",
              "\n :: Spread  :  ", MarketInfo(Symbol(), MODE_SPREAD)," || Leverage  :  1 / ", AccountLeverage(),
              "\n :: Next Lots  :  ", LotSize," || Equity  :  ", AccountEquity()," ",AccountCurrency(),
              "\n :: Server Time  :  ", Hour(), ":", Minute(),
              "\n ------------------------------------------------",
              "\n :: ",ComSpread,
              "\n ------------------------------------------------");
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
