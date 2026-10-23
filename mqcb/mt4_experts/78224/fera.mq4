//+------------------------------------------------------------------+
//|                                                     WITCH666.mq4 |
//+------------------------------------------------------------------+
#property copyright   "http://www.FinanceWave.com™"
#property strict

extern double CashAccount = 41;
extern double minlots =1; 
extern double Spread=50;

double dp = 2;
double rr = 8;

int Ticket,Ticket2,buy,sell,buylimit,selllimit,cnt,trade=1;
double Lot,PriceBuy,PriceSell,PriceBuyTP,PriceSellTP,Margin,StopLevel;
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int OnInit()
{return(0);}
//+------------------------------------------------------------------+
//| Modify selected order only if levels are valid and changed       |
//+------------------------------------------------------------------+
void ModifyOrder(double price,double tp,color clr)
{
price=NormalizeDouble(price,Digits);
tp=NormalizeDouble(tp,Digits);

if(price==NormalizeDouble(OrderOpenPrice(),Digits) && tp==NormalizeDouble(OrderTakeProfit(),Digits))
return;

if(OrderType()==OP_BUYLIMIT && (price>Ask-StopLevel || tp<price+StopLevel))
return;
if(OrderType()==OP_SELLLIMIT && (price<Bid+StopLevel || tp>price-StopLevel))
return;
if(OrderType()==OP_BUY && tp<Bid+StopLevel)
return;
if(OrderType()==OP_SELL && tp>Ask-StopLevel)
return;

OrderModify(OrderTicket(),price,0,tp,0,clr); 
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

Lot=MarketInfo(Symbol(),MODE_MINLOT)*minlots;
StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point+(Ask-Bid);
Margin=0.33*(iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_UPPER,0)-iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_MAIN,0));
PriceSell=NormalizeDouble(MathMax(iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_MAIN,0)+rr*Spread*Point,iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_UPPER,0)+(Ask-Bid)),Digits);
PriceSellTP=NormalizeDouble(iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_MAIN,0)+Margin-(Ask-Bid),Digits);
PriceBuy=NormalizeDouble(MathMin(iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_MAIN,0)-rr*Spread*Point,iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_LOWER,0)-(Ask-Bid)),Digits);
PriceBuyTP=NormalizeDouble(iBands(NULL,0,20,dp,0,PRICE_CLOSE,MODE_MAIN,0)-Margin+(Ask-Bid),Digits);

if(OrdersTotal()==0 && trade==1)
{
if(PriceBuy<=Ask-StopLevel && PriceBuyTP>=PriceBuy+StopLevel)
Ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lot,PriceBuy,0,0,PriceBuyTP,"Hedge HFT",20000,0,Blue);
if(PriceSell>=Bid+StopLevel && PriceSellTP<=PriceSell-StopLevel)
Ticket2=OrderSend(Symbol(),OP_SELLLIMIT,Lot,PriceSell,0,0,PriceSellTP,"Hedge HFT",40000,0,Red);
}

if(OrdersTotal()==2 && trade==1)
{

for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
{

if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
continue;

if(OrderType()==OP_BUYLIMIT)
{
ModifyOrder(PriceBuy,PriceBuyTP,Blue); 
}
if(OrderType()==OP_SELLLIMIT)
{
ModifyOrder(PriceSell,PriceSellTP,Red); 
}

if(OrderType()==OP_BUY)
{
ModifyOrder(OrderOpenPrice(),PriceBuyTP,Blue); 
}
if(OrderType()==OP_SELL)
{
ModifyOrder(OrderOpenPrice(),PriceSellTP,Red); 
}

}

}

if(OrdersTotal()==1 && trade==1)
{
buy=0;
sell=0;
buylimit=0;
selllimit=0;

for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
{

if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
continue;

if(OrderType()==OP_BUYLIMIT)
{
buylimit=1;
ModifyOrder(PriceBuy,PriceBuyTP,Blue); 
}
if(OrderType()==OP_SELLLIMIT)
{
selllimit=1;
ModifyOrder(PriceSell,PriceSellTP,Red); 
}

if(OrderType()==OP_BUY)
{
buy=1;
ModifyOrder(OrderOpenPrice(),PriceBuyTP,Blue); 
}
if(OrderType()==OP_SELL)
{
sell=1;
ModifyOrder(OrderOpenPrice(),PriceSellTP,Red); 
}

}

if(buy!=1 && buylimit!=1)
{
if(PriceBuy<=Ask-StopLevel && PriceBuyTP>=PriceBuy+StopLevel)
Ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lot,PriceBuy,0,0,PriceBuyTP,"Hedge HFT",20000,0,Blue);
}

if(sell!=1 && selllimit!=1)
{
if(PriceSell>=Bid+StopLevel && PriceSellTP<=PriceSell-StopLevel)
Ticket2=OrderSend(Symbol(),OP_SELLLIMIT,Lot,PriceSell,0,0,PriceSellTP,"Hedge HFT",40000,0,Red);
}

}

if(MathMin(AccountBalance(),AccountEquity())<CashAccount && OrdersTotal()>0)
{
for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
{

if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
continue;

if(OrderType()==OP_BUY)
OrderClose(OrderTicket(),OrderLots(),Bid,0,Violet);
if(OrderType()==OP_SELL)
OrderClose(OrderTicket(),OrderLots(),Ask,0,Violet);
if(OrderType()>OP_SELL)
OrderDelete(OrderTicket(),Purple);

}
trade=0;
}

}
//+------------------------------------------------------------------+
// ✓