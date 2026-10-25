//+------------------------------------------------------------------+
//|                                                    maxprofit.mq4 |
//|                                           ShahramOliya@gmail.com |
//|                       https://www.mql5.com/en/users/best-experts |
//+------------------------------------------------------------------+
#property copyright "ShahramOliya@gmail.com"
#property link      "https://www.mql5.com/en/users/best-experts"
#property version   "1.00"
#property strict
double maximiz;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
 //  double maxprofit;
  // double maximiz=0;
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
//---
//+------------------------------تابع پیدا کردن ماکزیمم سود-------------------------------------+
if(OrdersTotal()==0)
{
maximiz=0;
}
else
{
   bool order0=OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   double profit=OrderProfit();
    if (profit>=maximiz)
      {
      maximiz=profit;
      }
}
//   return(max); 
   Comment("maxprofit 0 ",maximiz); 
   
  }
//+------------------------------------------------------------------+




