//+------------------------------------------------------------------+
//|                                                Scalper Assistant |
//|                                       Copyright 2021, RayanTech  |
//|                                      http://t.me/MegaSYS_Support |
//+------------------------------------------------------------------+
#property copyright "Mohsen Nazari"
#property strict
sinput string Section1           = "---------------->>>		TP/SL Settings		<<<----------------";
extern int    StopLoss           = 30;       // Initial STOP-LOSS (Points)
extern int    TakeProfit         = 100;      // TAKE-PROFIT (Points)
sinput string Section3           = "---------------->>>   StopLoss Settings		<<<----------------";
extern double WhenToMoveToBE     = 15;       // When SL would be move to BreakEven (Points)
extern double BEAmount           = 5;        // BreakEven Amount (Points)

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Expert Advisor Start Function                                    |
//+------------------------------------------------------------------+
int start()
  {

   AutoTrailStopLoss();

   return(0);
  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| TRAILING  STOPLOSS                                               |
//+------------------------------------------------------------------+
void AutoTrailStopLoss()
  {
   for(int i= OrdersTotal()-1 ; i>= 0 ; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))  //------------------------------------------------------> Select Open Orders in the pool By Index Number
        {
         if(OrderMagicNumber()== 0) //----------------------------------------------------------------------> Only Manual Orders will be Modified
           {
            if(OrderType()== OP_BUY)  //--------------------------------------------------------------------> BUY Positions will be in Processing
              {
               if(MarketInfo(OrderSymbol(), MODE_BID)- OrderOpenPrice() >= getPoint(WhenToMoveToBE))
                 {
                  if(OrderStopLoss() < OrderOpenPrice()+ getPoint(BEAmount))
                    {
                     Print("BID = ", MarketInfo(OrderSymbol(), MODE_BID), " LastSL = ", OrderStopLoss());
                     //---
                     bool BUYModify = OrderModify(OrderTicket(),
                                                  OrderOpenPrice(),
                                                  OrderOpenPrice()+ getPoint(BEAmount),
                                                  OrderTakeProfit(),
                                                  0,
                                                  CLR_NONE);
                     //---
                     Sleep(800);

                     if(BUYModify)
                        break;
                     if(!BUYModify)
                        Print("Scalping Assistant Alert!! Error in OrderModify. Error code=", GetLastError());
                    }
                 }
              }

            //---

            if(OrderType()   == OP_SELL)  //------------------------------------------------------------------> SELL Positions will be in Processing
              {
               if(OrderOpenPrice()- MarketInfo(OrderSymbol(), MODE_ASK) >= getPoint(WhenToMoveToBE))
                 {
                  if(OrderStopLoss() > OrderOpenPrice()- getPoint(BEAmount))
                    {
                     Print("ASK = ", MarketInfo(OrderSymbol(), MODE_ASK), " LastSL = ", OrderStopLoss());
                     bool SELLModify =  OrderModify(OrderTicket(),
                                                    OrderOpenPrice(),
                                                    OrderOpenPrice()- getPoint(BEAmount),
                                                    OrderTakeProfit(),
                                                    0,
                                                    CLR_NONE);
                     //---
                     Sleep(800);

                     if(SELLModify)
                        break;
                     if(!SELLModify)
                        Print("Scalping Assistant Alert!! Error in OrderModify. Error code=",GetLastError());
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| Point Value Converter Function                                   |
//+------------------------------------------------------------------+
double   getPoint(double value)
  {
   return (NormalizeDouble(value * Point, Digits));
  }
//+------------------------------------------------------------------+
