//+------------------------------------------------------------------+
//|                                                   N-_Candles.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "We look for N-of identical candles which go in a row"
//---
#include <Trade\Trade.mqh>
CTrade         m_trade;                      // trading object
//--- input parameter
input uchar    InpN_candles   = 3;           // N identical candles which go in a row 
input double   InpLot         = 0.01;        // Lot
input ulong    m_magic        = 15489;       // magic number
input ulong    m_slippage     = 30;          // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
//---
   m_trade.SetDeviationInPoints(m_slippage);
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   MqlRates rates[];
   int copied=CopyRates(NULL,0,1,InpN_candles,rates);
//--- Example:
//--- rates[0].time -> D'2015.05.28 00:00:00'
//--- rates[2].time -> D'2015.06.01 00:00:00'
   if(copied<=0)
     {
      Print("Error copying price data ",GetLastError());
      return;
     }

   bool result=true;
//--- Bull candle. Bear candle.
   int type_of_candles=0;     // "1" -> Bull candle. "-1" ->Bear candle

   for(int i=0;i<copied;i++)
     {
      //--- We define type of the most distant candle
      if(i==0)
        {
         if(rates[i].open<rates[i].close)
            type_of_candles=1;
         else if(rates[i].open>rates[i].close)
            type_of_candles=-1;
         else
           {
            result=false;
            break;
           }

         continue;
        }

      if(type_of_candles==1) // "1" -> Bull candle
        {
         if(rates[i].open>rates[i].close)
           {
            result=false;
            break;
           }
        }
      else // "-1" ->Bear candle
        {
         if(rates[i].open<rates[i].close)
           {
            result=false;
            break;
           }
        }
     }

   if(!result)
      return;

//--- We here. Means we have found N-of candles in a row
   if(type_of_candles==1) // "1" -> Bull candle
      m_trade.Buy(InpLot);
   else
      m_trade.Sell(InpLot);

   int d=0;
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+ 
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
