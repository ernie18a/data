//+------------------------------------------------------------------+
//|                                          EA Money Management.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"

#include <FosterStewartCriterion.mqh>
//#include <MoneyManagement.mqh>

sinput ulong Magic=20260620;//Magic number
input uchar Slippage=5;
input ushort NumStrategies=2;//Number of strategies

sinput group "Buy Strategy"
input ushort PeriodBuy1=20,
             LevelBuy1=2;
//input ENUM_MONEYMANAGEMENT MoneyManagementBuy1=m_fixperc;
//input ushort RiskBuy1=0;

input ushort PeriodBuy2=115,
             LevelBuy2=4;
//input ENUM_MONEYMANAGEMENT MoneyManagementBuy2=m_fixperc;
//input ushort RiskBuy2=0;

input ushort PeriodBuy3=427,
             LevelBuy3=9;
//input ENUM_MONEYMANAGEMENT MoneyManagementBuy3=m_fixperc;
//input ushort RiskBuy3=0;

sinput group "Sell Strategy"
input ushort PeriodSell1=26,
             LevelSell1=10;
//input ENUM_MONEYMANAGEMENT MoneyManagementSell1=m_fixperc;
//input ushort RiskSell1=0;

input ushort PeriodSell2=134,
             LevelSell2=14;
//input ENUM_MONEYMANAGEMENT MoneyManagementSell2=m_fixperc;
//input ushort RiskSell2=0;

input ushort PeriodSell3=263,
             LevelSell3=25;
//input ENUM_MONEYMANAGEMENT MoneyManagementSell3=m_fixperc;
//input ushort RiskSell3=0;

CFosterStewartCriterion signbuy1,signbuy2,signbuy3,signsell1,signsell2,signsell3;

int stoploss,takeprofit,minsl;
ulong magicbuy1,magicbuy2,magicbuy3,magicsell1,magicsell2,magicsell3;
double volume;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   magicbuy1=Magic;
   magicbuy2=Magic+1;
   magicbuy3=Magic+2;
   magicsell1=Magic+3;
   magicsell2=Magic+4;
   magicsell3=Magic+5;

   signbuy1.Init(_Symbol,PERIOD_CURRENT,true,PeriodBuy1,LevelBuy1);
   signbuy2.Init(_Symbol,PERIOD_CURRENT,true,PeriodBuy2,LevelBuy2);
   signbuy3.Init(_Symbol,PERIOD_CURRENT,true,PeriodBuy3,LevelBuy3);

   signsell1.Init(_Symbol,PERIOD_CURRENT,false,PeriodSell1,LevelSell1);
   signsell2.Init(_Symbol,PERIOD_CURRENT,false,PeriodSell2,LevelSell2);
   signsell3.Init(_Symbol,PERIOD_CURRENT,false,PeriodSell3,LevelSell3);

   volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(NewBar()==true)
     {
      if(signbuy1.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK),lot=volume;
         if(BestPrice(price,magicbuy1)==true)
            PositionOpen(ORDER_TYPE_BUY,lot,price,price-stoploss*_Point,price+takeprofit*_Point,magicbuy1);
        }

      if(signbuy2.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK),lot=volume;
         if(BestPrice(price,magicbuy2)==true)
            PositionOpen(ORDER_TYPE_BUY,lot,price,price-stoploss*_Point,price+takeprofit*_Point,magicbuy2);
        }

      if(signbuy3.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK),lot=volume;
         if(BestPrice(price,magicbuy3)==true)
            PositionOpen(ORDER_TYPE_BUY,lot,price,price-stoploss*_Point,price+takeprofit*_Point,magicbuy3);
        }

      if(signsell1.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID),lot=volume;
         if(BestPrice(price,magicsell1)==true)
            PositionOpen(ORDER_TYPE_SELL,lot,price,price+stoploss*_Point,price-takeprofit*_Point,magicsell1);
        }

      if(signsell2.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID),lot=volume;
         if(BestPrice(price,magicsell2)==true)
            PositionOpen(ORDER_TYPE_SELL,lot,price,price+stoploss*_Point,price-takeprofit*_Point,magicsell2);
        }

      if(signsell3.CalcSignal(stoploss,takeprofit)==true)
        {
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID),lot=volume;
         if(BestPrice(price,magicsell3)==true)
            PositionOpen(ORDER_TYPE_SELL,lot,price,price+stoploss*_Point,price-takeprofit*_Point,magicsell3);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BestPrice(double price,ulong _magic)
  {
//---
   if(_magic==magicbuy1 || _magic==magicbuy2 || _magic==magicbuy3)
     {
      double min=DBL_MAX;
      for(int i=PositionsTotal()-1;i>-1;i--)
         if(PositionGetTicket(i)>0 && PositionGetInteger(POSITION_MAGIC)==_magic && PositionGetString(POSITION_SYMBOL)==_Symbol)
            min=MathMin(min,PositionGetDouble(POSITION_PRICE_OPEN));

      if(price<min)
         return(true);
     }
   else
     {
      double max=0;
      for(int i=PositionsTotal()-1;i>-1;i--)
         if(PositionGetTicket(i)>0 && PositionGetInteger(POSITION_MAGIC)==_magic && PositionGetString(POSITION_SYMBOL)==_Symbol)
            max=MathMax(max,PositionGetDouble(POSITION_PRICE_OPEN));

      if(price>max)
         return(true);
     }

   return(false);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionOpen(ENUM_ORDER_TYPE type,double lot,double price,double sl,double tp,ulong magic)
  {
//---
   double max_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
   if(max_volume==0)
      volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);

   for(int i=PositionsTotal()-1;i>-1;i--)
      if(PositionGetTicket(i)>0 && PositionGetString(POSITION_SYMBOL)==_Symbol)
         max_volume=max_volume-PositionGetDouble(POSITION_VOLUME);

   if(max_volume<lot)
      return;

   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(OrderCalcMargin(type,_Symbol,lot,price,margin)==false || margin>free_margin)
      return;

   MqlTradeRequest request= {};
   MqlTradeResult result= {};

   request.action=TRADE_ACTION_DEAL;
   request.symbol=_Symbol;
   request.deviation=Slippage;
   request.type=type;
   request.magic=magic;
   request.volume=lot;
   request.price=price;
   request.sl=NormalizeDouble(sl,_Digits);
   request.tp=NormalizeDouble(tp,_Digits);
   if(OrderSend(request,result)==false)
      Print("OrderSend error ",GetLastError());
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
//---
   static long lastbar;
   long curbar=SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE);
   if(lastbar<curbar)
     {
      lastbar=curbar;
      return(true);
     }
   return(false);
//---
  }
//+------------------------------------------------------------------+
