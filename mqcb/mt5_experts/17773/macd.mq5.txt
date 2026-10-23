//+------------------------------------------------------------------+
//|                                                         MACD.mq5 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.001"
#property description "Обрабатываем паттерн продолжения тренда"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input ushort   InpTakeProfit    =60;         // Take Profit (in pips)
input ushort   InpStopLoss      =70;         // Stop Loss (in pips)
//---
int nummodb,nummods;
int flaglot,bars_bup;
int aop_maxur,aop_minur,aop_oksell=0,aop_okbuy=0,S=0,S1=0,stops=0,stops1=0,sstops1;
double max1,max2,max3,min1,min2,min3;
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
int    handle_iMACD;                         // variable for storing the handle of the iMACD indicator 
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
   Comment("FORTRADER.RU");
   AOPattern();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }

   double macd_last_1 =iMACDGet(MAIN_LINE,1);
   double macd_last_2 =iMACDGet(MAIN_LINE,2);
   double macd_last_3=iMACDGet(MAIN_LINE,3);

   if(macd_last_1<-0.0015 && stops1==0)
     {
      stops1=1;
     }

   if(macd_last_1>-0.0005 && stops1==1)
     {
      stops1=0;
      S1=1;
     }

   if(S1==1 && macd_last_1<macd_last_2 && macd_last_2>macd_last_3 && macd_last_1<-0.0005 && macd_last_2>-0.0005)
     {
      aop_oksell=1;
      S1=0;
     }

   if(macd_last_1>0)
     {
      stops1=0;
      aop_oksell=0;
      S1=0;
     }

   if(aop_oksell==1)
     {
      max1=0;
      max2=0;
      max3=0;
      m_trade.Sell(0.1,NULL,m_symbol.Bid(),
                   m_symbol.NormalizePrice(m_symbol.Bid()+InpStopLoss*m_adjusted_point),
                   m_symbol.NormalizePrice(m_symbol.Bid()-InpTakeProfit*m_adjusted_point),"FORTRADER.RU");
      aop_oksell=0;
      aop_maxur=0;
      nummods=0;
      flaglot=0;
      bars_bup=0;
      stops1=0;
      aop_oksell=0;
      S1=0;
     }

   if(macd_last_1>0.0015 && stops==0)
     {
      stops=1;
     }

   if(macd_last_1<0)
     {
      stops=0;
      aop_okbuy=0;
      S=0;
     }

   if(macd_last_1<0.0005 && stops==1)
     {
      stops=0;
      S=1;
     }

   if(S==1 && macd_last_1>macd_last_2 && macd_last_2<macd_last_3 && macd_last_1>0.0005 && macd_last_2<0.0005)
     {
      aop_okbuy=1;
      S=0;
     }

   if(aop_okbuy==1)
     {
      m_trade.Buy(0.1,NULL,m_symbol.Ask(),
                  m_symbol.NormalizePrice(m_symbol.Ask()-InpStopLoss*m_adjusted_point),
                  m_symbol.NormalizePrice(m_symbol.Ask()+InpTakeProfit*m_adjusted_point),"FORTRADER.RU");
      aop_okbuy=0;
      aop_minur=0;
      nummodb=0;
      flaglot=0;
      sstops1=0;
      min1=0;
      min2=0;
      min3=0;
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
