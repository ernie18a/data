//+------------------------------------------------------------------+
//|                           OpenTicks(barabashkakvn's edition).mq5 |
//|                                        Copyright © 2008, ZerkMax |
//|                                                      zma@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, ZerkMax"
#property link      "zma@mail.ru"
#property description "Analysis of 4 previous bars"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\PartialClosing.mqh>
CPositionInfo  m_position;                      // trade position object
CSymbolInfo    m_symbol;                        // symbol info object
CAccountInfo   m_account;                       // account info wrapper
CPartialClosing m_trade_partial;                // trading object - partial closing
input ushort   TrailingStop   = 300;
input ushort   StopLoss       = 300;
input double   Lots           = 0.1;
input ulong    magicnumber    = 777;
input bool     HalfLots       = true;
input int      MaxOrders      =  1;

datetime prevtime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Lots<=0.0)
     {
      Print("The \"Lots\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                     // sets symbol name
   m_trade_partial.SetExpertMagicNumber(magicnumber);   // sets magic number
   RefreshRates();
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
//int i=0;
   int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      if(TrailingStop>0)
        {
         if(!m_position.SelectByIndex(i))
            return;
         if(m_position.Magic()==magicnumber)
           {
            TrailingStairs(m_position.Ticket(),TrailingStop);
           }
        }
     }

   bool BuyOp=false;
   bool SellOp=false;

   if(iHigh(m_symbol.Name(),Period(),1)>iHigh(m_symbol.Name(),Period(),2) &&
      iHigh(m_symbol.Name(),Period(),2)>iHigh(m_symbol.Name(),Period(),3) &&
      iHigh(m_symbol.Name(),Period(),3)>iHigh(m_symbol.Name(),Period(),4) &&
      iOpen(m_symbol.Name(),Period(),1)>iOpen(m_symbol.Name(),Period(),2) &&
      iOpen(m_symbol.Name(),Period(),2)>iOpen(m_symbol.Name(),Period(),3) &&
      iOpen(m_symbol.Name(),Period(),3)>iOpen(m_symbol.Name(),Period(),4))
      BuyOp=true;
   if(iHigh(m_symbol.Name(),Period(),1)<iHigh(m_symbol.Name(),Period(),2) &&
      iHigh(m_symbol.Name(),Period(),2)<iHigh(m_symbol.Name(),Period(),3) &&
      iHigh(m_symbol.Name(),Period(),3)<iHigh(m_symbol.Name(),Period(),4) &&
      iOpen(m_symbol.Name(),Period(),1)<iOpen(m_symbol.Name(),Period(),2) &&
      iOpen(m_symbol.Name(),Period(),2)<iOpen(m_symbol.Name(),Period(),3) &&
      iOpen(m_symbol.Name(),Period(),3)<iOpen(m_symbol.Name(),Period(),4))
      SellOp=true;

   if(iTime(m_symbol.Name(),Period(),0)==prevtime)
      return;
   prevtime=iTime(m_symbol.Name(),Period(),0);
   if(!IsTradeAllowed())
     {
      prevtime=iTime(m_symbol.Name(),Period(),1);
      return;
     }

   if(total<MaxOrders || MaxOrders==0)
     {
      if(!RefreshRates())
         return;
      if(BuyOp)
        {
         if(StopLoss!=0)
           {
            m_trade_partial.Buy(Lots,Symbol(),m_symbol.Ask(),m_symbol.Ask()-(StopLoss*Point()),0.0,"OpenTicks_Buy");
           }
         else
           {
            m_trade_partial.Buy(Lots,Symbol(),m_symbol.Ask(),0.0,0.0,"OpenTicks_Buy");
           }
        }
      if(SellOp)
        {
         if(StopLoss!=0)
           {
            m_trade_partial.Sell(Lots,Symbol(),m_symbol.Bid(),m_symbol.Bid()+(StopLoss*Point()),0.0,"OpenTicks_Sell");
           }
         else
           {
            m_trade_partial.Sell(Lots,Symbol(),m_symbol.Bid(),0.0,0.0,"OpenTicks_Sell");
           }
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Trailing Stairs                                                  |
//+------------------------------------------------------------------+
void TrailingStairs(ulong m_ticket,ushort trldistance)
  {
   if(!RefreshRates())
      return;
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      if((m_symbol.Bid()-m_position.PriceOpen())>(Point()*trldistance))
        {
         if(m_position.StopLoss()<m_symbol.Bid()-Point()*trldistance || (m_position.StopLoss()==0))
           {
            m_trade_partial.PositionModify(m_ticket,m_symbol.Bid()-Point()*trldistance,m_position.TakeProfit());
            if(HalfLots)
              {
               double half_volume=NormalizeDouble(m_position.Volume()/2,2);
               half_volume=LotCheck(half_volume);
               if(half_volume!=0.0 && half_volume!=m_position.Volume())
                  m_trade_partial.PositionClose(m_position.Ticket(),-1,half_volume);
               else
                  m_trade_partial.PositionClose(m_position.Ticket());
              }
           }
         else
           {
            m_trade_partial.PositionClose(m_ticket,-1);
           }
        }
     }
   else
     {
      if((m_position.PriceOpen()-m_symbol.Ask())>(Point()*trldistance))
        {
         if((m_position.StopLoss()>(m_symbol.Ask()+Point()*trldistance)) || (m_position.StopLoss()==0))
           {
            m_trade_partial.PositionModify(m_ticket,m_symbol.Ask()+Point()*trldistance,m_position.TakeProfit());
            if(HalfLots)
              {
               double half_volume=NormalizeDouble(m_position.Volume()/2,2);
               half_volume=LotCheck(half_volume);
               if(half_volume!=0.0 && half_volume!=m_position.Volume())
                  m_trade_partial.PositionClose(m_position.Ticket(),-1,half_volume);
               else
                  m_trade_partial.PositionClose(m_position.Ticket());
              }
            else
              {
               m_trade_partial.PositionClose(m_position.Ticket());
              }
           }
        }
     }
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
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
