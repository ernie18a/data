//+------------------------------------------------------------------+
//|                                                  nevalyashka.mq4 |
//|                            Copyright © 2015, Skype:  mqlcmillion |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Skype:  mqlcmillion "
#property link      "cmillion@narod.ru"
#property strict
#property description "Советник переворачивает ордера после закрытия"
//---
extern int    stoploss=10,//стоплосс
takeprofit  = 20,  //тейкпрофит
Magic       = 123; //идентификационный номер ордеров советника
extern double Lot         = 0.1; //начальный лот
extern double K_Lot       = 1.5; //коэффициент увеличения лота после убытка
double lot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   lot=Lot;
   if(OrderSend(Symbol(),OP_SELL,Lot,Bid,30,NormalizeDouble(Ask+stoploss*Point,Digits),
      NormalizeDouble(Bid-takeprofit*Point,Digits)," ",777,Blue)==-1) Print("Error");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int i,tip=0;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
           {
            return;
           }
        }
     }
   for(i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
           {
            tip=OrderType();
            if(OrderProfit()<0) lot=NormalizeDouble(OrderLots()*K_Lot,2);
            else lot=Lot;
            break;
           }
        }
     }
   if(tip==OP_BUY) if(OrderSend(Symbol(),OP_SELL,lot,NormalizeDouble(Bid,Digits),30,NormalizeDouble(Ask+stoploss*Point,Digits),
      NormalizeDouble(Bid-takeprofit*Point,Digits),NULL,Magic,clrNONE)==-1) Print("Error");
   if(tip==OP_SELL) if(OrderSend(Symbol(),OP_BUY,lot,NormalizeDouble(Ask,Digits),30,NormalizeDouble(Bid-stoploss*Point,Digits),
      NormalizeDouble(Ask+takeprofit*Point,Digits),NULL,Magic,clrNONE)==-1) Print("Error");
   return;
  }
//+------------------------------------------------------------------+
