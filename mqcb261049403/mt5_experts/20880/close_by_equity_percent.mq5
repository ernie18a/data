//+------------------------------------------------------------------+
//|             Close by Equity Percent(barabashkakvn's edition).mq5 |
//|                            Copyright 2012, adam malik bin kasang |
//|                                             adamkasang@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, adam malik bin kasang"
#property link      "adamkasang@gmail.com"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double equity_percent_from_balances=1.2; // Equity Percent From Balances
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=50;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
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
//---
   if(m_account.Equity()>=m_account.Balance()*equity_percent_from_balances)
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
         if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
           {
            m_trade.SetExpertMagicNumber(m_position.Magic());
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
           }
  }
//+------------------------------------------------------------------+
