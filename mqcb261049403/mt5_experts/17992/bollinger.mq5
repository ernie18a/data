//+------------------------------------------------------------------+
//|                                                    bollinger.mq5 |
//|                                           Copyright 2017, DC2008 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2017, Sergey Pavlov (DC2008)"
#property link          "https://www.mql5.com/ru/users/dc2008"
#property version       "1.00"
#property description   "Example bollinger expert"
//---
#include <Trade\Trade.mqh>
//---
MqlTick    last_tick;
CTrade     trade;
//---
input int                  e_bands_period=80;           // период скользящей средней 
int                        e_bands_shift=0;             // сдвиг 
input double               e_deviation=3.0;             // кол-во стандартных отклонений  
input ENUM_APPLIED_PRICE   e_applied_price=PRICE_CLOSE; // тип цены 
//---
double lot=0.01;
bool   on_trade=false;
//--- переменная для хранения хэндла индикатора iBands 
int    handle;
//+------------------------------------------------------------------+
//| Структура сигнала                                                |
//+------------------------------------------------------------------+
struct sSignal
  {
   bool              Buy;    // сигнал на покупку
   bool              Sell;   // сигнал на продажу
  };
//+------------------------------------------------------------------+
//| Генератор сигналов                                               |
//+------------------------------------------------------------------+
sSignal Buy_or_Sell()
  {
   sSignal res={false,false};
//--- индикаторные буферы 
   double         UpperBuffer[];
   double         LowerBuffer[];
   double         MiddleBuffer[];
   ArraySetAsSeries(MiddleBuffer,true);
   CopyBuffer(handle,0,0,1,MiddleBuffer);
   ArraySetAsSeries(UpperBuffer,true);
   CopyBuffer(handle,1,0,1,UpperBuffer);
   ArraySetAsSeries(LowerBuffer,true);
   CopyBuffer(handle,2,0,1,LowerBuffer);
//--- таймсерии
   double L[];
   double H[];
   ArraySetAsSeries(L,true);
   CopyLow(_Symbol,_Period,0,1,L);
   ArraySetAsSeries(H,true);
   CopyHigh(_Symbol,_Period,0,1,H);
   if(H[0]>UpperBuffer[0] && L[0]>MiddleBuffer[0])
      res.Sell=true;
   if(L[0]<LowerBuffer[0] && H[0]<MiddleBuffer[0])
      res.Buy=true;
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");
//--- создадим хэндл индикатора 
   handle=iBands(_Symbol,_Period,e_bands_period,e_bands_shift,e_deviation,e_applied_price);
   if(handle==INVALID_HANDLE)
      return(INIT_FAILED);
   else
      on_trade=true;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(on_trade)
     {
      sSignal signal=Buy_or_Sell();
      //--- BUY
      if(signal.Buy)
        {
         if(!PositionSelect(_Symbol))
           {
            SymbolInfoTick(_Symbol,last_tick);
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,NormalizeDouble(lot,2),last_tick.ask,0,0,"BUY: new position");
           }
         else
           {
            if(PositionGetDouble(POSITION_PROFIT)<0) return;
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               trade.PositionClose(_Symbol);
               SymbolInfoTick(_Symbol,last_tick);
               trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,NormalizeDouble(lot,2),last_tick.ask,0,0,"BUY: reversal");
              }
           }
        }

      //--- SELL
      if(signal.Sell)
        {
         if(!PositionSelect(_Symbol))
           {
            SymbolInfoTick(_Symbol,last_tick);
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,NormalizeDouble(lot,2),last_tick.bid,0,0,"SELL: new position");
           }
         else
           {
            if(PositionGetDouble(POSITION_PROFIT)<0) return;
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               trade.PositionClose(_Symbol);
               SymbolInfoTick(_Symbol,last_tick);
               trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,NormalizeDouble(lot,2),last_tick.bid,0,0,"SELL: reversal");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
