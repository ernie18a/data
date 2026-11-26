//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Forexia"
#property link      "https://www.mql5.com/en/users/scuxia"
 
/*
   Kicks in when position reaches at least TrailingStop pips of profit.
*/
 
extern double TrailingStop = 5;
 
// Set it to some value above 0 to activate stop-loss
extern double StopLoss = 0; 
 
int init()
{
   return(0);
}
 
int deinit()
{
   return(0);
}
 
int start()
{
  double PointValue;
  for (int i = 0; i < OrdersTotal(); i++) 
  {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
      if (OrderSymbol() != Symbol()) continue; // Skipping positions in other currency pairs
      //Calculate the point value in case there are extra digits in the quotes
      if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.00001) PointValue = 0.0001;
      else if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.001) PointValue = 0.01;
      else PointValue = MarketInfo(OrderSymbol(), MODE_POINT);
      //Normalize trailing stop value to the point value
      double TSTP = TrailingStop * PointValue;
 
      if (OrderType() == OP_BUY)
      {
         if (Bid - OrderOpenPrice() > TSTP)
         {
            if (OrderStopLoss() < Bid - TSTP)
            {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TSTP, OrderTakeProfit(), Red))
                  Print("Error setting Buy trailing stop: ", GetLastError());
            }
         }
         else if ((OrderStopLoss() != Bid - StopLoss * PointValue) && (StopLoss != 0) && (OrderStopLoss() == 0))
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - StopLoss * PointValue, OrderTakeProfit(), Red))
               Print("Error setting Buy stop-loss: ", GetLastError());
      }
      else if (OrderType() == OP_SELL)
      {
         if (OrderOpenPrice() - Ask > TSTP)
         {
            if ((OrderStopLoss() > Ask + TSTP) || (OrderStopLoss() == 0))
            {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TSTP, OrderTakeProfit(), Red))
                  Print("Error setting Sell trailing stop: ", GetLastError());
            }
         }
         else if ((OrderStopLoss() != Ask + StopLoss * PointValue) && (StopLoss != 0) && (OrderStopLoss() == 0))
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + StopLoss * PointValue, OrderTakeProfit(), Red))
               Print("Error setting Sell stop-loss: ", GetLastError());
      }
	}
 
   return(0);
}
/*if(TrailingStop>0)
  {
   OrderSelect(12345,SELECT_BY_TICKET);
   if(Bid-OrderOpenPrice()>Point*TrailingStop)
     {
      if(OrderStopLoss()<Bid-Point*TrailingStop)
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Blue);
         return(0);
        }
     }
  }*/
//+------------------------------------------------------------------+
