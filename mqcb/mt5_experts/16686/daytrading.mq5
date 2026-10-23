//+------------------------------------------------------------------+
//|                          DayTrading(barabashkakvn's edition).mq5 |
//|                               Copyright © 2005, NazFunds Company |
//|                                          http://www.nazfunds.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, NazFunds Company"
#property link      "http://www.nazfunds.com"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- A reliable expert, use it on 5 min charts with 20/pips profit limit. 
// Do not place any stop loss. No worries, check the results 
input double m_lots       = 0.1;             // volume trading
input double trailingStop = 25;              // trail stop in points
input double takeProfit   = 50;             // Take Profit
input double stopLoss     = 0;               // do not use s/l
input ulong  slippage     = 3;
// EA identifier. Allows for several co-existing EA with different values
input string nameEA="DayTrading";
//----
double   macdHistCurrent,macdHistPrevious,macdSignalCurrent,macdSignalPrevious;
double   stochHistCurrent,stochHistPrevious,stochSignalCurrent,stochSignalPrevious;
double   sarCurrent,sarPrevious,momCurrent,momPrevious;
double   realTP,realSL;
bool     isBuying=false,isSelling=false,isClosing=false;
int      cnt;
ulong    m_ticket=0;
ulong    m_magic=16384;
//---
int    handle_iMACD;                         // variable for storing the handle of the iMACD indicator 
int    handle_iStochastic;                   // variable for storing the handle of the iStochastic indicator 
int    handle_iSAR;                          // variable for storing the handle of the iSAR indicator 
int    handle_iMomentum;                     // variable for storing the handle of the iMomentum indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
   m_trade.SetDeviationInPoints(slippage);   // set deviation in points
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(Symbol(),PERIOD_CURRENT,5,3,3,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),Period(),0.02,0.2);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMomentum
   handle_iMomentum=iMomentum(Symbol(),Period(),14,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMomentum==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMomentum indicator for the symbol %s/%s, error code %d",
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
//--- destroy timer

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check for invalid bars and takeprofit
   if(Bars(Symbol(),Period())<200)
     {
      Print("Not enough bars for this strategy - ",nameEA);
      return;
     }

// Calculate indicators' value  
   calculateIndicators();
// Control open trades
   int totalPositions=PositionsTotal();
   int numPos=0;
// scan all orders and positions...
   for(cnt=0; cnt<totalPositions; cnt++)
     {
      //--- refresh rates
      if(!m_symbol.RefreshRates())
         return;
      //--- protection against the return value of "zero"
      if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
         return;
      // the next line will check for ONLY market trades, not entry orders
      m_position.SelectByIndex(cnt);
      // only look for this symbol, and only orders from this EA        
      if(m_position.Symbol()==Symbol() && m_position.Comment()==nameEA)
        {
         numPos++;
         // Check for close signal for bought trade
         if(m_position.PositionType()==POSITION_TYPE_BUY)
           {
            if(isSelling || isClosing)
              {
               // Close bought trade
               m_trade.PositionClose(m_position.Ticket(),slippage);
               prtAlert("Day Trading: Closing BUY position");
              }
            // Check trailing stop
            if(trailingStop>0)
              {
               if(m_symbol.Bid()-m_position.PriceOpen()>trailingStop*Point())
                 {
                  if(m_position.StopLoss()<(m_symbol.Bid()-trailingStop*Point()))
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Bid()-trailingStop*Point(),m_position.TakeProfit());
                 }
              }
           }
         else
         // Check sold trade for close signal
           {
            if(isBuying || isClosing)
              {
               m_trade.PositionClose(m_position.Ticket(),slippage);
               prtAlert("Day Trading: Closing SELL position");
              }
            if(trailingStop>0)
               // Control trailing stop
              {
               if(m_position.PriceOpen()-m_symbol.Ask()>trailingStop*Point())
                 {
                  if(m_position.StopLoss()==0 || m_position.StopLoss()>m_symbol.Ask()+trailingStop*Point())
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Ask()+trailingStop*Point(),m_position.TakeProfit());
                 }
              }
           }
        }
     }
// If there is no open trade for this pair and this EA
   if(numPos<1)
     {
      if(m_account.FreeMargin()<1000*m_lots)
        {
         Print("Not enough money to trade ",m_lots," lots. Strategy:",nameEA);
         return;
        }
      // Check for BUY entry signal
      if(isBuying && !isSelling && !isClosing)
        {
         if(stopLoss>0)
            realSL=m_symbol.Ask()-stopLoss*Point();
         if(takeProfit>0)
            realTP=m_symbol.Ask()+takeProfit*Point();
         // Buy
         if(m_trade.Buy(m_lots,Symbol(),m_symbol.Ask(),realSL,realTP,nameEA))
           {
            m_ticket=m_trade.ResultDeal();
            prtAlert("Day Trading: Buying");
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
        }
      // Check for SELL entry signal
      if(isSelling && !isBuying && !isClosing)
        {
         if(stopLoss>0)
            realSL=m_symbol.Bid()+stopLoss*Point();
         if(takeProfit>0)
            realTP=m_symbol.Bid()-takeProfit*Point();
         // Sell
         if(m_trade.Sell(m_lots,Symbol(),m_symbol.Bid(),realSL,realTP,nameEA))
           {
            m_ticket=m_trade.ResultDeal();
            prtAlert("Day Trading: Selling");
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|  Calculate indicators' value                                     |
//+------------------------------------------------------------------+
void calculateIndicators()
  {
   macdHistCurrent     = iMACDGet(MAIN_LINE,0);
   macdHistPrevious    = iMACDGet(MAIN_LINE,1);
   macdSignalCurrent   = iMACDGet(SIGNAL_LINE,0);
   macdSignalPrevious  = iMACDGet(SIGNAL_LINE,1);
   stochHistCurrent    = iStochasticGet(MAIN_LINE,0);
   stochHistPrevious   = iStochasticGet(MAIN_LINE,1);
   stochSignalCurrent  = iStochasticGet(SIGNAL_LINE,0);
   stochSignalPrevious = iStochasticGet(SIGNAL_LINE,1);
// Parabolic Sar Current
   sarCurrent=iSARGet(0);
// Parabolic Sar Previuos           
   sarPrevious=iSARGet(1);
// Momentum Current           
   momCurrent=iMomentumGet(0);
// Momentum Previous 
   momPrevious=iMomentumGet(1);
// Check for BUY, SELL, and CLOSE signal
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return;
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return;
   isBuying=(sarCurrent<=m_symbol.Ask() && sarPrevious>sarCurrent && momCurrent<100 && 
             macdHistCurrent<macdSignalCurrent && stochHistCurrent<35);
   isSelling=(sarCurrent>=m_symbol.Bid() && sarPrevious<sarCurrent && momCurrent>100 && 
              macdHistCurrent>macdSignalCurrent && stochHistCurrent>60);
   isClosing=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prtAlert(string str="")
  {
   Print(str);
   Alert(str);
//   SpeechText(str,SPEECH_ENGLISH);
//   SendMail("Subject EA",str);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[];
   ArraySetAsSeries(MACD,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,0,index+1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[];
   ArraySetAsSeries(Stochastic,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,0,index+1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int index)
  {
   double SAR[];
   ArraySetAsSeries(SAR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iSAR,0,0,index+1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMomentum                           |
//+------------------------------------------------------------------+
double iMomentumGet(const int index)
  {
   double Momentum[];
   ArraySetAsSeries(Momentum,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMomentumBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMomentum,0,0,index+1,Momentum)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMomentum indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Momentum[index]);
  }
//+------------------------------------------------------------------+
