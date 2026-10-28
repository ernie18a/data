//+------------------------------------------------------------------+
//|                                                  Simple MACD.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Trade on each new bar"
#property description "If MAIN_LINE MACD (1) > MAIN_LINE MACD (2) -> Buy"
#property description "If MAIN_LINE MACD (1) < MAIN_LINE MACD (2) -> Sell"
#property description "If Reverse -> Close all positions"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double   InpLots=0.1;                  // volume transaction
//---
ulong          m_magic=604918412;            // magic number
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
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
//--- работаем только на новом баре
   static datetime prev_time=0;              // статическа переменная (она сохраняет своё значение при следующем входе в процедуру)
   datetime time_0=iTime(0);
   if(prev_time==time_0)
      return;
   prev_time=time_0;                         // сохраним время

   double macd_2=iMACDGet(MAIN_LINE,2);
   double macd_1=iMACDGet(MAIN_LINE,1);

   if(DirectionsPositions()==-1)
      CloseAllPositions();

   if(macd_1>macd_2)
     {
      if(DirectionsPositions()==POSITION_TYPE_SELL)
         CloseAllPositions();
      if(!RefreshRates())
        {
         //--- так работа только на новом баре, то при ошибке сбросим "prev_time" - таким образом мы не теряем один бар
         prev_time=iTime(1);
         return;
        }
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=InpLots)
            m_trade.Buy(InpLots);
     }
   if(macd_1<macd_2)
     {
      if(DirectionsPositions()==POSITION_TYPE_BUY)
         CloseAllPositions();
      if(!RefreshRates())
        {
         //--- так работа только на новом баре, то при ошибке сбросим "prev_time" - таким образом мы не теряем один бар
         prev_time=iTime(1);
         return;
        }
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=InpLots)
            m_trade.Sell(InpLots);
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
//| Directions Positions                                             |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE DirectionsPositions(void)
  {
   ENUM_POSITION_TYPE pos_type=-1;
   int count_buy=0;
   int count_sell=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buy++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sell++;
           }
//---
   if(count_buy==0 && count_sell==0)
      return(-1); // нет позиций совсем
   if(count_buy!=0 && count_sell!=0)
      return(-1); // что-то пошло не так: есть разнонаправленные позиции
//--- если мы здесь, значит нормальная обработка
   if(count_buy!=0)
      pos_type=POSITION_TYPE_BUY;
   if(count_sell!=0)
      pos_type=POSITION_TYPE_SELL;
//---
   return(pos_type);
  }
//+------------------------------------------------------------------+
//| Close All Positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
