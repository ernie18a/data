//+------------------------------------------------------------------+
//|                              MA2CCI(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, George-on-Don"
#property link      "http://www.forex.aaanet.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedMargin m_money;
//--- input parameters
input int      ma_period_fast = 10;          // Fast MA Period
input int      ma_period_slow = 37;          // Slow MA Period
input int      ma_period_cci  = 39;          // CCI Period
input int      ma_period_atr  = 3;           // ATR Period (for S/L)
input bool     SndMail        = true;        // E-mail Sending Parameter
input double   PercentRisk    = 2;           // Percent margin PercentRisk
ushort         min_indent     = 15;          // minimum indent (for S/L)
//---
ulong          m_magic=20050610;             // magic number
ulong          m_slippage=30;                // slippage
int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
int            handle_iATR;                  // variable for storing the handle of the iATR indicator 
int            handle_iCCI;                  // variable for storing the handle of the iCCI indicator 

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(PercentRisk); // init risk
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),ma_period_fast,0,MODE_EMA,PRICE_CLOSE);
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
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),ma_period_slow,0,MODE_EMA,PRICE_CLOSE);
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
//--- create handle of the indicator iATR
   handle_iATR=iATR(m_symbol.Name(),Period(),ma_period_atr);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(m_symbol.Name(),Period(),ma_period_cci,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
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
   if(!IsTradeAllowed())
      return;
//--- calculate open positions by current symbol
   if(CalculatePositions()==0)
      CheckForOpen();
   else
      CheckForClose();
  }
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
//--- trading will be started with first tick of new bar only
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   string sHeaderLetter="";
   string sBodyLetter="";
//---- define Moving Average 
   double mas     = iMAGet(handle_iMA_slow,1);  // Slow MA shifted on 1 Period
   double maf     = iMAGet(handle_iMA_fast,1);  // Fast MA shifted on 1 Period
   double mas_p   = iMAGet(handle_iMA_slow,2);  // Slow MA shifted on 2 Period 
   double maf_p   = iMAGet(handle_iMA_fast,2);  // Fast MA shifted on 2 Period
   double Atr     = iATRGet(0);
   double icc     = iCCIGet(1);                 // CCI shifted on 1 Period
   double icc_p   = iCCIGet(2);                 // CCI shifted on 2 Period
//--- check for open buy order
   if((maf>mas && maf_p<=mas_p) && (icc>0 && icc_p<=0))
     {
      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }
      //--- getting lot size for open long position (CMoneyFixedMargin)
      double sl=0.0;
      if(Atr>min_indent*m_adjusted_point)
         sl=m_symbol.Ask()-Atr;
      else
         sl=m_symbol.Ask()-min_indent*m_adjusted_point;

      double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      if(check_open_long_lot==0.0)
         return;

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=check_open_long_lot)
           {
            if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),m_symbol.NormalizePrice(sl)))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  time_0=iTime(1);
                 }
               else
                 {
                  if(SndMail)
                    {
                     sHeaderLetter="Operation BUY at "+m_symbol.Name()+"";
                     sBodyLetter="Order Buy at "+m_symbol.Name()+
                                 " for "+DoubleToString(m_trade.ResultPrice(),m_symbol.Digits())+
                                 ", and set stoploss at "+DoubleToString(sl,m_symbol.Digits())+"";
                     sndMessage(sHeaderLetter,sBodyLetter);
                    }
                 }
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               time_0=iTime(1);
              }
           }
      return;
     }
//--- check for open sell order
   if((maf<mas && maf_p>=mas_p) && (icc<0 && icc_p>=0))
     {
      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }
      //--- getting lot size for open short position (CMoneyFixedMargin)
      double sl=0.0;
      if(Atr>min_indent*m_adjusted_point)
         sl=m_symbol.Bid()+Atr;
      else
         sl=m_symbol.Bid()+min_indent*m_adjusted_point;

      double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      if(check_open_short_lot==0.0)
         return;

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Ask(),ORDER_TYPE_SELL);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=check_open_short_lot)
           {
            if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),m_symbol.NormalizePrice(sl)))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  time_0=iTime(1);
                 }
               else
                 {
                  if(SndMail)
                    {
                     sHeaderLetter="Operation SELL at "+m_symbol.Name()+"";
                     sBodyLetter="Order Sell at "+m_symbol.Name()+
                                 " for "+DoubleToString(m_trade.ResultPrice(),m_symbol.Digits())+
                                 ", and set stoploss at "+DoubleToString(sl,m_symbol.Digits())+"";
                     sndMessage(sHeaderLetter,sBodyLetter);
                    }
                 }
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               time_0=iTime(1);
              }
           }
      return;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose()
  {
//--- trading will be started with first tick of new bar only
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   string sHeaderLetter="";
   string sBodyLetter="";
//---
   double mas=iMAGet(handle_iMA_slow,1);    // Slow MA shifted on 1 Period
   double maf=iMAGet(handle_iMA_fast,1);    // Fast MA shifted on 1 Period
   double mas_p=iMAGet(handle_iMA_slow,2);  // Slow MA shifted on 2 Period
   double maf_p=iMAGet(handle_iMA_fast,2);  // Fast MA shifted on 2 Period
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(maf<mas && maf_p>=mas_p)
                  if(m_trade.PositionClose(m_position.Ticket()))
                     if(SndMail)
                       {
                        sHeaderLetter="Operation CLOSE BUY at"+m_symbol.Name()+"";
                        sBodyLetter="Close order Buy at "+m_symbol.Name()+
                                    " for "+DoubleToString(m_trade.ResultPrice(),m_symbol.Digits())+
                                    ", and finish this Trade";
                        sndMessage(sHeaderLetter,sBodyLetter);
                       }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(maf>mas && maf_p<=mas_p)
                  if(m_trade.PositionClose(m_position.Ticket()))
                     if(SndMail)
                       {
                        sHeaderLetter="Operation CLOSE SELL at"+m_symbol.Name()+"";
                        sBodyLetter="Close order Sell at "+m_symbol.Name()+
                                    " for "+DoubleToString(m_trade.ResultPrice(),m_symbol.Digits())+
                                    ", and finish this Trade";
                        sndMessage(sHeaderLetter,sBodyLetter);
                       }
              }
           }
  }
//-------------------------------------------------------------------+
// Send e-mail message function                                      |
//-------------------------------------------------------------------+
void sndMessage(string HeaderLetter,string BodyLetter)
  {
   ResetLastError();
   if(!SendMail(HeaderLetter,BodyLetter))
      Print("Ошибка, сообщение не отправлено: ",GetLastError());
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
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,index,1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,index,1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[0]);
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
