//+------------------------------------------------------------------+
//|                                                   MyTrailing.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Mehmet CAK"
#property link      "https://www.mql5.com/en/users/doktorcak"
#property version   "1.0"
#property strict 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern double TP=20;//TP (pips)
extern double SL=20;//SL (pips)
extern double TStart=10;//TS Start (pips)
extern double TStop=5;//TS (pips)
extern double TStep=5;//TS Step (pips)



double _sl, _tp, _pip;

int Max_Slippage_pip_For_TakePosition=800;
double PIP;int dg;

int OnInit()
  {
//---
   PIP=Point();dg=1;
  if(Digits==3 || Digits==5) PIP*=10; dg=10;
  if(Digits<=2 || Digits==4) PIP*=1; dg=10;  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {


for(int i=0; i<=OrdersTotal()-1; i++)         
     {
      if (!OrderSelect(i,SELECT_BY_POS) )continue;
         if(OrderSymbol()!=Symbol())continue;

     }

bool r;
  double STL=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
  double trail=MathMax(TStop*PIP,STL),TSstart=TStart*PIP;
  double jump =MathMax(TStep,0.1)*PIP;
  double TSLB= Bid-trail; double TSLS=Ask+trail;

  for(int i=0; i<=OrdersTotal()-1; i++)         
     {
      if (!OrderSelect(i,SELECT_BY_POS) )continue;
         if(OrderSymbol()!=Symbol())continue;

           double theTP=OrderTakeProfit();
           double OOP= OrderOpenPrice();
           double theSL=OrderStopLoss();
           int OT=OrderTicket();
                    
            if (OrderType()==OP_BUY)
            { 
              if(theTP!=NormalizeDouble(OOP+TP*PIP,Digits) && theSL!=NormalizeDouble(OOP-SL*PIP,Digits) && OOP!=0 && TP!=0 && SL!=0)
              if(OrderModify(OT,OOP,NormalizeDouble(OOP-SL*PIP,Digits),NormalizeDouble(OOP+TP*PIP,Digits),0,clrNONE))continue;

              if(TStop!=0 && TSLB-OOP>=TSstart && theSL+jump <=TSLB)
              r= OrderModify(OT,OOP,TSLB,theTP,0,Green); 
             }
            if (OrderType()==OP_SELL)
            { 
              if(theTP!=NormalizeDouble(OOP-TP*PIP,Digits) && theSL!=NormalizeDouble(OOP+SL*PIP,Digits) && OOP!=0 && TP!=0 && SL!=0)
              if(OrderModify(OT,OOP,NormalizeDouble(OOP+SL*PIP,Digits),NormalizeDouble(OOP-TP*PIP,Digits),0,clrNONE))continue;

              if(TStop!=0 && OOP-TSLS>=TSstart && (theSL-jump >=TSLS||theSL==0))
              r= OrderModify(OT,OOP,TSLS,theTP,0,Red); 
            }
             
     }   
  }
//+------------------------------------------------------------------+
