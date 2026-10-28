//+------------------------------------------------------------------+
//|     RobotPowerM5_meta4V12 (RobotBB)(barabashkakvn's edition).mq5 |
//|                                        Copyright © 2005, Company |
//|                                             http://www.funds.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "http://www.funds.com"

#include <Trade\SymbolInfo.mqh> 
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
CSymbolInfo    m_symbol;                     // symbol info object
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
//--- A reliable expert,use it on 5 min charts(GBP is best) with
// 150/pips profit limit. 
// No worries, check the results. 
input int      BullBearPeriod =5;
input double   m_lots         = 0.01;
input ushort   m_trailingStep = 10;    // trail step. minimum 10
input ushort   m_takeProfit   = 150;   // take profit. recomended  no more than 150
input ushort   m_stopLoss     = 105;   // stop loss
ulong    m_slippage=30;
// EA identifier. Allows for several co-existing EA with different values.
input string nameEA="Soultrading";
//----
double bull,bear;
double realTP,realSL,b,s,m_sl,m_tp;
bool isBuying=false,isSelling=false,isClosing=false;
ulong          m_ticket;
//---
int    handle_iBullsPower;                      // variable for storing the handle of the iBullsPower indicator 
int    handle_iBearsPower;                      // variable for storing the handle of the iBearsPower indicator 
int    handle_iATR;                             // variable for storing the handle of the iATR indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_lots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(m_trailingStep<10.0)
     {
      Print("The \"trail step\" can't be smaller 10.0");
      return(INIT_PARAMETERS_INCORRECT);
     }
   m_symbol.Name(Symbol());                           // sets symbol name
   m_trade.SetDeviationInPoints(m_slippage);          // sets deviation
   RefreshRates();
//--- create handle of the indicator iBullsPower
   handle_iBullsPower=iBullsPower(Symbol(),Period(),BullBearPeriod);
//--- if the handle is not created 
   if(handle_iBullsPower==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBullsPower indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iBearsPower
   handle_iBearsPower=iBearsPower(Symbol(),Period(),BullBearPeriod);
//--- if the handle is not created 
   if(handle_iBearsPower==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBearsPower indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iATR
   handle_iATR=iATR(Symbol(),Period(),5);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
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
//--- check for invalid bars and takeprofit
   if(Bars(Symbol(),Period())<200)
     {
      Print("Not enough bars for this strategy - ",nameEA);
      return;
     }
//--- calculate indicators' value 
   calculateIndicators();
//--- control open trades
   int totalPositions=PositionsTotal();
   int numPos=0;
//--- scan all positions...
   for(int cnt=totalPositions-1; cnt>=0; cnt--)
     {
      //--- the next line will check for ONLY market trades, not entry orders
      if(!m_position.SelectByIndex(cnt))
         return;
      //--- only look for this symbol, and only orders from this EA      
      if(m_position.Symbol()==Symbol())
        {
         numPos++;
         //--- check for close signal for bought trade
         if(m_position.PositionType()==POSITION_TYPE_BUY)
           {
            //--- control trailing step
            if(!RefreshRates())
               return;
            if(m_symbol.Bid()-m_position.StopLoss()>(2*m_trailingStep*Point()))
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_symbol.Bid()-m_trailingStep*Point(),m_position.TakeProfit());
              }
           }
         else // check sold trade for close signal
           {
            //--- control trailing step
            if(!RefreshRates())
               return;
            if(m_position.StopLoss()-m_symbol.Ask()>(2*m_trailingStep*Point()))
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_symbol.Ask()+m_trailingStep*Point(),m_position.TakeProfit());
              }
           }
        }
     }
//--- if there is no open trade for this pair and this EA
   if(numPos<1)
     {
      if(m_account.FreeMargin()<1000*m_lots)
        {
         Print("Not enough money to trade ",m_lots," m_lots. Strategy:",nameEA);
         return;
        }
      //--- check for BUY entry signal
      if(isBuying && !isSelling && !isClosing)
        {
         if(!RefreshRates())
            return;
         m_sl = m_symbol.Ask() - m_stopLoss * Point();
         m_tp = m_symbol.Ask() + m_takeProfit * Point();
         if(m_trade.Buy(m_lots,Symbol(),m_symbol.Ask(),m_sl,m_tp,nameEA+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)))
           {
            m_ticket=m_trade.ResultDeal();
           }
         Comment(m_sl);
         if(m_ticket==0)
           {
            Print("Buy (",nameEA,") -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         prtAlert("Day Trading: Buying");
        }
      //--- check for SELL entry signal
      if(isSelling && !isBuying && !isClosing)
        {
         if(!RefreshRates())
            return;
         m_sl = m_symbol.Bid() + m_stopLoss * Point();
         m_tp = m_symbol.Bid() - m_takeProfit * Point();
         if(m_trade.Sell(m_lots,Symbol(),m_symbol.Bid(),m_sl,m_tp,nameEA+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)))
           {
            m_ticket=m_trade.ResultDeal();
           }
         if(m_ticket==0)
           {
            Print("Sell (",nameEA,") -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         prtAlert("Day Trading: Selling");
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|  Calculate indicators' value                                     |
//+------------------------------------------------------------------+
void calculateIndicators()
  {
   bull = iBullsPowerGet(1);
   bear = iBearsPowerGet(1);
   Comment("bull+bear= ",bull+bear);
//b = 1 * Point() + iATRGet(1)*1.5;
//s = 1 * Point() + iATRGet(1)*1.5;
   isBuying  = (bull+bear > 0);
   isSelling = (bull+bear < 0);
   isClosing = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prtAlert(string str="")
  {
   Print(str);
   Alert(str);
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
//| Get value of buffers for the iBullsPower                         |
//+------------------------------------------------------------------+
double iBullsPowerGet(const int index)
  {
   double BullsPower[];
   ArraySetAsSeries(BullsPower,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBullsPower array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBullsPower,0,0,index+1,BullsPower)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBullsPower indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(BullsPower[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iBearsPower                         |
//+------------------------------------------------------------------+
double iBearsPowerGet(const int index)
  {
   double BearsPower[];
   ArraySetAsSeries(BearsPower,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBearsPower array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBearsPower,0,0,index+1,BearsPower)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBearsPower indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(BearsPower[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[];
   ArraySetAsSeries(ATR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,0,index+1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[index]);
  }
//+------------------------------------------------------------------+
