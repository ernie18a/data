//+------------------------------------------------------------------+
//|                                                      Doubler.mq4 |
//|                                                Billionaire prod. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Billionaire prod."
#property link      "ulanenko@mail.ru"

extern int    StopLoss       = 100;
extern int    TakeProfit     = 50;
int    magicnumber    = 777;
extern double lots = 0.1;
extern int Ext1 = 1;
extern int Ext2 = 1;
extern bool AutoLotChanging = false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
int total = OrdersTotal();   
int SLB = Bid-(StopLoss*Point);
int TPB = Ask+(TakeProfit*Point);
int balance=AccountBalance()/500;
double lot=balance*0.1;
//----

              if (total == 0)
              {
              if (AutoLotChanging == true)
   {   
              OrderSend(Symbol(),OP_BUY,lot,Ask,3,SLB,TPB,"Doubler BUY",magicnumber,0,Green);
              OrderSend(Symbol(),OP_SELL,lot,Ask,3,TPB+(Ext1*Point),SLB-(Ext2*Point),"Doubler SELL",magicnumber,0,Green);
   }
   else
              OrderSend(Symbol(),OP_BUY,lots,Ask,3,SLB,TPB,"Doubler BUY",magicnumber,0,Green);
              OrderSend(Symbol(),OP_SELL,lots,Ask,3,TPB+(Ext1*Point),SLB-(Ext2*Point),"Doubler SELL",magicnumber,0,Green);

   }
   
   
   
   
   
   
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+