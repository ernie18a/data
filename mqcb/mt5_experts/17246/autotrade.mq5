//+------------------------------------------------------------------+
//|                           Autotrade(barabashkakvn's edition).mq5 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, народное :-)"
#property link      "scrivimi@mail.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
input ushort   InpIndent              = 12;  // отступ для выставления отложенного ордера
input double   MinProfit              = 2;   // min прибыль в валюте депозита
input ushort   ExpirationMinutes      = 41;  // время истечения, минут
input double   AbsoluteFixation       = 43;  // прибыль или убыток по достижению которой закрываем
input ushort   InpStabilization       = 25;  // стабилизация пунктов
input double   Lots                   = 0.1; // объём открытия
//---
ulong          m_magic=16384; // magic number
double         ExtIndent=0.0;
double         ExtStabilization=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtIndent         = InpIndent        * m_adjusted_point;
   ExtStabilization  = InpStabilization * m_adjusted_point;
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
//double pip=MarketInfo(Symbol(),MODE_TICKSIZE);
//--- считаем открытые позиции
   int total=0;
   int count_buy=0;  // счётчик позиций Buy
   int count_sell=0; // счётчик позиций Sell
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buy++;
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sell++;
           }
//--- а теперь контроль: в работе может быть только одна позиция
   if(total>1)
     {
      if(count_buy>1 || count_sell>1 || count_buy+count_sell>1)
        {
         CloseAllPositions(); // закрываем все позиции, так как что-то пошло не так
         return;              // выходим
        }
     }
//---
   if(total==0)
     {
      //--- проверим количество отложенных ордеров
      int total_orders=0;
      for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
         if(m_order.SelectByIndex(i))
            if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
               total_orders++;
      //--- если есть более одного отложенного ордера - то выходим
      if(total_orders>1)
         return;

      //--- если не удалось обновить цены - то выходим
      if(!RefreshRates())
         return;

      double buy=m_symbol.Ask()+ExtIndent;
      double sell=m_symbol.Bid()-ExtIndent;
      //--- выставляем отложенный BuyStop ордер с ограниченным временем жизни 
      m_trade.BuyStop(Lots,buy,NULL,0.0,0.0,ORDER_TIME_SPECIFIED,TimeCurrent()+ExpirationMinutes*60);
      //--- выставляем отложенный SellStop ордер с ограниченным временем жизни 
      m_trade.SellStop(Lots,sell,NULL,0.0,0.0,ORDER_TIME_SPECIFIED,TimeCurrent()+ExpirationMinutes*60);
      return;                 // выходим
     }
//--- если мы здесь, значит есть одна открытая позиция по текущему символу и с текущим Magic
//--- и пока неизвестно сколько отложенных ордеров :)
   double close1=iClose(m_symbol.Name(),Period(),1);
   double close2=iClose(m_symbol.Name(),Period(),2);
   double open1=iOpen(m_symbol.Name(),Period(),1);
   double open2=iOpen(m_symbol.Name(),Period(),2);
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Profit()>MinProfit && MathAbs(iClose(m_symbol.Name(),Period(),1)-iOpen(m_symbol.Name(),Period(),1))<=ExtStabilization)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                  return;
                 }
               //--- защита от маленьких баров №1 и №2 - не оправдана - включение этой защиты ведёт к сливу
               //if(MathAbs(iClose(1)-iOpen(1))<=ExtStabilization && MathAbs(iClose(2)-iOpen(2))<=ExtStabilization)
               //  {
               //   m_trade.PositionClose(m_position.Ticket());
               //   DeleteOrders(ORDER_TYPE_SELL_STOP);
               //  }
               //--- выходим по достижению абсолютной прибыли или абсолютного убытка
               if(m_position.Profit()>=AbsoluteFixation || m_position.Profit()<=-AbsoluteFixation)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Profit()>MinProfit && MathAbs(iOpen(m_symbol.Name(),Period(),1)-iClose(m_symbol.Name(),Period(),1))<=ExtStabilization)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                  return;
                 }
               //--- защита от маленьких баров №1 и №2 - не оправдана - включение этой защиты ведёт к сливу
               //if(MathAbs(iOpen(1)-iClose(1))<=ExtStabilization && MathAbs(iOpen(2)-iClose(2))<=ExtStabilization)
               //  {
               //   m_trade.PositionClose(m_position.Ticket());
               //   DeleteOrders(ORDER_TYPE_BUY_STOP);
               //  }
               //--- выходим по достижению абсолютной прибыли или абсолютного убытка
               if(m_position.Profit()>=AbsoluteFixation || m_position.Profit()<=-AbsoluteFixation)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                 }
              }
           }
//----
   return;
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
//|  Закрываем все позиции по текущему символу и с текущим Magic     |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   Print(__FUNCTION__);
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
   return;
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
