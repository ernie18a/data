//+------------------------------------------------------------------+
//|                                               Slime_Mold_RSI.mq4 |
//|                                                       Kei Sanada |
//|                          https://www.mql5.com/en/users/sdk7777   |
//|        2017/07/19 V1.1 Add take measures to changing ticket No   |          
//+------------------------------------------------------------------+
#property copyright "Kei Sanada"
#property link      "www.linkedin.com/in/kei-sanada"
#property version   "1.10"
#property strict

input double Lots = 0.1;
input int MagicNumber = 0;

input int    x1 = 0;//weight1
input int    x2 = 0;//weight2
input int    x3 = 0;//weight3
input int    x4 = 0;//weight4

string Trade_Comment = IntegerToString(MagicNumber,5,' ') + "Days-Optimization"; 
int Ticket = 0; //Ticket number

void OnTick()
{
   double w1 = x1 - 100;
   double w2 = x2 - 100;
   double w3 = x3 - 100;
   double w4 = x4 - 100;   
   //Perceptron before one bar 2017/03/18
   double a11 = ((iRSI(Symbol(), 0, 12,PRICE_MEDIAN,1))/100-0.5)*2; 
   double a21 = ((iRSI(Symbol(), 0, 36,PRICE_MEDIAN,1))/100-0.5)*2; 
   double a31 = ((iRSI(Symbol(), 0, 108,PRICE_MEDIAN,1))/100-0.5)*2; 
   double a41 = ((iRSI(Symbol(), 0, 324,PRICE_MEDIAN,1))/100-0.5)*2; 
   double Current_Percptron = (w1 * a11 + w2 * a21 + w3 * a31 + w4 * a41);
   //Perceptron before two bar 2017/03/18
   double a12 = ((iRSI(Symbol(), 0, 12,PRICE_MEDIAN,2))/100-0.5)*2;
   double a22 = ((iRSI(Symbol(), 0, 36,PRICE_MEDIAN,2))/100-0.5)*2;
   double a32 = ((iRSI(Symbol(), 0, 108,PRICE_MEDIAN,2))/100-0.5)*2;
   double a42 = ((iRSI(Symbol(), 0, 324,PRICE_MEDIAN,2))/100-0.5)*2;
   double Pre_Percptron = (w1 * a12 + w2 * a22 + w3 * a32 + w4 * a42);
   
   int pos = 0; //Position status
   //2017/07/19 V1.1 Add take measures to changing ticket No
   //Alpari changing ticekt No, when rollover.
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS) && OrderCloseTime() == 0 && OrderMagicNumber() == MagicNumber)
      {
         Ticket = OrderTicket();
      }
   }
   
   if(OrderSelect(Ticket, SELECT_BY_TICKET)) 
   {
      if(OrderType() == OP_BUY) pos = 1; //Long position
      if(OrderType() == OP_SELL) pos = -1; //Short positon
    }
   
   //2017/07/17 For Check Open price
   static int BarsBefore = 0;
   int BarsNow = Bars;
   int BarsCheck = BarsNow - BarsBefore;
   
   if (BarsCheck == 1)
   printf(Trade_Comment + ", " + "pos=" + pos + ", " + "Pre_Percptron=" + Pre_Percptron + ", " + "Current_Percptron=" + Current_Percptron + ", ");
   
   BarsBefore = BarsNow;
      
   bool ret; //position status
   if(Pre_Percptron < 0 && Current_Percptron > 0) //long signal
   {
      //If there is a short position, send order close
      if(pos < 0)
      {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0; //If order close succeeds, position status is Zero
      }
      //If there is no position, send long order
      if(pos == 0) Ticket = OrderSend(
                                       _Symbol,              // symbol
                                       OP_BUY,                 // operation
                                       Lots,              // volume
                                       Ask,               // price
                                       0,            // slippage
                                       0,            // stop loss
                                       0,          // take profit
                                       Trade_Comment,        // comment
                                       MagicNumber,// magic number
                                       0,        // pending order expiration
                                       Green  // color
                                       );
   }
   if(Pre_Percptron > 0 && Current_Percptron < 0) //short signal
   {
      //If there is a long position, send order close
      if(pos > 0)
      {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0; //If order close succeeds, position status is Zero
      }
      //If there is no position, send short order
      if(pos == 0) Ticket = OrderSend(
                                       _Symbol,              // symbol
                                       OP_SELL,              // operation
                                       Lots,                 // volume
                                       Bid,          // price
                                       0,            // slippage
                                       0,            // stop loss
                                       0,            // take profit
                                       Trade_Comment,         // comment
                                       MagicNumber,  // magic number
                                       0,            // pending order expiration
                                       Red  // color
                                       ); 
   }
}