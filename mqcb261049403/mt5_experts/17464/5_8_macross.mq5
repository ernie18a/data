//+------------------------------------------------------------------+
//|                         5_8 MACross(barabashkakvn's edition).mq5 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input double   Lots=0.1;
input ushort   StopLoss=0;
input int      TrailingStop=0;
input ushort   TakeProfit=40;
input int      mafastperiod=5;
input int      mafastshift=-1;
input ENUM_MA_METHOD    mafastmethod=MODE_EMA;
input ENUM_APPLIED_PRICE mafastprice=PRICE_CLOSE;
input int      maslowperiod=8;
input int      maslowshift=0;
input ENUM_MA_METHOD maslowmethod=MODE_EMA;
input ENUM_APPLIED_PRICE maslowprice=PRICE_OPEN;
//---
datetime TimePrev=0;
ulong    m_magic=192015752;                  // magic number
int      handle_iMA_fast;                    // variable for storing the handle of the iMA indicator 
int      handle_iMA_slow;                    // variable for storing the handle of the iMA indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double   m_adjusted_point;                   // point value adjusted for 3 or 5 points
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
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),mafastperiod,mafastshift,mafastmethod,mafastprice);
//--- if the handle is not created 
   if(handle_iMA_fast==INVALID_HANDLE)
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
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),maslowperiod,maslowshift,maslowmethod,maslowprice);
//--- if the handle is not created 
   if(handle_iMA_slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
//--- Trailing Stop
   TrailingAlls(TrailingStop);

   if(TimePrev==iTime(0))
      return;
   TimePrev=iTime(0);
//--- Caculate indicators
   double fast1=iMAGet(handle_iMA_fast,1);
   double fast2=iMAGet(handle_iMA_fast,2);
   double slow1=iMAGet(handle_iMA_slow,1);
   double slow2=iMAGet(handle_iMA_slow,2);

   if(fast1>slow1 && fast2<slow2)
     {
      ClosePositions(POSITION_TYPE_SELL);
      if(!RefreshRates())
        {
         TimePrev=iTime(1);
         return;
        }
      double sl=0.0;
      double tp=0.0;
      if(StopLoss>0)
         sl=m_symbol.Ask()-StopLoss*m_adjusted_point;
      if(TakeProfit>0)
         tp=m_symbol.Ask()+TakeProfit*m_adjusted_point;
      m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp);
     }

   if(fast1<slow1 && fast2>slow2)
     {
      ClosePositions(POSITION_TYPE_BUY);
      if(!RefreshRates())
        {
         TimePrev=iTime(1);
         return;
        }
      double sl=0.0;
      double tp=0.0;
      if(StopLoss>0)
         sl=m_symbol.Bid()+StopLoss*m_adjusted_point;
      if(TakeProfit>0)
         tp=m_symbol.Bid()-TakeProfit*m_adjusted_point;
      m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp);
     }
   return;
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(int trail)
  {
   if(trail==0)
      return;
//---
   double stopcrnt;
   double stopcal;

   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               stopcrnt=m_position.StopLoss();
               stopcal=m_symbol.Bid()-trail*m_adjusted_point;
               if(stopcrnt==0)
                 {
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
                 }
               else
               if(stopcal>stopcrnt)
                 {
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               stopcrnt=m_position.StopLoss();
               stopcal=m_symbol.Ask()+trail*m_adjusted_point;
               if(stopcrnt==0)
                 {
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
                 }
               else
               if(stopcal<stopcrnt)
                 {
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
