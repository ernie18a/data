//+------------------------------------------------------------------+
//|                                                      AroonEA.mq4 |
//|                                  Copyright 2018, Fabio Cavalloni |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Fabio Cavalloni"
#property version   "1.00"
#property strict

extern int    MagicNumber            = 777;  // Magic number of the EA
extern double Lots                   = 1;  // Static lot size

extern int    WprPeriods             = 35;   // WPR Periods
extern int    openWPR                = 20;   // Open WPR value (enter 20 for use <-80 BUY and >-20 SELL)
extern int    closeWPR               = 10;   // Close WPR value(same as above)
extern int    StopLoss               = 0;    // Stop loss pips (0 for WPR close)
extern int    TakeProfit             = 0;    // Take profit pips

datetime buyTag1 ,sellTag1, timeTag;
double   p, lots;
double   aroon1up, aroon1dw, aroon2up, aroon2dw, aroonUpTrend, aroonDwTrend,
         wpr; 


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
  
if (timeTag < Time[0]) {
 
 aroon1up = iCustom(Symbol(),PERIOD_CURRENT,"Aroon.ex4",14,0,0,0,1);
 aroon1dw = iCustom(Symbol(),PERIOD_CURRENT,"Aroon.ex4",14,0,0,1,1);
 aroon2up = iCustom(Symbol(),PERIOD_CURRENT,"Aroon.ex4",14,0,0,0,2);
 aroon2dw = iCustom(Symbol(),PERIOD_CURRENT,"Aroon.ex4",14,0,0,1,2);
 
 aroonUpTrend = iCustom(Symbol(),PERIOD_H1,"Aroon.ex4",14,0,0,0,2);
 aroonDwTrend = iCustom(Symbol(),PERIOD_H1,"Aroon.ex4",14,0,0,1,2);
 
 wpr    = iWPR(Symbol(),PERIOD_CURRENT,WprPeriods,1);
 
 timeTag     = TimeCurrent();
 
}
  
  if( orderOpen(MagicNumber) ) closeIndicator(wpr);
   
   if ( aroon2up <= aroon2dw && aroon1up > aroon1dw && wpr < -(100-openWPR) &&  !orderOpen(MagicNumber) &&  buyTag1 < Time[0] ) 
      {
         int ticket1;
         ticket1 = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,SL(OP_BUY),TP(OP_BUY),"Simple MACD",MagicNumber,0,Blue);
         if (ticket1 > -1) buyTag1 = TimeCurrent();
      }

   if( aroon2up >= aroon2dw && aroon1up < aroon1dw && wpr > -openWPR && !orderOpen(MagicNumber) && sellTag1 < Time[0] ) 
      {
         int ticket1;
         ticket1 = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,SL(OP_SELL),TP(OP_SELL),"Simple MACD",MagicNumber,0,Red);
         if (ticket1 > -1) sellTag1 = TimeCurrent();
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


void closeIndicator(double myOscillator)
{
for (int i = OrdersTotal()-1; i >= 0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
       if (OrderType() == OP_BUY && wpr >= -closeWPR ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Blue)) continue;
       } 
       if (OrderType() == OP_SELL && wpr <= -(100-closeWPR) ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Red)) continue;
       } 
    }
}
return;
}



double SL(int type)
{
if (StopLoss == 0)   return(0.0);
if (type == OP_BUY)  return(Bid-StopLoss*p);
if (type == OP_SELL) return(Ask+StopLoss*p);
return(0.0);
}

double TP(int type)
{
if (TakeProfit == 0) return(0.0);
if (type == OP_BUY)  return(Bid+TakeProfit*p);
if (type == OP_SELL) return(Ask-TakeProfit*p);
return(0.0);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {}