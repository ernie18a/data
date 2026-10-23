//+------------------------------------------------------------------+
//|                           WOC.0.1.2(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
input ushort   InpStopLoss       = 6;  // начальный стоплосс
input ushort   InpTrailingStop   = 6;  // Trailing
input int      Speed             = 5;
input double   timeSpeed         = 3;
input double   InpLots=0.01; // лот                                     
input bool     AutoLots=false;
//---
ulong          m_magic=531572760;                // magic number
double         Point_;
datetime       nextTime=0,TimeSpeedUp=0,TimeSpeedDown=0;
int            lastBars;
int            up,down;
bool           TimBoolUp=false,TimBoolDown=false,OrderSal=false;
double         priceUp=0.0,priceDown=0.0;
//---
double  ExtStopLoss=0.0;
double  ExtTrailingStop=0.0;
double  ExtLots=0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LotsSize()
  {
   double acc_balance=m_account.Balance();

   if(acc_balance<200)
      ExtLots=0.02;

   if(acc_balance>200)
      ExtLots=0.04;

   if(acc_balance>300)
      ExtLots=0.05;

   if(acc_balance>400)
      ExtLots=0.06;

   if(acc_balance>500)
     {
      ExtLots=0.07;
     }
   if(acc_balance>600)
      ExtLots=0.08;

   if(acc_balance>700)
      ExtLots=0.09;

   if(acc_balance>800)
      ExtLots=0.1;

   if(acc_balance>900)
      ExtLots=0.2;

   if(acc_balance>1000)
      ExtLots=0.3;

   if(acc_balance>2000)
      ExtLots=0.4;

   if(acc_balance>3000)
      ExtLots=0.5;

   if(acc_balance>4000)
      ExtLots=0.6;

   if(acc_balance>5000)
     {
      ExtLots=0.7;
     }
   if(acc_balance>6000)
      ExtLots=0.8;

   if(acc_balance>7000)
      ExtLots=0.9;

   if(acc_balance>8000)
      ExtLots=1;

   if(acc_balance>9000)
      ExtLots=2;

   if(acc_balance>10000)
      ExtLots=3;

   if(acc_balance>11000)
      ExtLots=4;

   if(acc_balance>12000)
      ExtLots=5;

   if(acc_balance>13000)
      ExtLots=6;

   if(acc_balance>14000)
      ExtLots=7;

   if(acc_balance>15000)
      ExtLots=8;

   if(acc_balance>20000)
      ExtLots=9;

   if(acc_balance>30000)
      ExtLots=10;

   if(acc_balance>40000)
      ExtLots=11;

   if(acc_balance>50000)
      ExtLots=12;

   if(acc_balance>60000)
      ExtLots=13;

   if(acc_balance>70000)
      ExtLots=14;

   if(acc_balance>80000)
      ExtLots=15;

   if(acc_balance>90000)
      ExtLots=16;

   if(acc_balance>100000)
      ExtLots=17;

   if(acc_balance>110000)
      ExtLots=18;

   if(acc_balance>120000)
      ExtLots=19;

   if(acc_balance>130000)
      ExtLots=20;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPositions()
  {
   int try;
   if(AutoLots==true)
     {
      LotsSize();
     }

   if(up<down)
     {
      Print("Параметр вниз - удовлетворяет условию");
      if(TimeCurrent()-TimeSpeedDown<=timeSpeed)
        {
         Print("Параметр ВРЕМЯ - удовлетворяет условию");

         if(!RefreshRates())
            return;

         for(try=1; try<=2; try++)
           {
            if(!m_trade.Sell(ExtLots,Symbol(),m_symbol.Bid()))
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
              }
            else
              {
               OrderSal=true;
               break;
              }
           }
        }
     }
   else
     {
      Print("Параметр вверх - удовлетворяет условию");
      if(TimeCurrent()-TimeSpeedUp<=timeSpeed)
        {
         Print("Параметр ВРЕМЯ - удовлетворяет условию");

         if(!RefreshRates())
            return;

         for(try=1; try<=2; try++)
           {
            if(!m_trade.Buy(ExtLots,Symbol(),m_symbol.Ask()))
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
              }
            else
              {
               OrderSal=true;
               break;
              }
           }

        }
     }
   priceUp   = 0;
   priceDown = 0;
   up        = 0;
   down      = 0;
   TimBoolUp = false;
   TimBoolDown = false;
   TimeSpeedUp = 0;
   TimeSpeedDown=0;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtLots           = InpLots;
   ExtStopLoss       = InpStopLoss     * digits_adjust * m_symbol.Point();
   ExtTrailingStop   = InpTrailingStop * digits_adjust * m_symbol.Point();

   nextTime=0;TimeSpeedUp=0;TimeSpeedDown=0;
   TimBoolUp=false; TimBoolDown=false; OrderSal=false;
   priceUp=0.0; priceDown=0.0;

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
   int open_positions=-1;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            open_positions=i;
            break;
           }
   if(!RefreshRates())
      return;

//--- for testing
   double BID=m_symbol.Bid();
   double ASK=m_symbol.Ask();

   if(open_positions<0)
     {
      if(priceUp<m_symbol.Ask())
        {
         up=up+1;
         priceUp=m_symbol.Ask();
         if(TimBoolUp==false)
           {
            TimeSpeedUp=TimeCurrent();
            TimBoolUp=true;
           }
        }
      else
        {
         priceUp=0;

         up=0;
         TimBoolUp=false;
         TimeSpeedUp=0;
        }

      if(priceDown>m_symbol.Ask())
        {
         down=down+1;
         priceDown=m_symbol.Ask();
         if(TimBoolDown==false)
           {
            TimeSpeedDown=TimeCurrent();
            TimBoolDown=true;
           }
        }
      else
        {
         priceDown = 0;
         down      = 0;
         TimBoolDown=false;
         TimeSpeedDown=0;
        }

      if(up==Speed || down==Speed)
        {
         OpenPositions();
        }

      if(priceUp==0)
        {
         priceUp=m_symbol.Ask();
        }
      if(priceDown==0)
        {
         priceDown=m_symbol.Ask();
        }
     }
   else // есть позиция по текущему символу
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(OrderSal==true)
                    {
                     m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(m_symbol.Bid()-ExtStopLoss,Digits()),0.0);
                     OrderSal=false;
                    }
                  if(m_symbol.Bid()-m_position.PriceOpen()>ExtTrailingStop)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-2*ExtTrailingStop)
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-ExtTrailingStop,0.0);
                       }
                    }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(OrderSal==true)
                    {
                     m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(m_symbol.Ask()+ExtStopLoss,Digits()),0.0);
                     OrderSal=false;
                    }
                  if(m_position.PriceOpen()-m_symbol.Ask()>ExtTrailingStop)
                    {
                     if(m_position.StopLoss()>m_symbol.Ask()+2*ExtTrailingStop)
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+ExtTrailingStop,0.0);
                       }
                    }
                 }
              }
     }
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
