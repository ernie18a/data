//+------------------------------------------------------------------+
//|                                                   Limits Pro.mq4 |
//|                                              Copyright 2017, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrdTypes
  {
   BUY=0,       // Buy
   SELL = 1,    // Sell
   MODIFY = 2,  // Modify
   DELETE = 3,  // Delete
  };
//--- input parameters
input OrdTypes OrdType=2; //Type of transaction
input double Lots=0.01;//Lot
input double StartPrice=1.28;//Price from
input double EndPrice=1.27;//Price up to
input double TakeProfit=0;//TakeProfit (price)
input double StopLoss=0;//StopLoss (price)
input int Step=100;//Step, (pips)
input bool Del=false;//Delete active orders

input int Magic=0;// Magic Number
input int SlipPage=2;// Slippage
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(!IsTradeAllowed()){ Print("Auto Trading disabled"); return; }
   if(OrdType<2)
     {
      Print("Start opening orders");
      OpenLimits();
     }
   if(OrdType==2)
     {
      Print("We begin the modification of orders");
      ModifyLimits();
     }
   if(OrdType==3)
     {
      Print("Beginning of order removal");
      DeleteLimits();
     }

  }
//+------------------------------------------------------------------+
void OpenLimits()
  {

   int CountOrder=0; double startP,endP,realLot; ENUM_ORDER_TYPE oType=OP_BUYSTOP;
   if(StartPrice>EndPrice){ startP=EndPrice; endP=StartPrice; }else{ startP=StartPrice; endP=EndPrice; }
   CountOrder=(int)NormalizeDouble(((endP-startP)/_Point)/Step,0);

   for(int i=0;i<=CountOrder;i++)
     {
      double curPrice=startP+i*Step*_Point;
      if(curPrice>Ask)
        {
         if(OrdType==0){ oType = OP_BUYSTOP; }
         if(OrdType==1){ oType = OP_SELLLIMIT; }
        }
      if(curPrice<Bid)
        {
         if(OrdType==0){ oType = OP_BUYLIMIT; }
         if(OrdType==1){ oType = OP_SELLSTOP; }
        }
      realLot=Lots;
      if(realLot<SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)){ realLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN); }
      if(realLot>SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)){ realLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX); }
      OpenOrder(realLot,curPrice,oType);
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenOrder(double lot,double prs,ENUM_ORDER_TYPE ot)
  {
   for(int c=0; c<=2; c++)
     {
      RefreshRates();
      int ticket=OrderSend(_Symbol,ot,lot,prs,SlipPage,StopLoss,TakeProfit,"",Magic,0,clrNONE);
      int e=GetLastError();
      if(e==0)
        {
         break;
           } else{ Print("Error open : ",ot," ",prs,"  ",StopLoss,"  ",TakeProfit," ",e); Sleep(10);
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyLimits()
  {
   double startP,endP;
   if(StartPrice>EndPrice){ startP=EndPrice; endP=StartPrice; }else{ startP=StartPrice; endP=EndPrice; }

   if(OrdersTotal()>0)
     {
      for(int c=0; c<OrdersTotal(); c++)
        {
         if(OrderSelect(c,SELECT_BY_POS))
           {
            if(OrderMagicNumber()==Magic && OrderSymbol()==_Symbol)
              {

               if(OrderOpenPrice()>=startP && OrderOpenPrice()<=endP)
                 {
                  int tiket=OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,TakeProfit,0,clrNONE);
                 }
              }
           }
        }
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLimits()
  {
   double startP,endP; int tiket;
   if(StartPrice>EndPrice){ startP=EndPrice; endP=StartPrice; }else{ startP=StartPrice; endP=EndPrice; }
   int total=OrdersTotal();
   if(total>0)
     {
      for(int c=total-1; c>=0; c--)
        {
         ResetLastError();
         if(OrderSelect(c,SELECT_BY_POS))
           {
            if(OrderMagicNumber()==Magic && OrderSymbol()==_Symbol)
              {

               if(OrderOpenPrice()>=startP && OrderOpenPrice()<=endP)
                 {
                  if(OrderType()==OP_BUY && Del)
                    {
                     tiket=OrderClose(OrderTicket(),OrderLots(),Bid,SlipPage);
                    }
                  if(OrderType()==OP_SELL && Del)
                    {
                     tiket=OrderClose(OrderTicket(),OrderLots(),Ask,SlipPage);
                    }
                  if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                    {
                     tiket=OrderDelete(OrderTicket());
                    }
                 }
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
