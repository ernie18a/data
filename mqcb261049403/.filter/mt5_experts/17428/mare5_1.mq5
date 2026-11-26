//+------------------------------------------------------------------+
//|                             MARE5.1(barabashkakvn's edition).mq5 |
//|                                        Author: Kvant & Reshetov  |
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#property version "1.002"
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   Lots              = 0.01;
input double   TakeProfit        = 35;
input double   StopLoss          = 55;
input int      MAFastPeriod      = 14;
input int      MASlowPeriod      = 79;
input int      MovingShift       = 4;
input int      HourTimeOpen      = 2;
input int      HourTimeClose     = 3;
//---
ulong          m_magic=15489;                // magic number
int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if((HourTimeOpen<0 || HourTimeClose<0) || (HourTimeOpen>23 || HourTimeClose>23))
     {
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(HourTimeOpen==HourTimeClose)
     {
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(HourTimeOpen>HourTimeClose)
     {
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),PERIOD_M1,MAFastPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(PERIOD_M1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_slow=iMA(m_symbol.Name(),PERIOD_M1,MASlowPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(PERIOD_M1),
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
   double FastMa=iMAGet(handle_iMA_fast,0);
   double FastMa2 = iMAGet(handle_iMA_fast, 2);
   double FastMa5 = iMAGet(handle_iMA_fast, 5);
   double SlowMa=iMAGet(handle_iMA_slow,0);
   double SlowMa2 = iMAGet(handle_iMA_slow, 2);
   double SlowMa5 = iMAGet(handle_iMA_slow, 5);

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(str1.hour>=HourTimeOpen && str1.hour<=HourTimeClose)
     {
      int total=0;
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               total++;

      if(total<1)
        {
         //---- sell conditions
         if((SlowMa-FastMa)>=m_symbol.Point() && (FastMa2-SlowMa2)>=m_symbol.Point() && 
            (FastMa5-SlowMa5)>=m_symbol.Point() && iClose(1)<iOpen(1))
           {
            if(!RefreshRates())
               return;

            m_trade.Sell(Lots,NULL,
                         m_symbol.Bid(),
                         m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss*m_adjusted_point),
                         m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit*m_adjusted_point));
            return;
           }
         //---- buy conditions
         if((FastMa-SlowMa)>=m_symbol.Point() && (SlowMa2-FastMa2)>=m_symbol.Point() && 
            (SlowMa5-FastMa5)>=m_symbol.Point() && iClose(1)>iOpen(1))
           {
            if(!RefreshRates())
               return;

            m_trade.Buy(Lots,NULL,
                        m_symbol.Ask(),
                        m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss*m_adjusted_point),
                        m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit*m_adjusted_point));
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
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
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
