//+------------------------------------------------------------------+
//|                         SimpleTrade(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2008 Gryb Alexander |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008 Gryb Alexander"
#property link      ""
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
//--- input parameters
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
input ushort      StopLoss    = 120;
input double      Lots        = 1;
//---
ulong             m_slippage  = 3;           // slippage
ulong             m_magic     = 15489;       // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double            m_adjusted_point;          // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
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
   static datetime curTime=0;
//--- работаем только на новом баре (в момент "рождения" нового бара)
//--- внутри бара не работаем
   if(iTime(0)!=curTime)
     {
      curTime=iTime(0);

      //--- подсчёт количества открытых позиций
      int total=0;
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               total++;

      //--- если открытых позиций нет
      if(total==0)
        {
         if(iOpen(0)>iOpen(3))
           {
            //--- так как работаем только на новом баре, то при неудачном обновлении
            //--- текущих цен сбрасываем таймер
            if(!RefreshRates())
              {
               curTime=iTime(1);
               return;
              }
            //--- так как работаем только на новом баре, то при неудачной торговой операции
            //--- сбрасываем таймер
            if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),m_symbol.Ask()-StopLoss*m_adjusted_point))
               if(m_trade.ResultDeal()!=0)
                  return;
            curTime=iTime(1);
            return;
           }
         if(iOpen(0)<=iOpen(3))
           {
            //--- так как работаем только на новом баре, то при неудачном обновлении
            //--- текущих цен сбрасываем таймер
            if(!RefreshRates())
              {
               curTime=iTime(1);
               return;
              }
            //--- так как работаем только на новом баре, то при неудачной торговой операции
            //--- сбрасываем таймер
            if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),m_symbol.Bid()+StopLoss*m_adjusted_point))
               if(m_trade.ResultDeal()!=0)
                  return;
            curTime=iTime(1);
            return;
           }
        }
      else // если есть открытые позиции
        {
         //--- закрываем все позиции
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
            if(m_position.SelectByIndex(i))
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                  m_trade.PositionClose(m_position.Ticket());
         //--- сбрасываем таймер
         curTime=iTime(1);
         //if(Open[0]>Open[3]) OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,Ask-stop*Point,0);
         //if(Open[0]<=Open[3]) OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,Bid+stop*Point,0);
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
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
