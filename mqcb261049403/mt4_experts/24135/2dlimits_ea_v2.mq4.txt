//+------------------------------------------------------------------+
//|                                               2DLimits_EA_v2.mq4 |
//|                                  Copyright 2018, Fabio Cavalloni |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Fabio Cavalloni"
#property version   "1.00"
#property strict

extern int    MagicNumber            = 123456;    // Magic number of the EA
extern double Lots                   = 1;         // Static lot size

datetime buyTag1 ,sellTag1, timeTag, dayTag;
double   p, lots;
double   high1, low1, open1, close1, high2, low2, open2, close2, middleY,
         sizePos, atr;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
                        p = Point;
  if (Point == 0.00001) p = 0.0001;
  if (Point == 0.001)   p = 0.01;
  
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if( Bars < 10 ) return;
   
   if (timeTag < Time[0]) {
   
    if( dayTag != iTime(Symbol(),PERIOD_D1,0) ) deletePendings();
    
    high1   = iHigh(Symbol(),PERIOD_D1,1);
    low1    = iLow(Symbol(),PERIOD_D1,1);
    open1   = iOpen(Symbol(),PERIOD_D1,1);
    close1  = iClose(Symbol(),PERIOD_D1,1);
    high2   = iHigh(Symbol(),PERIOD_D1,2);
    low2    = iLow(Symbol(),PERIOD_D1,2);
    open2   = iOpen(Symbol(),PERIOD_D1,2);
    close2  = iClose(Symbol(),PERIOD_D1,2);
    
    middleY = NormalizeDouble(iHigh(Symbol(),PERIOD_D1,1) - ( (iHigh(Symbol(),PERIOD_D1,1)-iLow(Symbol(),PERIOD_D1,1))*0.5 ),Digits);
    sizePos = iHigh(Symbol(),PERIOD_D1,1)-iLow(Symbol(),PERIOD_D1,1);
    atr     = iATR(Symbol(),PERIOD_D1,7,1);
    timeTag = Time[0];
    dayTag  = iTime(Symbol(),PERIOD_D1,0);
 
    }
  
   if( high1 > high2 && low1 > low2 && !orderOpen(MagicNumber) && !orderClosedOnBar(MagicNumber)  ) 
      {   
         if( Ask < middleY ) int ticket = OrderSend(Symbol(),OP_BUYSTOP,Lots,high1,0,middleY,NormalizeDouble(high1+sizePos,Digits),"2DLimits EA",MagicNumber,0,Blue);
      }

   if( high1 < high2 && low1 < low2 && !orderOpen(MagicNumber) && !orderClosedOnBar(MagicNumber) ) 
      {
         if( Bid > middleY ) int ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,low1,0,middleY,NormalizeDouble(low1-sizePos,Digits),"2DLimits EA",MagicNumber,0,Red);
      }
}
//+------------------------------------------------------------------+

bool orderOpen(int Magic)
{
for ( int i = OrdersTotal()-1; i >= 0; i--) {
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) continue; 
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
       return(true);
    }  
}
return(false);
}

bool orderClosedOnBar(int Magic)
{
for ( int i = OrdersHistoryTotal()-1; i >= 0; i--) {
    if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderOpenTime() >= Time[0]) {
       return(true);
    }  
}
return(false);
}

void deletePendings()
{
for (int i = OrdersTotal()-1; i >= 0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
       //se BUY
       if (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT  ) {
          if (OrderDelete(OrderTicket(),clrNONE)) continue;
       } 
    }
}
return;
}



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {}