//|                                      Copyright © 2019, Abu Saidu |
//|                                                t.me/ask4abusaidu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Abu Saidu"
#property link     "https://www.mql5.com/en/users/ask4abusaidu"
 ""
#property description "For more information contact" // Description (line 1)
#property description ">>Telegram = t.me/ask4abusaidu<<"
#property description ">>whatsapp = +2347018717038<<"
#property version "1.0"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>

extern int     MagicNumber=15485;
extern int     StopLoss = 100;
extern int     TakeProfit = 200;

bool crossed[2];

//bool crossed[6];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   for (int i = 0; i < ArraySize(crossed); i++)
      crossed[i] = true;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars<100 || IsTradeAllowed()==false)
      return;
   OrderTest();
  }
 //+------------------------------------------------------------------+
//|                                                                  |
bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
  {
   bool ret = condition && !crossed[i];
   crossed[i] = condition;
   return(ret);
  }
//+------------------------------------------------------------------+
void OrderTest()
  {
   int send=-1;
   double MA[3];
  double  BSL = Ask - StopLoss * Point;
  double  SSL = Bid + StopLoss * Point;
  double  BTP = Ask + TakeProfit * Point;
  double  STP = Bid - TakeProfit * Point;

   MA[0]=iMA(NULL,0,200,0,MODE_EMA,PRICE_CLOSE,0);
//   MA[1]=iMA(NULL,0,150,0,MODE_EMA,PRICE_CLOSE,0);
//   MA[2]=iMA(NULL,0,100,0,MODE_EMA,PRICE_CLOSE,0);
//buy entry
  if(Cross(0, Open[0] > MA[0]))
      send=OrderSend(NULL,OP_BUY,MarketInfo(Symbol(),MODE_MINLOT),Ask,3,BSL,BTP);
/*  if(Cross(1, Open[0] > MA[1]))
      send=OrderSend(NULL,OP_BUY,MarketInfo(Symbol(),MODE_MINLOT),Ask,3,BSL,BTP);
  if(Cross(2, Open[0] > MA[2]))
      send=OrderSend(NULL,OP_BUY,MarketInfo(Symbol(),MODE_MINLOT),Ask,3,BSL,BTP);
*///sell entry
  if(Cross(1, Open[0] < MA[0]))
      send=OrderSend(NULL,OP_SELL,MarketInfo(Symbol(),MODE_MINLOT),Bid,3,SSL,STP);
/*  if(Cross(4, Open[0] < MA[1]))
      send=OrderSend(NULL,OP_SELL,MarketInfo(Symbol(),MODE_MINLOT),Bid,3,SSL,STP);
  if(Cross(5, Open[0] < MA[2]))
      send=OrderSend(NULL,OP_SELL,MarketInfo(Symbol(),MODE_MINLOT),Bid,3,SSL,STP);
*/
  }
//+------------------------------------------------------------------+