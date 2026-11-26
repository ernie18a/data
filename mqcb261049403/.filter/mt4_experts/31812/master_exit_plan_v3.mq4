//+------------------------------------------------------------------+
//|                                             Master Exit Plan.mq4 |
//|                                 Copyright © 2016, Joel Protusada |
//|                     https://www.facebook.com/groups/FXFledgling/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016 by Joel Protusada"
#property link      "https://www.facebook.com/groups/FXFledgling/"
#property version   "3.00"
#property strict

//+------------------------------------------------------------------+
//| P A R A M E T E R S                                              |
//+------------------------------------------------------------------+
extern string LINE1="=================Target Equity===================================="; //================= 
extern bool   EnableTQ=false; //Enable Target Equity to Close All
extern double TargetEQ=1; //Target % of Equity
extern string LINE2="=================Stop Loss================================"; //================= 
extern bool   EnableSL=false; //Enable Hidden Stop-Loss
extern double HiddenSL=800; //Hidden Stop-Loss in Points
extern bool   EnableHSL=false; //Enable Hard Stop-Loss
extern double DummySL=2000; //Hard Stop-Loss in Points
extern bool   EnableDSL=false; //Enable Hidden Dynamic SL
extern double HiddenDSL=800; //Hidden Dynamic Stop-Loss in Points
extern bool   EnableHDSL=false; //Enable Hard Dynamic Stop-Loss
extern double DummyDSL=2000; //Dynamic Hard Stop-Loss in Points
extern string LINE3="=================Trail Stop======================================="; //================= 
extern bool   EnableTS= false; //Enable Trail Stop
extern double TrailStopPts= 5; //Trail Stop in Points 
extern double Target= 0.2; //TS % Target
extern double SurePts= 30; //Sure Profit Points
extern string LINE4="=================Trail Pending Stop Order=============================="; //================= 
extern bool   EnableTrailPO=false; //Enable Trail Pending Order
extern double TrailPOPts=10; //Trail Pending Order in Points

//+------------------------------------------------------------------+
//| V A R I A B L E S                                                |
//+------------------------------------------------------------------+
string com = "";
double tar = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   tar=AccountBalance()+(AccountBalance()*TargetEQ/100);
//--- create timer     
   EventSetTimer(1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   OnTimer();
  }
//+------------------------------------------------------------------+
//| Runs on every tick and every 1 minute                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   com="\n\n";
   if(EnableTQ) CloseTarget();
   if(EnableDSL) DSL();
   if(EnableSL) StopLoss();
   if(EnableHDSL) HDSL();
   if(EnableHSL) HStopLoss();
   if(EnableTS>0) TrailStop();
   if(EnableTrailPO>0) TrailPO();
   if(com=="\n\n") com+="";
   Comment(com);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CLOSE ON EQUITY TARGET                                           |
