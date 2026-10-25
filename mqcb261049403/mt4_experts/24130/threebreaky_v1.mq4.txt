//+------------------------------------------------------------------+
//|                                               ThreeBreaky_v3.mq4 |
//|                                  Copyright 2018, Fabio Cavalloni |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Fabio Cavalloni"
#property version   "1.00"
#property strict

extern bool   System1     = true;           // Use system 1
extern bool   System2     = true;           // Use system 2
extern bool   System3     = true;           // Use system 3

extern int    MagicNumber  = 900;           // Magic Number (system will use Magic+1, Magic+2, Magic+3)
extern double Lots         = 1;            // Order Lots
extern int    StopLoss     = 20;            // Stop loss pips
extern int    TakeProfit   = 0;             // Take profit pips (order will be always closed with indicator)

double    p, lots, atrSL;
datetime  buyTag1, sellTag1, buyTag2, sellTag2, buyTag3, sellTag3, timeTag;
double    atrDaily[73], atrDMedia, atr1, atrD,
          spanA, spanB,
          size1, maxSize,
          sar1, sar2;
                   
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
  
   if (timeTag < Time[0])
      {
      HideTestIndicators(true);
      
// System 1 variables
      for ( int i=1 ; i<= 72; i++ ) atrDaily[i] = iHigh(Symbol(),PERIOD_CURRENT,i) - iLow(Symbol(),PERIOD_CURRENT,i);
                                    atrDMedia  = iMAOnArray(atrDaily,0,72,0,MODE_SMA,1);
      
      atr1       = iATR(Symbol(),PERIOD_CURRENT,1,1);      
      atrD       = iATR(Symbol(),PERIOD_D1,14,1);      
      
// System 2 variables   
      spanA       = iIchimoku(Symbol(),PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANA,1);
      spanB       = iIchimoku(Symbol(),PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANB,1);
      
// System 3 variables
      size1       = MathAbs(Close[1] - Open[1]);
      maxSize     = 0;
      for ( int i=2; i<= 21; i++)
         {
            double size = MathAbs(Open[i] - Close[i]);
            if( size > maxSize ) maxSize = size;
         }
      
// Indicator for order close
      sar1        = iSAR(Symbol(),PERIOD_CURRENT,0.005,0.2,1);
      sar2        = iSAR(Symbol(),PERIOD_CURRENT,0.005,0.2,2);


      timeTag     = TimeCurrent();
     
      }
      
   if( OrdersTotal() > 0 ) close1();
   if( OrdersTotal() > 0 ) close2();
   if( OrdersTotal() > 0 ) close3();
   
   
   if( System1 )
   {  
      if( Close[1] > Open[1] && atr1 > atrDMedia*4 && !orderOpen(MagicNumber+1) &&  buyTag1 < Time[0] ) 
      {
         int ticket1;
         ticket1 = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,SL(OP_BUY),0,"ThreeBreaky 1",MagicNumber+1,0,Blue); 
         if (ticket1 > -1) buyTag1 = TimeCurrent();
      }
      
      if( Close[1] < Open[1] && atr1 > atrDMedia*4  && !orderOpen(MagicNumber+1) && sellTag1 < Time[0] ) 
      {
         int ticket1;
         ticket1 = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,SL(OP_SELL),0,"ThreeBreaky 1",MagicNumber+1,0,Red);
         if (ticket1 > -1) sellTag1 = TimeCurrent();
      }
   }
   
   if( System2 ) 
   { 
      if( Close[2] < spanA && Close[2] < spanB && Close[1] > spanA && Close[1] > spanB && !orderOpen(MagicNumber+2) &&  buyTag2 < Time[0] ) 
      {
         int ticket2;
         ticket2 = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,SL(OP_BUY),0,"ThreeBreaky 2",MagicNumber+2,0,Blue);
         if (ticket2 > -1) buyTag2 = TimeCurrent();
      }
      
      if( Close[2] > spanA && Close[2] > spanB && Close[1] < spanA && Close[1] < spanB && !orderOpen(MagicNumber+2) && sellTag2 < Time[0] ) 
      {
         int ticket2;
         ticket2 = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,SL(OP_SELL),0,"ThreeBreaky 2",MagicNumber+2,0,Red);
         if (ticket2 > -1) sellTag2 = TimeCurrent();
      }
   }

   if( System3 ) 
   { 
      if( Close[1] > Open[1] && size1 > maxSize*3 && !orderOpen(MagicNumber+3) &&  buyTag3 < Time[0] ) 
      {
         int ticket3;
         ticket3 = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,SL(OP_BUY),0,"ThreeBreaky 3",MagicNumber+3,0,Blue);
         if (ticket3 > -1) buyTag3 = TimeCurrent();
      }
      
      if( Close[1] < Open[1] && size1 > maxSize*3 && !orderOpen(MagicNumber+3) && sellTag3 < Time[0] ) 
      {
         int ticket3;
         ticket3 = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,SL(OP_SELL),0,"ThreeBreaky 3",MagicNumber+3,0,Red);
         if (ticket3 > -1) sellTag3 = TimeCurrent();
      }
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


//+------------------------------------------------------------------+
//| Order closing functions                                          |
//+------------------------------------------------------------------+


void close1()
{
for (int i = OrdersTotal()-1; i >= 0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber+1 ) {
       //se BUY
       if (OrderType() == OP_BUY && Close[2] > sar2 && Close[1] < sar1  ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Blue)) continue;
       } 
       //se SELL
       if (OrderType() == OP_SELL && Close[2] < sar2 && Close[1] > sar1  ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Red)) continue;
       } 
    }
}
return;
}


void close2()
{
for (int i = OrdersTotal()-1; i >= 0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber+2 ) {
       //se BUY
       if (OrderType() == OP_BUY && Close[2] > sar2 && Close[1] < sar1  ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Blue)) continue;
       } 
       //se SELL
       if (OrderType() == OP_SELL && Close[2] < sar2 && Close[1] > sar1  ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Red)) continue;
       } 
    }
}
return;
}

void close3()
{
for (int i = OrdersTotal()-1; i >= 0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber+3 ) {
       //se BUY
       if (OrderType() == OP_BUY && Close[2] > sar2 && Close[1] < sar1  ) {
          if (OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Blue)) continue;
       } 
       //se SELL
       if (OrderType() == OP_SELL && Close[2] < sar2 && Close[1] > sar1  ) {
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