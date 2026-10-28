//+------------------------------------------------------------------+
//|                                                 TrailingStop.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "Пример TrailingStop"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input ushort   InpTrailingStop    =10;       // TrailingStop (in pips)
input ushort   InpTrailingStep    =5;        // TrailingStep (in pips)
//---
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
ulong          m_magic=15489;                // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
bool           FirstStart=true;              // true - first start
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
   m_symbol.Name(Symbol());                  // sets symbol name
   m_symbol.Refresh();                       // refreshes the symbol data
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=digits_adjust*m_symbol.Point();
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;

   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

   FirstStart=true;
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
   if(FirstStart)
     {
      m_trade.Buy(0.01);
      m_trade.Sell(0.01);
      FirstStart=false;
     }
//--- TrailingStop
   if(!RefreshRates())
      return;

//--- при таком методе мы будет сюда попадать на каждом тике.
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            //--- TrailingStop -> подтягивание StopLoss у ПРИБЫЛЬНОЙ позиции
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- когда у позиции ещё нет StopLoss
               if(m_position.StopLoss()==0)
                 {
                  //--- пока StopLoss равен 0.0, TrailingStep не учитываем
                  if(m_symbol.Bid()-ExtTrailingStop>m_position.PriceOpen())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),0.0);
                    }
                 }
               //--- у позиции уже есть StopLoss
               else
                 {
                  //--- теперь TrailingStep нужно учитывать, иначе мы будет модифицировать 
                  //--- поизцию НА КАЖДОМ ТИКЕ, а это ПЛОХО
                  if(m_symbol.Bid()-ExtTrailingStop-ExtTrailingStep>m_position.StopLoss())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),
                                            NormalizeDouble(m_symbol.Bid()-ExtTrailingStop,m_symbol.Digits()),0.0);
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- когда у позиции ещё нет StopLoss
               if(m_position.StopLoss()==0)
                 {
                  //--- пока StopLoss равен 0.0, TrailingStep не учитываем
                  if(m_symbol.Ask()+ExtTrailingStop<m_position.PriceOpen())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),0.0);
                    }
                 }
               //--- у позиции уже есть StopLoss
               else
                 {
                  //--- теперь TrailingStep нужно учитывать, иначе мы будет модифицировать 
                  //--- поизцию НА КАЖДОМ ТИКЕ, а это ПЛОХО
                  if(m_symbol.Ask()+ExtTrailingStop+ExtTrailingStep<m_position.StopLoss())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),
                                            NormalizeDouble(m_symbol.Ask()+ExtTrailingStop,m_symbol.Digits()),0.0);
                    }
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
