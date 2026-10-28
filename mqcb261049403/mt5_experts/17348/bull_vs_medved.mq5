//+------------------------------------------------------------------+
//|                      Bull vs Medved(barabashkakvn's edition).mq5 |
//|                       Copyright © 2008, Andrey Kuzmenko (Foxbat) |
//|                                          mailto:foxbat-b@mail.ru |
//+------------------------------------------------------------------+
//| Некоторые "общеполезные" функции кода, трейлинг стоп, например,  |
//| были любезно позаимствованы из других экспертов.                 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Andrey Kuzmenko (Foxbat)"
#property link      "foxbat-b@mail.ru"
#property version   "1.001"
//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//---
input double   Lots           = 0.10;        // размер лота
input ushort   InpCandleSize  = 75;          // размер тела свечи
input ushort   InpStopLoss    = 60;          // StopLoss
input ushort   InpTakeProfit  = 60;          // TakeProfit
input ushort   InpIndentUP    = 16;          // отступ для Buylimit
input ushort   InpIndentDOWN  = 20;          // отступ для Selllimit
input string   StartTime      = "0:05";      // Время старта по гринвичу
input string   StartTime1     = "4:05";
input string   StartTime2     = "8:05";
input string   StartTime3     = "12:05";
input string   StartTime4     = "16:05";
input string   StartTime5     = "20:05";
//---
bool           trade          = false;
bool           trade1         = false;
double         Limit          = 400;
string         Name_Expert    = "Bull vs Medved";
bool           UseSound       = true;
string         NameFileSound  = "alert.wav";
//---
ulong          m_magic=612453;               // magic number
ulong          m_slippage=0;                 // slippage
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
double         ExtCandleSize  = 0;
double         ExtIndentUP    = 0;
double         ExtIndentDOWN  = 0;
double         ExtStopLoss    = 0;
double         ExtTakeProfit  = 0;
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
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtCandleSize  = InpCandleSize * m_adjusted_point;
   ExtIndentUP    = InpIndentUP   * m_adjusted_point;
   ExtIndentDOWN  = InpIndentDOWN * m_adjusted_point;
   ExtStopLoss    = InpStopLoss   * m_adjusted_point;
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
//--- переводим время из строчной величины StartTime во временнУю TimeStart
   datetime TimeStart=StringToTime(StartTime);
   datetime TimeStart1=StringToTime(StartTime1);
   datetime TimeStart2=StringToTime(StartTime2);
   datetime TimeStart3=StringToTime(StartTime3);
   datetime TimeStart4=StringToTime(StartTime4);
   datetime TimeStart5=StringToTime(StartTime5);
