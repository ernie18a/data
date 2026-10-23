//+------------------------------------------------------------------+
//|                             BIG DOG(barabashkakvn's edition).mq5 |
//|                            FORTRADER.RU, Юрий, ftyuriy@gmail.com |
//|               http://www.fortrader.ru, Время + каналы + трейлинг |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU, Юрий, ftyuriy@gmail.com"
#property link      "http://FORTRADER.RU, TIME"
#property version   "1.001"
/*Разработано для 52 выпуска журнала FORTRADER.Ru. Система по стратегии большая собака. 
Обсуждение: http://forexsystems.ru/torgovaia-strategiia-big-dog-t8929.html?t=8929
Архив журнала: http://www.fortrader.ru/arhiv.php
52 выпуск: http://www.fortrader.ru/
*/
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
input uchar    StartHour         = 14;       // StartHour
input uchar    StopHour          = 16;       // StopHour
input ushort   InpMaxPoint       = 50;       // MaxPoint
input ushort   InpTakeProfit     = 50;       // TakeProfit
input double   Lots              = 0.1;      // Lots
input ushort   InpDistanceMaxMin = 20;       // DistanceMaxMin
//---
ulong          m_magic=2285752;              // magic number
int            day=0;                        // день в который поставлен отложенный ордер
double         ExtMaxPoint=0.0;
double         ExtTakeProfit=0.0;
double         ExtDistanceMaxMin=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double            m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   ExtMaxPoint       =InpMaxPoint        * m_adjusted_point;
   ExtTakeProfit     =InpTakeProfit      * m_adjusted_point;
   ExtDistanceMaxMin = InpDistanceMaxMin * m_adjusted_point;
   day=0;
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
   OpenPattern();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPattern()
  {
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   int total_orders=0;  // количество отложенных Stop ордеров
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total_orders++;

//--- Если новый день и есть отложенные ордера то удаляем ордера
   if(day!=str1.day_of_week && total_orders>0)
     {
      DeleteAllOrders();
      return; // после удаления отложенных ордеров выходим
     }

//---
   double high= GetHighLow_Time((int)StartHour,(int)StopHour,0);
   double low = GetHighLow_Time((int)StartHour,(int)StopHour,1);

   int total_buy=0;     // количество позиций Buy
   int total_sell=0;    // количество позиций Sell

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               total_buy++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               total_sell++;
           }

   TimeToStruct(iTime(m_symbol.Name(),Period(),1),str1);

   if(!RefreshRates())
      return;

   if(MathAbs(high-low)<ExtMaxPoint && str1.hour>=StopHour && total_orders==0)
     {
      if(total_sell==0 && (high-m_symbol.Ask())>ExtDistanceMaxMin)
        {
         day=str1.day_of_week;
         double sl=low;
         double tp=high+ExtTakeProfit;
         if(!m_trade.BuyStop(Lots,NormalizeDouble(high,m_symbol.Digits()),NULL,sl,tp,0,0,"FORTRADER.RU"))
           {
            Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", price: ",DoubleToString(high,m_symbol.Digits()),
                  ", sl: ",DoubleToString(sl,m_symbol.Digits()),
                  ", tp: ",DoubleToString(tp,m_symbol.Digits()));
           }
        }

      if(total_buy==0 && (m_symbol.Bid()-low)>ExtDistanceMaxMin)
        {
         day=str1.day_of_week;
         double sl=high;
         double tp=low-ExtTakeProfit;
         if(!m_trade.SellStop(Lots,NormalizeDouble(low,m_symbol.Digits()),NULL,sl,tp,0,0,"FORTRADER.RU"))
           {
            Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", price: ",DoubleToString(high,m_symbol.Digits()),
                  ", sl: ",DoubleToString(sl,m_symbol.Digits()),
                  ", tp: ",DoubleToString(tp,m_symbol.Digits()));
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetHighLow_Time(int Start,int Stop,int type)
  {
   double ret=0.0;

   MqlDateTime str1;
   TimeToStruct(iTime(m_symbol.Name(),Period(),1),str1);

   if(type==0)
     {
      if(str1.hour>=Stop)
        {
         for(int i=0;i<200;i++)
           {
            TimeToStruct(iTime(m_symbol.Name(),Period(),i),str1);
            if(str1.hour<=Stop)
              {
               if(iHigh(m_symbol.Name(),Period(),i)>ret)
                 {
                  ret=iHigh(m_symbol.Name(),Period(),i);
                 }
               if(str1.hour<=Start)
                 {
                  return(ret);
                 }
              }
           }
        }
     }

   if(type==1)
     {
      if(str1.hour>=Stop)
        {
         for(int i=0;i<200;i++)
           {
            TimeToStruct(iTime(m_symbol.Name(),Period(),i),str1);
            if(str1.hour<=Stop)
              {
               if(iLow(m_symbol.Name(),Period(),i)<ret || ret==0)
                 {
                  ret=iLow(m_symbol.Name(),Period(),i);
                 }
               if(str1.hour<=Start)
                 {
                  return(ret);
                 }
              }
           }
        }
     }

   return(ret);
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
