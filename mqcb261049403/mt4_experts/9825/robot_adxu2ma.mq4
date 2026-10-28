//+------------------------------------------------------------------+
//|                                               Robot_ADX+2MA      |
//|                                               Yuriy Tokman (YTG) |
//|                                               https://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "https://ytg.com.ua"
#property version   "2.00"
#property strict

input int TakeProfit = 4700;
input int Sl = 2400;
input double Lots = 0.1;
input int n = 10;

int MagicNumber = 2808;
int Slippage = 30;
int POPYTKY = 10;
bool  gbDisabled = False;
#include     <stdlib.mqh>

             
//+------------------------------------------------------------------+
int start()
 {
  int ticket, total;
  double x1=iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,1);
  double x2=iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,1);
  double x3=MathAbs((x1-x2)/Point);
  double x4=iADX(NULL,0,6,0,MODE_PLUSDI,0);
  double x5=iADX(NULL,0,6,0,MODE_MINUSDI,0);
  double x6=iADX(NULL,0,6,0,MODE_PLUSDI,1);
  double x7=iADX(NULL,0,6,0,MODE_MINUSDI,1);
  double x8=iADX(NULL,0,6,0,MODE_PLUSDI,0);
  double x9=iADX(NULL,0,6,0,MODE_MINUSDI,0);

double ll=0,tp=0,sl=0;
     
  total=OrdersTotal();
  if(total<1)
   {
    if(AccountFreeMargin()<(1000*Lots) || Lots<=0)
     {
      Print("Insufficient funds = ", AccountFreeMargin());
      return(0);  
     }
    if (x1<x2 && x3>n && x6<5 && x4>10 && x8>x9 )
     {
      if(TakeProfit>0)tp=Ask + TakeProfit*Point;else tp=0;
      if(Sl>0)sl=Bid - Sl*Point;else sl=0;
      ll=Lots;
      OpenPosition(Symbol(), OP_BUY, ll, sl, tp, MagicNumber);
     }
    if (x1>x2 && x3>n && x7<5 && x5>10 && x8<x9 ) 
     {
      ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+Sl*Point,Bid-TakeProfit*Point,"-",0,0,Red);
      if(TakeProfit>0)tp=Bid - TakeProfit*Point;else tp=0;
      if(Sl>0)sl=Ask + Sl*Point;else sl=0;
      ll=Lots;
      OpenPosition(Symbol(), OP_SELL, ll, sl, tp, MagicNumber); 
     }
 }
 
 return(0);
 }
//+------------------------------------------------------------------+
int OpenPosition(string sy, int op, double ll, double sl=0, double tp=0, int mn=0, string cm ="") {
  color    clOpen;
  datetime ot;
  double   pp, pa, pb;
  int      dg, err, it, ticket=0;
  string   lsComm="http://ytg.com.ua/";
 
  if (sy=="" || sy=="0") sy=Symbol();
  if (op==OP_BUY) clOpen=Lime; else clOpen=Red;
  for (it=1; it<=POPYTKY; it++) {
    if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) {
      Print("OpenPosition(): Остановка работы функции");
      break;
    }
    while (!IsTradeAllowed()) Sleep(5000);
    RefreshRates();
    dg=(int)MarketInfo(sy, MODE_DIGITS);
    pa=MarketInfo(sy, MODE_ASK);
    pb=MarketInfo(sy, MODE_BID);
    if (op==OP_BUY) pp=pa; else pp=pb;
    pp=NormalizeDouble(pp, dg);
    ot=TimeCurrent();
//----+
    if(AccountFreeMarginCheck(Symbol(),op, ll)<=0 || GetLastError()==134)return(0);    
//----+ 
    ticket=OrderSend(sy, op, ll, pp, Slippage, sl, tp, lsComm, mn, 0, clOpen);
    if (ticket>0) {
      PlaySound("ok.wav"); break;
    } else {
      err=GetLastError();
      if (pa==0 && pb==0) Message("Проверьте в Обзоре рынка наличие символа "+sy);
      // Вывод сообщения об ошибке
      Print("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
      Print("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=",GetNameOP(op),
            " pp=",pp," sl=",sl," tp=",tp," mn=",mn);
      // Блокировка работы советника
      if (err==2 || err==64 || err==65 || err==133) {
        gbDisabled=True; break;
      }
      // Длительная пауза
      if (err==4 || err==131 || err==132) {
        Sleep(1000*300); break;
      }
      if (err==128 || err==142 || err==143) {
        Sleep(1000*66.666);
        if (ExistPositions(sy, op, mn, ot)) {
          PlaySound("ok.wav"); break;
        }
      }
      if (err==140 || err==148 || err==4110 || err==4111) break;
      if (err==141) Sleep(1000*100);
      if (err==145) Sleep(1000*17);
      if (err==146) while (IsTradeContextBusy()) Sleep(1000*11);
      if (err!=135) Sleep(1000*7.7);
    }
  }
  return(ticket);
}
//----
bool ExistPositions(string sy="", int op=-1, int mn=-1, datetime ot=0) {
  int i, k=OrdersTotal();
 
  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sy || sy=="") {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (op<0 || OrderType()==op) {
            if (mn<0 || OrderMagicNumber()==mn) {
              if (ot<=OrderOpenTime()) return(True);
            }
          }
        }
      }
    }
  }
  return(False);
}
//----
void Message(string m) {
  Comment(m);
  if (StringLen(m)>0) Print(m);
} 
//----
string GetNameOP(int op) {
  switch (op) {
    case OP_BUY      : return("Buy");
    case OP_SELL     : return("Sell");
    case OP_BUYLIMIT : return("Buy Limit");
    case OP_SELLLIMIT: return("Sell Limit");
    case OP_BUYSTOP  : return("Buy Stop");
    case OP_SELLSTOP : return("Sell Stop");
    default          : return("Unknown Operation");
  }
}
//----