//+------------------------------------------------------------------+
//|                              21hour(barabashkakvn's edition).mq5 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#property description "Задаём временные интервалы ВНУТРИ ОДНИХ СУТОК"
#property version "1.001"
//+------------------------------------------------------------------+
//| 1.00:                                                            |
//|  один временной промежуток                                       |
//| 1.01:                                                            |
//|  два временных промежутка, при этом они не пересекаются          |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input double   Lots              = 0.1;      // Lots
input uchar    HourStartFirst    = 8;        // HourStartFirst
input uchar    HourStopFirst     = 21;       // HourStopFirst
input uchar    HourStartSecond   = 22;       // HourStartSecond
input uchar    HourStopSecond    = 23;       // HourStopSecond
input ushort   InpStep           = 5;        // Step
input ushort   InpTakeProfit     = 40;       // TakeProfit
//--- parameters
double         ExtStep=0.0;
double         ExtTakeProfit=0.0;
ulong          m_magic=12321;    // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point=0.0;      // point value adjusted for 3 or 5 points
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
//---checking timeslots
   if(!CheckingTimeslots())
      return(INIT_PARAMETERS_INCORRECT);
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtStep        = InpStep       * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit * m_adjusted_point;
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
   static datetime prevtime=0;            // статическая переменная для хранения времени
//--- посчитаем, есть ли открытая позиция
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;
//--- что-то пошло не так, позиций больше чем одна
   if(total>1)
     {
      ClosePositions();
      return;
     }
//--- есть одна позиция, значит удаляем отложенный/отложенные ордер
   if(total==1)
      DeleteOrders();
//--- работаем только в момент рождения нового бара
   if(iTime(0)==prevtime)
      return;
   prevtime=iTime(0);

   if(!IsTradeAllowed())
     {
      prevtime=iTime(0);
      return;
     }

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

//--- если текущее время попадает в начало первого или второго промежутка
   if((str1.hour==HourStartFirst && str1.min==0) || (str1.hour==HourStartSecond && str1.min==0))
     {
      //--- так как работает только на новом баре, то в случае
      //--- ошибки обновления текущих цен сбрасываем таймер
      if(!RefreshRates())
        {
         prevtime=iTime(1);
         return;
        }
      double price=NormalizeDouble(m_symbol.Ask()+ExtStep,m_symbol.Digits());
      double tp   =NormalizeDouble(m_symbol.Ask()+ExtStep+ExtTakeProfit,m_symbol.Digits());
      m_trade.BuyStop(Lots,price,NULL,0.0,tp);

      price       =NormalizeDouble(m_symbol.Bid()-ExtStep,m_symbol.Digits());
      tp          =NormalizeDouble(m_symbol.Bid()-ExtStep-ExtTakeProfit,m_symbol.Digits());
      m_trade.SellStop(Lots,price,NULL,0.0,tp);

      return;
     }

//--- если текущее время попадает в конец первого или второго промежутка, то
//--- закрываем позицию/позиции и удаляем отложенный ордер/ордера
   if((str1.hour==HourStopFirst && str1.min==0) || (str1.hour==HourStopSecond && str1.min==0))
     {
      ClosePositions();
      DeleteOrders();
     }

//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckingTimeslots()
  {
   bool res=true;

//--- проверка первого промежутка на равенство: нельзя, чтобы час старта был равен часу финиша
   if(HourStartFirst==HourStopFirst)
     {
      Print("Error: HourStartFirst (",HourStartFirst,") == HourStopFirst (",HourStopFirst,")");
      return(false);
     }
//--- проверка второго промежутка на равенство: нельзя, чтобы час старта был равен часу финиша
   if(HourStartSecond==HourStopSecond)
     {
      Print("Error: HourStartSecond (",HourStartSecond,") == HourStopSecond (",HourStopSecond,")");
      return(false);
     }

//--- проверка первого и второго промежутка на правильность времени: нельзя, чтобы часы старта был равны 
//--- или чтобы ВТОРОЙ промежуток был раньше ПЕРВОГО
   if(HourStartFirst>=HourStartSecond)
     {
      Print("Error: HourStartFirst (",HourStartFirst,") >= HourStartSecond (",HourStartSecond,")");
      return(false);
     }
//--- проверка первого и второго промежутка на правильность времени: нельзя, чтобы часы финиша был равны 
//--- или чтобы ВТОРОЙ промежуток был раньше ПЕРВОГО
   if(HourStopFirst>=HourStopSecond)
     {
      Print("Error: HourStopFirst (",HourStopFirst,") >= HourStopSecond (",HourStopSecond,")");
      return(false);
     }

//--- проверка первого промежутка на правильность времени: нельзя, чтобы время финиша было меньше времени старта
   if(HourStopFirst<HourStartFirst)
     {
      Print("Error: HourStopFirst (",HourStopFirst,") < HourStartFirst (",HourStartFirst,")");
      return(false);
     }
//--- проверка второго промежутка на правильность времени: нельзя, чтобы время финиша было меньше времени старта
   if(HourStopSecond<HourStartSecond)
     {
      Print("Error: HourStopSecond (",HourStopSecond,") < HourStartSecond (",HourStartSecond,")");
      return(false);
     }

//--- проверка на вложенность:
   if(HourStartFirst<HourStartSecond && HourStartSecond<HourStopFirst)
     {
      Print("Error: HourStartFirst (",HourStartFirst,") < HourStartSecond (",HourStartSecond,") && ",
            "HourStartSecond (",HourStartSecond,") < HourStopFirst (",HourStopFirst,")");
      return(false);
     }
//---
   return(res);
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
//| Delete All Orders                                                |
//+------------------------------------------------------------------+
void DeleteOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Close All Positions                                              |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
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
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
