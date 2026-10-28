//+------------------------------------------------------------------+
//|            True Scalper Profit Lock(barabashkakvn's edition).mq5 |
//|         Copyright © 2005, International Federation of Red Cross. |
//|                                             http://www.ifrc.org/ |
//|                                         Please donate some pips  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  Modifications                                                   |
//|  -------------                                                   |
//|  1)  Jacob Yego and Ron Thompson: Original version               |
//|                                                                  |
//|  2)  Reworked by Roger.                                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, International Federation of Red Cross."
#property link      "http://www.ifrc.org/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- generic user input
input double Lots=1.0;
input int    TakeProfit=44;
input int    StopLoss=90;
input bool   RSIMethodA=false;
input bool   RSIMethodB=true;
input int    RSIValue=50;
input bool   AbandonMethodA=true;
input bool   AbandonMethodB=false;
input int    Abandon=101;
input bool   MoneyManagement=true;
input int    Risk=2;
input int    Slippage=3;
input bool   UseProfitLock=true;
input int    BreakEvenTrigger=25;
input int    BreakEven=3;
input bool   LiveTrading=false;
input bool   AccountIsMini=false;
input int    maxTradesPerPair=1;
input ulong  m_magic=5432;
//----
double lotMM;
bool BuySignal=false;
bool SetBuy=false;
bool SellSignal=false;
bool SetSell=false;
// Bar handling
datetime bartime=0;
int      bartick=0;
int      TradeBars=0;
//---
int    handle_iMA_3;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_7;                         // variable for storing the handle of the iMA indicator 
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

//--- create handle of the indicator iMA
   handle_iMA_3=iMA(m_symbol.Name(),Period(),3,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_7=iMA(m_symbol.Name(),Period(),7,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_7==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),2,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
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
   if(UseProfitLock) ProfitLockStop();
   if(AbandonMethodA || AbandonMethodB)
     {
      RunAbandonCheck();
      RunAbandonMethods();
     }
   if(!SetLotsMM())
      return;
   RunOrderTriggerCalculations();
   RunNewOrderManagement();
//---
   return;
  }
//  SetLotsMM - By Robert Cochran http://autoforex.biz
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetLotsMM()
  {
   double MarginCutoff=0.0;
//----
   if(!AccountIsMini)
      MarginCutoff=1000;
   if(AccountIsMini)
      MarginCutoff=100;
   if(m_account.FreeMargin() < MarginCutoff) return(false);
   if(MoneyManagement)
     {
      lotMM=MathCeil(m_account.Balance()*Risk/10000)/10;
      //----
      if(lotMM < 0.1) lotMM=Lots;
      if(lotMM > 1.0) lotMM=MathCeil(lotMM);
      // Enforce lot size boundaries
      if(LiveTrading)
        {
         if(AccountIsMini) lotMM=lotMM*10;
         if(!AccountIsMini && lotMM<1.0) lotMM=1.0;
        }
      if(lotMM>100) lotMM=100;
     }
   else
     {
      lotMM=Lots; // Change MoneyManagement to 0 if you want the Lots parameter to be in effect
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|  RunOrderTriggerCalculations                                     |
//+------------------------------------------------------------------+
bool RunOrderTriggerCalculations()
  {
   bool    RSIPOS=false;
   bool    RSINEG=false;
// 3-period moving average on Bar[1]
   double bullMA3=iMAGet(handle_iMA_3,1);
// 7-period moving average on Bar[1]
   double bearMA7=iMAGet(handle_iMA_7,1);
// 2-period moving average on Bar[2]
   double RSI=iRSIGet(2);
   double RSI2=iRSIGet(1);
// Determine what polarity RSI is in
   if(RSIMethodA)
     {
      if(RSI>RSIValue && RSI2<RSIValue)
        {
         RSIPOS=true;
         RSINEG=false;
        }
      else RSIPOS=false;
      if(RSI<RSIValue && RSI2>RSIValue)
        {
         RSIPOS=false;
         RSINEG=true;
        }
      else RSINEG=false;
     }
   if(RSIMethodB)
     {
      if(RSI>RSIValue)
        {
         RSIPOS=true;
         RSINEG=false;
        }
      if(RSI<RSIValue)
        {
         RSIPOS=false;
         RSINEG=true;
        }
     }
   if((bullMA3>(bearMA7+m_symbol.Point())) && RSINEG)
     {
      BuySignal=true;
     }
   else BuySignal=false;
   if((bullMA3<(bearMA7-m_symbol.Point())) && RSIPOS)
     {
      SellSignal=true;
     }
   else SellSignal=false;
   return(true);
  }
// OpenOrdersBySymbolAndComment
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculatePositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
   return(total);
  }
// PROFIT LOCK - By Robert Cochran - http://autoforex.biz
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProfitLockStop()
  {
   if(CalculatePositions()>0)
     {
      if(!RefreshRates())
         return;

      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_symbol.Bid()>=m_position.PriceOpen()+BreakEvenTrigger*m_symbol.Point() && 
                     m_position.PriceOpen()>m_position.StopLoss())
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_position.PriceOpen()+BreakEven*m_symbol.Point(),
                                            m_position.TakeProfit());
                    }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_symbol.Ask()<=m_position.PriceOpen()-BreakEvenTrigger*m_symbol.Point() && 
                     m_position.PriceOpen()<m_position.StopLoss())
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_position.PriceOpen()-BreakEven*m_symbol.Point(),
                                            m_position.TakeProfit());
                    }
                 }
              }
     }
  }
