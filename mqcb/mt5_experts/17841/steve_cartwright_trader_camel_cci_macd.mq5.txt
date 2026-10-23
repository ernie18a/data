//+--------------------------------------------------------------------+
//|Steve Cartwright Trader Camel CCI MACD(barabashkakvn's edition).mq5 |
//|                                Copyright © 2017, Vladimir Karputov |
//|                                             http://wmua.ru/slesar/ |
//+--------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
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
//---
input int    ma_period_MA_HIGH   = 40;
input int    ma_period_MA_LOW    = 5;
input int    ma_period_CCI       = 30;
input ushort TakeProfit          = 40;
input double Lots                = 1;
//---
datetime       m_last_close_time=0;
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
//---
int MinDist;
int SigPos;
double MACDSP1,MACDSP2;
double MACDHP1,MACDHP2;
double CCIP1;
double CAMELHIGHP1,CAMELHIGHP2,CAMELLOWP1,CAMELLOWP2;
//---
int    handle_iMA_PRICE_HIGH;                // variable for storing the handle of the iMA indicator 
int    handle_iMA_PRICE_LOW;                 // variable for storing the handle of the iMA indicator 
int    handle_iMACD;                         // variable for storing the handle of the iMACD indicator 
int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA_PRICE_HIGH=iMA(m_symbol.Name(),Period(),ma_period_MA_HIGH,0,MODE_EMA,PRICE_HIGH);
//--- if the handle is not created 
   if(handle_iMA_PRICE_HIGH==INVALID_HANDLE)
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
   handle_iMA_PRICE_LOW=iMA(m_symbol.Name(),Period(),ma_period_MA_LOW,0,MODE_EMA,PRICE_LOW);
//--- if the handle is not created 
   if(handle_iMA_PRICE_LOW==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),12,26,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(m_symbol.Name(),Period(),ma_period_CCI,PRICE_CLOSE);
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
//--- Indicator Setup 
   CAMELHIGHP1=iMAGet(handle_iMA_PRICE_HIGH,1);
   CAMELLOWP1=iMAGet(handle_iMA_PRICE_LOW,1);
//
   MACDSP1=iMACDGet(SIGNAL_LINE,1);
   MACDSP2=iMACDGet(SIGNAL_LINE,2);
//
   MACDHP1=iMACDGet(MAIN_LINE,1);
   MACDHP2=iMACDGet(MAIN_LINE,2);
//
   CCIP1=iCCIGet(1);
//--- POSITIONS CLOSURE   
// If Positions are in force then check for closure against Technicals LONG & SHORT
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(MACDHP1<MACDSP1 || CCIP1<100) //--- LONG Closure Rules
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close LONG position
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(MACDHP1>MACDSP1)//--- SHORT Closure Rules 
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close SHORT position
                 }
              }
           }
//---  NEW POSITIONS ?   
//Possibly add in timer to stop multiple entries within Period
// Check Margin available
// ONLY ONE POSITION per SYMBOL
// Check for elapsed time from last entry to stop multiple entries on same bar
//--- switch to turn ON/OFF history check
   if(m_last_close_time!=0 && TimeCurrent()-m_last_close_time<PeriodSeconds())
      return;
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return;
//---
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",m_account.FreeMargin());
      return;
     }
//--- ENTRY RULES: LONG 
   if(CCIP1>100 && MACDHP1>0 && MACDHP1>MACDSP1 && iClose(1)>CAMELHIGHP1)
     {
      if(!RefreshRates())
         return;
      OpenBuy(0.0,m_symbol.Ask()+TakeProfit*m_adjusted_point);
      return;
     }
//--- ENTRY RULES: SHORT                                    
   if(CCIP1<-100 && MACDHP1<0 && MACDHP1<MACDSP1 && iClose(1)<CAMELLOWP1)
     {
      if(!RefreshRates())
         return;
      OpenSell(0.0,m_symbol.Bid()-TakeProfit*m_adjusted_point);
     }
//--- End of PROGRAM     
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
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      long     deal_time         =0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
        {
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            m_last_close_time=(datetime)deal_time;
           }
         else if(deal_entry!=DEAL_ENTRY_OUT)
           {
            m_last_close_time=0;
           }
        }
     }
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