//--- если текущее время меньше стартового или больше его на 5 минут, то выходим и ничего не делаем.
//--- но предварительно делаем переменную trade ложной. Просто сбрасываем информацию о том, что уже открывались.
   if((TimeCurrent()<TimeStart || TimeCurrent()>TimeStart+300) && 
      (TimeCurrent()<TimeStart1 || TimeCurrent()>TimeStart1+300) && 
      (TimeCurrent()<TimeStart2 || TimeCurrent()>TimeStart2+300) && 
      (TimeCurrent()<TimeStart3 || TimeCurrent()>TimeStart3+300) && 
      (TimeCurrent()<TimeStart4 || TimeCurrent()>TimeStart4+300) && 
      (TimeCurrent()<TimeStart5 || TimeCurrent()>TimeStart5+300))
     {
      trade=false;
      return;
     }

   if(trade)
      return;

   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",m_account.FreeMargin());
      return;
     }
   if(!IsPendingOrders())
     {
      if(IsBull()==true && IsBadBull()==false)
        {
         PlacementBuyLimit();
         return;
        }
     }

   if(!IsPendingOrders())
     {
      if(IsCoolBull()==true)
        {
         PlacementBuyLimit();
         return;
        }
     }

   if(!IsPendingOrders())
     {
      if(IsBear()==true)
        {
         PlacementSellLimit();
         return;
        }
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBull()
  {
   if((iClose(m_symbol.Name(),Period(),3)>iOpen(m_symbol.Name(),Period(),2)) &&
      (iClose(m_symbol.Name(),Period(),2)-iOpen(m_symbol.Name(),Period(),2)>=10*m_symbol.Point()) &&
      (iClose(m_symbol.Name(),Period(),1)-iOpen(m_symbol.Name(),Period(),1)>=ExtCandleSize))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBadBull()
  {
   if((iClose(m_symbol.Name(),Period(),3)-iOpen(m_symbol.Name(),Period(),3)>=10*m_symbol.Point()) &&
      (iClose(m_symbol.Name(),Period(),2)-iOpen(m_symbol.Name(),Period(),2)>=10*m_symbol.Point()) &&
      (iClose(m_symbol.Name(),Period(),1)-iOpen(m_symbol.Name(),Period(),1)>=ExtCandleSize))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsCoolBull()
  {
   if((iOpen(m_symbol.Name(),Period(),2)-iClose(m_symbol.Name(),Period(),2)>=20*m_symbol.Point()) && 
      (iClose(m_symbol.Name(),Period(),2)<=iOpen(m_symbol.Name(),Period(),1)) && 
      (iClose(m_symbol.Name(),Period(),1)>iOpen(m_symbol.Name(),Period(),2)) && 
      (iClose(m_symbol.Name(),Period(),1)-iOpen(m_symbol.Name(),Period(),1)>=0.4*ExtCandleSize))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBear()
  {
   if((iOpen(m_symbol.Name(),Period(),1)-iClose(m_symbol.Name(),Period(),1)>=ExtCandleSize))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Поиск отложенных ордеров                                           |
//+------------------------------------------------------------------+
bool IsPendingOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//| Размещаем Buy Limit:                                             |
//| |                                                                |
//| ||                                                               |
//|  ||                                                              |
//|  ||                                                              |
//|   | - текущая цена Ask                                           |
//|   | - текущая цена Bid                                           |
//|   ||                                                             |
//|    ||                                                            |
//|     |                                                            |
//|     | - здесь уровень Buy Limit                                  |
//+------------------------------------------------------------------+   
void PlacementBuyLimit()
  {
//--- для отложенных ордеров выставляем время истечения равное + четыре часа
   if(!RefreshRates())
      return;

   double price=m_symbol.Ask()-ExtIndentUP;
   double sl   =price-ExtStopLoss;
   double tp   =price+ExtTakeProfit;

   if(!m_trade.BuyLimit(Lots,price,NULL,sl,tp,ORDER_TIME_SPECIFIED,TimeCurrent()+4*60*60,Name_Expert))
     {
      Print("BuyLimit -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
     }
   else
     {
      if(UseSound)
         PlaySound(NameFileSound);
     }
  }
//+------------------------------------------------------------------+
//| Размещаем Sell Limit:                                            |
//|     | - здесь уровень Sell Limit                                 |
//|     |                                                            |
//|    ||                                                            |
//|   ||                                                             |
//|   | - текущая цена Ask                                           |
//|   | - текущая цена Bid                                           |
//|  ||                                                              |
//|  ||                                                              |
//| ||                                                               |
//| |                                                                |
//+------------------------------------------------------------------+
void PlacementSellLimit()
  {
//--- для отложенных ордеров выставляем время истечения равное + четыре часа
   if(!RefreshRates())
      return;

   double price=m_symbol.Bid()+ExtIndentUP;
   double sl   =price+ExtStopLoss;
   double tp   =price-ExtTakeProfit;

   if(!m_trade.SellLimit(Lots,price,NULL,sl,tp,ORDER_TIME_SPECIFIED,TimeCurrent()+4*60*60,Name_Expert))
     {
      Print("SellLimit -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
     }
   else
     {
      if(UseSound)
         PlaySound(NameFileSound);
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