// ABANDON CHECK
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunAbandonCheck()
  {
   if(CalculatePositions()>0)
     {
      if(TradeBars==0 && bartick==0)
        {
         for(int i=PositionsTotal()-1;i>=0;i--)
            if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  TradeBars=(int)MathFloor(TimeCurrent()-m_position.Time())/60/PeriodSeconds();
                  bartime=iTime(m_symbol.Name(),Period(),0);
                  bartick=TradeBars;
                 }

        }
      if(bartime!=iTime(m_symbol.Name(),Period(),0))
        {
         bartime=iTime(m_symbol.Name(),Period(),0);
         bartick++;
        }
     }
   return(true);
  }
// RunAbandonMethods
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunAbandonMethods()
  {
   if(CalculatePositions()>0)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(AbandonMethodA && bartick==Abandon) // force "HEDGE" after abandon
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     SetSell=true;
                     continue;
                    }
                  else if(AbandonMethodB && bartick==Abandon) // indicators decide direction after abandon
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(AbandonMethodA && bartick==Abandon) // force "HEDGE" after abandon
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     SetBuy=true;
                     continue;
                    }
                  else if(AbandonMethodB && bartick==Abandon) // indicators decide direction after abandon
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }
              }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RunNewOrderManagement()
  {
   double  TP,SL;
//---
   if(CalculatePositions()<maxTradesPerPair)
     {
      if(!RefreshRates())
         return;

      //--- ENTRY Ask(buy, long) 
      if(BuySignal || SetBuy)
        {
         SL=m_symbol.Ask() - StopLoss*m_symbol.Point();
         TP=m_symbol.Ask() + TakeProfit*m_symbol.Point();

         m_trade.Buy(lotMM,NULL,m_symbol.Ask(),SL,TP,"TS-ProfitLock - Long");

         bartick=0;
         if(SetBuy)
            SetBuy=false;

         return;
        }

      //--- ENTRY m_symbol.Bid() (sell, short)
      if(SellSignal || SetSell)
        {
         SL=m_symbol.Bid() + StopLoss*m_symbol.Point();
         TP=m_symbol.Bid() - TakeProfit*m_symbol.Point();

         m_trade.Sell(lotMM,NULL,m_symbol.Bid(),SL,TP,"TS-ProfitLock - Short");

         bartick=0;
         if(SetSell)
            SetSell=false;

         return;
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+
