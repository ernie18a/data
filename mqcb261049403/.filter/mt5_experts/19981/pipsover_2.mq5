//+------------------------------------------------------------------+
//|                                                   Pipsover 2.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property description "Version 1: https://www.mql5.com/ru/code/17163"
#property version "2.004"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots           = 0.1;      // Lots
input ushort   InpStopLoss       = 65;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 100;      // Take Profit (in pips)
input double   InpOpenLevel      = 100;      // Chaikin level for opening a position
input double   InpCloseLevel     = 125;      // Chaikin level for position locking
input ushort   InpTrailingStop   = 30;       // Trailing Stop (in pips)
input ushort   InpBreakeven      = 15;       // Break-even (and trailing step), minimum is 1
input int      MA_ma_period      = 20;       // MA: averaging period 
input int      MA_ma_shift       = 0;        // MA: horizontal shift of the indicator
input ENUM_MA_METHOD MA_ma_method=MODE_SMA;  // MA: smoothing type
input ENUM_APPLIED_PRICE MA_applied_price=PRICE_CLOSE;// MA: type of price
input int      Chaikin_fast_ma_period=3;     // Chaikin: fast period
input int      Chaikin_slow_ma_period=10;    // Chaikin: slow period
input ENUM_MA_METHOD Chaikin_ma_method=MODE_EMA;// Chaikin: smoothing type
input ulong    m_magic=888;                  // magic number
//---
ulong          m_slippage=10;                // slippage
//---
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtBreakeven=0.0;

int               handle_iMA;                // variable for storing the handle of the iMA indicator 
int               handle_iChaikin;           // variable for storing the handle of the iChaikin indicator  
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double            m_adjusted_point=0.0;      // tuning for 3 or 5 digits
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpBreakeven==0 && InpTrailingStop!=0)
     {
      string text="Trailing can not work when \"The break-even (and step of the trailing)\" is zero!";
      Alert(text);
      Print(text);
      return(INIT_PARAMETERS_INCORRECT);
     }
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtStopLoss    = InpStopLoss     *m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit   *m_adjusted_point;
   ExtTrailingStop= InpTrailingStop *m_adjusted_point;
   ExtBreakeven   = InpBreakeven    *m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),MA_ma_period,MA_ma_shift,MA_ma_method,MA_applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iChaikin
   handle_iChaikin=iChaikin(m_symbol.Name(),Period(),Chaikin_fast_ma_period,Chaikin_slow_ma_period,Chaikin_ma_method,VOLUME_TICK);
//--- if the handle is not created 
   if(handle_iChaikin==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iChaikin indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   long chart_windows_total=ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(0,0,handle_iMA);
   ChartIndicatorAdd(0,(int)chart_windows_total,handle_iChaikin);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   long chart_windows_total=ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   for(int i=(int)chart_windows_total;i>=0;i--)
      for(int j=ChartIndicatorsTotal(0,i)-1;j>=0;j--)
         ChartIndicatorDelete(0,i,ChartIndicatorName(0,i,j));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   double ma=iMAGet(0);       // The value of the indicator "Moving Average" on the bar #0
   double ch=iChaikinGet(1);  // The value of the indicator "Chaikin" on the bar #1

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(!RefreshRates())
      return;
   if(total<1) // if not open positions
     {
      //--- if the value of the Chaikin indicator is very large and a potential reversal has begun
      //--- a kind of oversold --> buy
      if(iClose(1)>iOpen(1) && iLow(1)<ma && ch<-InpOpenLevel)
        {
         double level_price=m_symbol.Ask();
         double level_sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double level_tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         m_trade.Buy(InpLots,NULL,level_price,
                     m_symbol.NormalizePrice(level_sl),
                     m_symbol.NormalizePrice(level_tp),"Pipsover");
         return;
        }
      //--- if the value of the Chaikin indicator is very large and a potential reversal has begun
      //--- overbought --> sell
      if(iClose(1)<iOpen(1) && iHigh(1)>ma && ch>InpOpenLevel)
        {
         double level_price=m_symbol.Bid();
         double level_sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double level_tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         m_trade.Sell(InpLots,NULL,level_price,
                      m_symbol.NormalizePrice(level_sl),
                      m_symbol.NormalizePrice(level_tp),"Pipsover");
         return;
        }
     }
   else
     {
      //--- there are open positions. Maybe it's time to hedge?
      //--- if only one position is open
      if(total==1)
        {
         if(m_position.SelectByIndex(0))
           {
            //--- looks like a pullback, we will hedge a long position
            if(m_position.PositionType()==POSITION_TYPE_BUY && 
               iClose(1)<iOpen(1) && iHigh(1)>ma && ch>InpCloseLevel)
              {
               double level_price=m_symbol.Bid();
               double level_sl=m_symbol.Ask()+ExtStopLoss;
               double level_tp=m_symbol.Ask()-ExtTakeProfit;
               m_trade.Sell(InpLots,NULL,level_price,level_sl,level_tp,"Pipsover");
               return;
              }
            //--- looks like a pullback, we will hedge a short position
            if(m_position.PositionType()==POSITION_TYPE_SELL && 
               iClose(1)>iOpen(1) && iLow(1)<ma && ch<-InpCloseLevel)
              {
               double level_price=m_symbol.Ask();
               double level_sl=m_symbol.Bid()-ExtStopLoss;
               double level_tp=m_symbol.Bid()+ExtTakeProfit;
               m_trade.Buy(InpLots,NULL,level_price,level_sl,level_tp,"Pipsover");
               return;
              }
           }
        }
      //--- 
      if(InpTrailingStop!=0)
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
            if(m_position.SelectByIndex(i))
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     //--- breakeven
                     if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtBreakeven)
                        if(m_position.StopLoss()<m_position.PriceOpen() && 
                           !CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_position.PriceOpen(),
                              m_position.TakeProfit()))
                              Print("Modify (breakeven) ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                           continue;
                          }
                     //--- trailing
                     if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtBreakeven)
                        if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtBreakeven))
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                              m_position.TakeProfit()))
                              Print("Modify (trailing) ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                           continue;
                          }
                    }
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     //--- breakeven
                     if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtBreakeven)
                        if((m_position.StopLoss()>m_position.PriceOpen() || m_position.StopLoss()==0.0) && 
                           !CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_position.PriceOpen(),
                              m_position.TakeProfit()))
                              Print("Modify (breakeven) ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                           continue;
                          }
                     //--- trailing
                     if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtBreakeven)
                        if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtBreakeven))) || 
                           (m_position.StopLoss()==0))
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                              m_position.TakeProfit()))
                              Print("Modify (trailing) ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                          }
                    }
                 }
     }
//---
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
double iMAGet(const int index)
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
//| Get value of buffers for the iChaikin                            |
//+------------------------------------------------------------------+
double iChaikinGet(const int index)
  {
   double Chaikin[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iChaikin array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iChaikin,0,index,1,Chaikin)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iChaikin indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Chaikin[0]);
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
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
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
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
