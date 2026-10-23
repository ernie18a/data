//+------------------------------------------------------------------+
//|              Altarius RSI Stohastic(barabashkakvn's edition).mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
input double Lots               = 0.1;
input double MaximumRisk        = 0.1;
input double DecreaseFactor     = 3;
input double PeriodRSI          = 4;
double  st1,st2;
//---
ulong  m_magic                   = 282578160;   // magic number
int    handle_iStochastic_15_8_8;               // variable for storing the handle of the iStochastic indicator 
int    handle_iStochastic_10_3_3;               // variable for storing the handle of the iStochastic indicator 
int    handle_iRSI;                             // variable for storing the handle of the iRSI indicator
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double            m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   if(Bars(Symbol(),Period())<100)
     {
      Print("It is less bars, than 100");
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
//--- create handle of the indicator iStochastic
   handle_iStochastic_15_8_8=iStochastic(Symbol(),Period(),15,8,8,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic_15_8_8==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic_10_3_3=iStochastic(Symbol(),Period(),10,3,3,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic_10_3_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(Symbol(),Period(),3,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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
//--- check for history and trading
   if(!IsTradeAllowed())
      return;
//--- calculate open positions by current symbol
   if(CalculatePositions(m_symbol.Name())==0)
      CheckForOpen();
   else
      CheckForClose();
//---
  }
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculatePositions(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               buys++;
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               sells++;
              }
           }
//--- return positions volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
//| Расчет оптимальной величины лота                                 |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    losses=0;                  // number of losses deals without a break
//--- select lot size
   lot=NormalizeDouble(m_account.FreeMargin()*MaximumRisk/1000.0,2);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      //--- request trade history 
      HistorySelect(TimeCurrent()-86400,TimeCurrent()+86400);
      //--- 
      uint     total=HistoryDealsTotal();
      //--- for all deals 
      for(uint i=0;i<total;i++)
        {
         if(!m_deal.SelectByIndex(i))
           {
            Print("Error in history!");
            break;
           }
         if(m_deal.Symbol()!=Symbol() || m_deal.Entry()!=DEAL_ENTRY_OUT)
            continue;
         //---
         if(m_deal.Profit()>0)
            break;
         if(m_deal.Profit()<0)
            losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   if(lot<0.1)
      lot=0.1;
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   if(iTickVolume(0)>1)
      return;

   if(!RefreshRates())
      return;

//--- покупаем
   if(iStochasticGet(handle_iStochastic_15_8_8,MAIN_LINE,0)>
      iStochasticGet(handle_iStochastic_15_8_8,SIGNAL_LINE,0) && 
      iStochasticGet(handle_iStochastic_15_8_8,MAIN_LINE,0)<50)
      if(MathAbs(iStochasticGet(handle_iStochastic_10_3_3,MAIN_LINE,0)-
         iStochasticGet(handle_iStochastic_10_3_3,SIGNAL_LINE,0))>5)
        {
         if(m_trade.Buy(LotsOptimized(),NULL,m_symbol.Ask(),0.0,0.0))
           {
            Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         return;
        }
//--- продаем
   if(iStochasticGet(handle_iStochastic_15_8_8,MAIN_LINE,0)
      <iStochasticGet(handle_iStochastic_15_8_8,SIGNAL_LINE,0) && 
      iStochasticGet(handle_iStochastic_15_8_8,MAIN_LINE,0)>55)
      if(MathAbs(iStochasticGet(handle_iStochastic_10_3_3,MAIN_LINE,0)-
         iStochasticGet(handle_iStochastic_10_3_3,SIGNAL_LINE,0))>5)
        {
         if(m_trade.Sell(LotsOptimized(),NULL,m_symbol.Bid(),0.0,0.0))
           {
            Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         return;
        }

  }
//+------------------------------------------------------------------+
//| Закрытие всех позиций                                            |
//+------------------------------------------------------------------+
void ClosAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
  }
//
//+------------------------------------------------------------------+
//| Check for close positions                                        |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   if(iTickVolume(0)>1)
      return;
//--- проверка на проигрыш   
   if(m_account.Profit()<0 && MathAbs(m_account.Profit())>=m_account.Margin()*MaximumRisk)
     {
      Print("Убыток ",m_account.Profit()," - закрываем всё");
      ClosAllPositions();
      return;
     }
//---- если есть положительная прибыль
   double rsi_0=iRSIGet(0);
   double sto_15_8_8_signal_0=iStochasticGet(handle_iStochastic_15_8_8,SIGNAL_LINE,0);
   double sto_15_8_8_signal_1=iStochasticGet(handle_iStochastic_15_8_8,SIGNAL_LINE,1);
   double rsi=iRSIGet(0);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(rsi_0>60 && sto_15_8_8_signal_0<sto_15_8_8_signal_1)
                  if(sto_15_8_8_signal_0>70)
                     m_trade.PositionClose(m_position.Ticket());
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(rsi_0<40 && sto_15_8_8_signal_0>sto_15_8_8_signal_1)
                  if(sto_15_8_8_signal_0<30)
                     m_trade.PositionClose(m_position.Ticket());
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
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(int handle,const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
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
//| Get TickVolume for specified bar index                           | 
//+------------------------------------------------------------------+ 
long iTickVolume(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   long TickVolume[1];
   long tickvolume=0;
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
  }
//+------------------------------------------------------------------+