//+------------------------------------------------------------------+
void CloseTarget()
  {
   com+="\n\nTarget Equity: "+AccountCurrency()+" "+DoubleToStr(tar,2)+"\n";
   if(tar<AccountEquity())
     {
      CloseAll();
      tar=AccountBalance()+(AccountBalance()*TargetEQ/100);
     }
  }
  
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int t=OrderSelect(i,SELECT_BY_POS);

      bool result=false;
      if( OrderType() == OP_BUY)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
      if( OrderType() == OP_SELL)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
      if( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
      if( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
      if( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
      if( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
     }
   return;
  }
//+------------------------------------------------------------------+
//| DYNAMIC STOP-LOSS                                                |
//+------------------------------------------------------------------+
void DSL()
  {
   RefreshRates();

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int t=OrderSelect(i,SELECT_BY_POS);

      bool result= false;
      double o   = iOpen(OrderSymbol(),1,1);
      double bid = MarketInfo(OrderSymbol(),MODE_BID);
      double ask = MarketInfo(OrderSymbol(),MODE_ASK);
      double pt  = MarketInfo(OrderSymbol(),MODE_POINT);
      int    dig = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
      if(OrderType()==OP_BUY)
        {
         if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0)
           {
            double dsl=o-(DummyDSL*pt);

            if(dsl>0 && ((OrderStopLoss()==0 && dsl<OrderOpenPrice()) || (dsl!=OrderStopLoss() && OrderStopLoss()<=OrderOpenPrice())))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(dsl,dig),OrderTakeProfit(),0,White);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Dummy Dynamic Stop-Loss: "+DoubleToStr(dsl,dig);
              }
           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)
           {
            double dsl=o+(DummyDSL*pt);

            if(dsl>0 && ((OrderStopLoss()==0 && dsl>OrderOpenPrice()) || (dsl!=OrderStopLoss() && OrderStopLoss()>=OrderOpenPrice())))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(dsl,dig),OrderTakeProfit(),0,White);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Dummy Dynamic Stop-Loss: "+DoubleToStr(dsl,dig);
              }
           }
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//| HIDDEN DYNAMIC STOP-LOSS                                         |
//+------------------------------------------------------------------+
void HDSL()
  {
   RefreshRates();

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int t=OrderSelect(i,SELECT_BY_POS);

      bool result= false;
      double o   = iOpen(OrderSymbol(),1,1);
      double bid = MarketInfo(OrderSymbol(),MODE_BID);
      double ask = MarketInfo(OrderSymbol(),MODE_ASK);
      double pt  = MarketInfo(OrderSymbol(),MODE_POINT);
      int    dig = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
      if(OrderType()==OP_BUY)
        {
         if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0)
           {
            if(o-(HiddenDSL*pt)>ask)
              {
               result=OrderClose(OrderTicket(),OrderLots(),bid,5,Red);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Hidden Dynamic Stop-Loss: "+DoubleToStr(o-(HiddenDSL*pt),dig);

              }

           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)
           {
            if(o+(HiddenDSL*pt)<bid)
              {
               result=OrderClose(OrderTicket(),OrderLots(),ask,5,Red);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Hidden Dynamic Stop-Loss: "+DoubleToStr(o+(HiddenDSL*pt),dig);

              }
           }
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//| HARD STOP-LOSS                                                   |
//+------------------------------------------------------------------+
void StopLoss()
  {
   RefreshRates();

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int t=OrderSelect(i,SELECT_BY_POS);

      bool result=false;
      //double o   = iOpen(OrderSymbol(),1,1);
      double bid = MarketInfo(OrderSymbol(),MODE_BID);
      double ask = MarketInfo(OrderSymbol(),MODE_ASK);
      double pt  = MarketInfo(OrderSymbol(),MODE_POINT);
      int    dig = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
      if(OrderType()==OP_BUY)
        {
         if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0)
           {
            if(OrderStopLoss()==0)
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-(DummySL*pt),dig),OrderTakeProfit(),0,White);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Dummy Stop-Loss: "+DoubleToStr(OrderOpenPrice()-(DummySL*pt),dig);
              }
           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)
           {
            //double dsl = o+(DummyDSL*pt);

            if(OrderStopLoss()==0)
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+(DummySL*pt),dig),OrderTakeProfit(),0,White);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Dummy Stop-Loss: "+DoubleToStr(OrderStopLoss()+(DummySL*pt),dig);
              }
           }
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//| HIDDEN STOP-LOSS                                                 |
//+------------------------------------------------------------------+
void HStopLoss()
  {
   RefreshRates();

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int t=OrderSelect(i,SELECT_BY_POS);

      bool result=false;
      //double o   = iOpen(OrderSymbol(),1,1);
      double bid = MarketInfo(OrderSymbol(),MODE_BID);
      double ask = MarketInfo(OrderSymbol(),MODE_ASK);
      double pt  = MarketInfo(OrderSymbol(),MODE_POINT);
      int    dig = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
      if(OrderType()==OP_BUY)
        {
         if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0)
           {
            if(OrderOpenPrice()-(HiddenDSL*pt)>ask)
              {
               result=OrderClose(OrderTicket(),OrderLots(),bid,5,Red);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Hidden Stop-Loss: "+DoubleToStr(OrderOpenPrice()-(HiddenDSL*pt),dig);
              }

           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)
           {
            if(OrderOpenPrice()+(HiddenDSL*pt)<bid)
              {
               result=OrderClose(OrderTicket(),OrderLots(),ask,5,Red);
               Sleep(500);
               com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Hidden Stop-Loss: "+DoubleToStr(OrderOpenPrice()+(HiddenDSL*pt),dig);

              }
           }
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//| TRAIL STOP                                                       |
//+------------------------------------------------------------------+
void TrailStop()
  {
   double target=MathMax(0.2,(AccountBalance()*Target)/100);
   com+="\n\nTrail-Stop % Target: "+DoubleToStr(target,2);
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      RefreshRates();

      if(OrderSelect(i,SELECT_BY_POS))
        {
         int    digits = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
         double sl     = OrderStopLoss();
         double open   = NormalizeDouble(OrderOpenPrice(),digits);
         double ask    = MarketInfo(OrderSymbol(),MODE_ASK);
         double bid    = MarketInfo(OrderSymbol(),MODE_BID);
         double point  = MarketInfo(OrderSymbol(),MODE_POINT);
         double tp     = NormalizeDouble(OrderTakeProfit(),digits);
         int    ticket = OrderTicket();
         int    type   = OrderType();
         double spread = (double) SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);

         com+="\n"+IntegerToString(OrderTicket())+" "+OrderSymbol()+" Profit: "+DoubleToStr(OrderProfit()+OrderCommission()+OrderSwap(),2);
         if(OrderProfit()+OrderCommission()+OrderSwap()>target)
           {

            if(type==OP_BUY)
              {
               if(sl<NormalizeDouble(bid -((TrailStopPts+SurePts+spread)*point),digits) || sl==0)
                 {
                  if(!OrderModify(ticket,open,NormalizeDouble(bid -(TrailStopPts+spread)*point,digits),tp,0))
                     Print("OrderModify - Buy has been ended with an error #",GetLastError());
                 }
              }

            if(type==OP_SELL)
              {
               if(sl>NormalizeDouble(ask+(TrailStopPts+SurePts+spread)*point,digits) || sl==0)
                 {
                  if(!OrderModify(ticket,open,NormalizeDouble(ask+(TrailStopPts+spread)*point,digits),tp,0))
                     Print("OrderModify - Sell has been ended with an error #",GetLastError());
                 }
              }

           }
        }
     }

  }
