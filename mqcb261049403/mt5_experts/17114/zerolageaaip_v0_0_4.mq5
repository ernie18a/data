//+------------------------------------------------------------------+
//|                ZeroLagEA-AIP v0.0.4(barabashkakvn's edition).mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input int      FastEMA = 2;
input int      SlowEMA = 34;
input int      UseFreshMACDSig=1;
input double   InpLots=2;
input ulong    InpSlippage=5;     // Slippage
input int      StartHour=9;
input int      EndHour=15;
input int      KillDay=5;
input int      KillHour=21;
//---
double TradesThisSymbol=0;
datetime newbar=0;
int SaR=0,BuySig=0,SellSig=0;
//---
ulong          m_magic=666523386;   // magic number
ulong          m_slippage=0;
int            handle_iCistom;                          // variable for storing the handle of the iCustom indicator 
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
   m_slippage=InpSlippage*digits_adjust;
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- create handle of the indicator iCustom
   handle_iCistom=iCustom(m_symbol.Name(),Period(),"zerolag_macd",FastEMA,SlowEMA);
//--- if the handle is not created 
   if(handle_iCistom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCistom indicator for the symbol %s/%s, error code %d",
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
   double MACD_Signal=0.0;
   double MACD_Main=0.0;
   double FreshMACDSig=0.0;
   double MACD_MainPrev=0.0;
   double MACD_SignalPrev=0.0;
//---
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
//---

   if(str1.hour<StartHour || str1.hour>=EndHour || (str1.day_of_week==KillDay && str1.hour==KillHour))
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               m_trade.PositionClose(m_position.Ticket());
      return;
     }
   if(newbar!=iTime(m_symbol.Name(),Period(),0) || SaR==1)
     {
      newbar=iTime(m_symbol.Name(),Period(),0);
      SaR=0;

      TradesThisSymbol=0;
      //---
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               TradesThisSymbol++;

      MACD_Main=iCustomGet(0,1);
      MACD_Signal=iCustomGet(1,1);
      MACD_MainPrev=iCustomGet(0,2);
      MACD_SignalPrev=iCustomGet(1,2);
      FreshMACDSig=0;
      //---
      if(UseFreshMACDSig==1)
        {
         if(((MACD_SignalPrev>MACD_MainPrev) && (MACD_Signal<MACD_Main)) || 
            ((MACD_SignalPrev<MACD_MainPrev) && (MACD_Signal>MACD_Main)))
            FreshMACDSig=1;
         //---
         if(FreshMACDSig!=1)
            return;
        }
      //---
      if(MACD_Signal>MACD_Main)
        {
         SellSig= 1;
         BuySig = 0;
        }
      //---
      if(MACD_Signal<MACD_Main)
        {
         SellSig= 0;
         BuySig = 1;
        }

      TradesThisSymbol=0;
      //---
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               TradesThisSymbol++;
      //---
      if(TradesThisSymbol!=0)
        {
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
            if(m_position.SelectByIndex(i))
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     if(BuySig==0 && SellSig==1)
                       {
                        SaR=1;
                        m_trade.PositionClose(m_position.Ticket());
                        return;
                       }
                    }

                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     if(SellSig==0 && BuySig==1)
                       {
                        SaR=1;
                        m_trade.PositionClose(m_position.Ticket());
                        return;
                       }
                    }
                 }
        }
      TradesThisSymbol=0;
      //---
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               TradesThisSymbol++;
      //---
      if(TradesThisSymbol==0)
        {
         if(!RefreshRates())
            return;

         if(BuySig==1 && SellSig==0)
           {
            BuySig=0;
            if(!m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"Buy Order placed at "+TimeToString(TimeCurrent())))
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
            return;
           }
         //---
         if(BuySig==0 && SellSig==1)
           {
            SellSig=0;
            if(!m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"Sell Order placed at "+TimeToString(TimeCurrent())))
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
            return;
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
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCistom,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
