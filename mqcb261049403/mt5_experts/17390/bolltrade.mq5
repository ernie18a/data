//+------------------------------------------------------------------+
//|                           BollTrade(barabashkakvn's edition).mq5 |
//|                 Copyright © 2000-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- user input
input ushort   TakeProfit        = 3;        // TakeProfit
input ushort   StopLoss          = 20;       // StopLoss
input double   BDistance         = 3;        // plus how much
input int      BPeriod           = 4;        // Bollinger period
input double   Deviation         = 2;        // Bollinger deviation
input double   Lots              = 1.0;      // how many lots to trade at a time 
input bool     LotIncrease       = true;     // grow lots based on balance = true
//--- non-external flag settings
ulong          m_slippage= 10;               // how many pips of slippage can you tolorate
bool           OnePositionOnly= true;        // one position at a time or not
//--- naming and numbering
ulong          m_magic=200607121116;         // allows multiple experts to trade on same account
string         TradeComment="BollTrade";     // comment so multiple EAs can be seen in Account History
double         StartingBalance=0;            // lot size control if LotIncrease == true
//--- Bar handling
datetime       bartime=0;                    // used to determine when a bar has moved
int            bartick=0;                    // number of times bars have moved
//--- Trade control
bool           TradeAllowed=true;            // used to manage trades
//--- Min/Max tracking and tick logging
int            maxPositions;                 // statistic for maximum numbers or positions open at one time
double         maxEquity;                    // statistic for maximum equity level
double         minEquity;                    // statistic for minimum equity level
double         maxOEquity;                   // statistic for maximum equity level per order
double         minOEquity;                   // statistic for minimum equity level per order 
double         EquityPos=0;                  // statistic for number of ticks order was positive
double         EquityNeg=0;                  // statistic for number of ticks order was negative
double         EquityZer=0;                  // statistic for number of ticks order was zero
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iBands;                // variable for storing the handle of the iBands indicator 
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
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iBands
   handle_iBands=iBands(m_symbol.Name(),Period(),BPeriod,0,Deviation,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iBands==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   if(LotIncrease)
      StartingBalance=m_account.Balance()/Lots;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- so you can see stats in journal
   Print("MAX number of positions "+IntegerToString(maxPositions));
   Print("MAX equity              "+DoubleToString(maxEquity,2));
   Print("MIN equity              "+DoubleToString(minEquity));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int      PositionsPerSymbol=0;
   int      PositionsBUY=0;
   int      PositionsSELL=0;
//--- stoploss and takeprofit and close control
   double SL=0.0;
   double TP=0.0;
   double CurrentProfit=0.0;
   double CurrentBasket=0.0;
//--- direction control
   bool BUYme=false;
   bool SELLme=false;
//--- bar counting
   if(bartime!=iTime(0))
     {
      bartime=iTime(0);
      bartick++;
      TradeAllowed=true;
     }
// Lot increasement based on AccountBalance when expert is started
// this will trade 1.0, then 1.1, then 1.2 etc as account balance grows
// or 0.9 then 0.8 then 0.7 as account balance shrinks 
   double ExtLots=Lots;
   if(LotIncrease)
     {
      ExtLots=NormalizeDouble(m_account.Balance()/StartingBalance,1);
      if(ExtLots>500.0)
         ExtLots=500.0;
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               PositionsBUY++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               PositionsSELL++;
           }

   PositionsPerSymbol=PositionsBUY+PositionsSELL;
//--- keep some statistics
   if(PositionsPerSymbol>maxPositions)
      maxPositions=PositionsPerSymbol;

   double bup=iBandsGet(UPPER_BAND,0);
   double bdn=iBandsGet(LOWER_BAND,0);

   if(iClose(0)>bup+(BDistance*m_adjusted_point))
      SELLme=true;
   if(iClose(0)<bdn-(BDistance*m_adjusted_point))
      BUYme=true;

//--- ENTRY LONG
   if((OnePositionOnly && PositionsPerSymbol==0 && BUYme) || (!OnePositionOnly && TradeAllowed && BUYme))
     {
      if(!RefreshRates())
         return;

      if(StopLoss==0)
         SL=0.0;
      else
         SL=m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss*m_adjusted_point);
      if(TakeProfit==0)
         TP=0.0;
      else
         TP=m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit*m_adjusted_point);

      if(m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),SL,TP,TradeComment))
         if(m_trade.ResultDeal()>0)
           {
            maxOEquity=0;
            minOEquity=0;
            EquityPos=0;
            EquityNeg=0;
            EquityZer=0;
            TradeAllowed=false;
           }
     }
//--- ENTRY SHORT
   if((OnePositionOnly && PositionsPerSymbol==0 && SELLme) || (!OnePositionOnly && TradeAllowed && SELLme))
     {
      if(!RefreshRates())
         return;

      if(StopLoss==0)
         SL=0;
      else
         SL=m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss*m_adjusted_point);
      if(TakeProfit==0)
         TP=0;
      else
         TP=m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit*m_adjusted_point);

      if(m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),SL,TP,TradeComment))
         if(m_trade.ResultDeal()>0)
           {
            maxOEquity=0;
            minOEquity=0;
            EquityPos=0;
            EquityNeg=0;
            EquityZer=0;
            TradeAllowed=false;
           }
     }
//--- accumulate statistics
   CurrentBasket=m_account.Equity()-m_account.Balance();
   if(CurrentBasket>maxEquity)
     {
      maxEquity=CurrentBasket;
      maxOEquity=CurrentBasket;
     }
   if(CurrentBasket<minEquity)
     {
      minEquity=CurrentBasket;
      minOEquity=CurrentBasket;
     }
   if(CurrentBasket>0)
      EquityPos++;
   if(CurrentBasket<0)
      EquityNeg++;
   if(CurrentBasket==0)
      EquityZer++;

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
//| Get value of buffers for the iBands                              |
//|  the buffer numbers are the following:                           |
//|   0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND                  |
//+------------------------------------------------------------------+
double iBandsGet(const int buffer,const int index)
  {
   double Bands[1];
//ArraySetAsSeries(Bands,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBands,buffer,index,1,Bands)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Bands[0]);
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