//+------------------------------------------------------------------+
//| TRAIL PO                                                         |
//+------------------------------------------------------------------+
void TrailPO()
  {
   int totalorders=OrdersTotal();
   for(int i=totalorders-1;i>=0;i--)
     {
      int r=OrderSelect(i,SELECT_BY_POS);
      bool result=false;
      RefreshRates();

      double bid = MarketInfo(OrderSymbol(),MODE_BID);
      double ask = MarketInfo(OrderSymbol(),MODE_ASK);
      int    dig = (int) MarketInfo(OrderSymbol(),MODE_DIGITS);
      double pts = MarketInfo(OrderSymbol(),MODE_POINT);
      double lvl = TrailPOPts+MathMax(MarketInfo(Symbol(),MODE_STOPLEVEL),MarketInfo(Symbol(),MODE_SPREAD));
      double pbuy   =   NormalizeDouble(ask+(lvl*pts),dig);
      double psel   =   NormalizeDouble(bid-(lvl*pts),dig);

      if(OrderType()==OP_BUYSTOP && OrderOpenPrice()>pbuy)
        {
         int error=OrderModify(OrderTicket(),pbuy,OrderStopLoss(),0,0,White);
        }
      else
      if(OrderType()==OP_SELLSTOP && OrderOpenPrice()<psel)
        {
         int error=OrderModify(OrderTicket(),psel,OrderStopLoss(),0,0,White);
        }

     }
   return;
  }
//+------------------------------------------------------------------+
