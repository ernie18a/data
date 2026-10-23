//+------------------------------------------------------------------+
//|                                                ListPositions.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.004"
#property description "List of positions"
#include <Trade\PositionInfo.mqh>
CPositionInfo  m_position;                   // trade position object
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnumSelectSymbol   // Enumeration of named constants 
  {
   all_symbols=0,      // All symbols
   current=1,          // Current symbol
  };
//--- input parameters
input ulong             m_magic  = ULONG_MAX;         // ULONG_MAX (18446744073709551615) -> all magic's
input EnumSelectSymbol  m_name   = all_symbols;       // SelectSymbol
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(6);
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
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string text="";
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         if(m_name==current)
            if(m_position.Symbol()!=Symbol())
               continue;
         if(m_magic!=ULONG_MAX)
            if(m_position.Magic()==m_magic)
               continue;
           {
            text+=IntegerToString(i)+
                  " | "+m_position.Symbol()+
                  " | "+IntegerToString(m_position.Ticket())+
                  " | "+TimeToString(m_position.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS)+
                  " | "+EnumToString(m_position.PositionType())+
                  " | "+DoubleToString(m_position.Volume(),2)+
                  " | "+DoubleToString(m_position.PriceOpen(),8)+
                  " | "+DoubleToString(m_position.StopLoss(),8)+
                  " | "+DoubleToString(m_position.TakeProfit(),8)+
                  " | "+DoubleToString(m_position.Swap(),8)+
                  " | "+DoubleToString(m_position.Profit(),8)+
                  "\n";
           }
        }
   Comment(text);
  }
//+------------------------------------------------------------------+
