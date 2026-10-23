//+------------------------------------------------------------------+
//|                MacdPatternTraderAll(barabashkakvn's edition).mq5 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+
#property version "1.001" 
#include <Trade\PositionInfo.mqh>
#include <Trade\PartialClosing.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CPartialClosing m_trade;                     // trading object
CSymbolInfo    m_symbol;                     // symbol info object
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3
/*
В каждом номере торговая стратегия и советник. Присоединяйтесь!
Приглашаем авторов статей по трейдингу.

Обрабатываем все паттерны стратегии FOREX MACD.
 
Original description strategies:
http://www.unfx.ru/strategies_to_trade/strategies_134.php
 
Подробное описание параметров советника доступно в номере журнала от 28 Июля, 
предложения и отзывы мы будем рады видеть в нашей электропочте: letters@fortrader.ru
http://www.fortrader.ru/arhiv.php
 
A detailed description of the parameters adviser available issue of the journal dated Iule 28, 
suggestions and feedback we will be glad to see in our e-mail: letters@fortrader.ru
http://www.fortrader.ru/arhiv.php
 
Looking for an interpreter for the English version of the magazine on partnership.
*/

#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"

input string p1="Настройки паттерна №1(A)";
input bool p1_enable=true;
input int stoplossbars1=22;
input int takeprofitbars1=32;
input int otstup1=40;
input int slow_ema_period_1=13;
input int fast_ema_period_1=24;
input double maxur1=0.0095;
input double minur1=-0.0045;

input string p2="Настройки паттерна №2(B)";
input bool p2_enable=true;
input int stoplossbars2=2;
input int takeprofitbars2=2;
input int otstup2=50;
input int slow_ema_period_2=7;
input int fast_ema_period_2=17;
input double maxur2=0.0045;
input double minur2=-0.0035;

input string p3="Настройки паттерна №3(C)";
input bool p3_enable=true;
input int stoplossbars3=8;
input int takeprofitbars3=12;
input int otstup3=2;
input int slow_ema_period_3=2;
input int fast_ema_period_3=32;

input double maxur3=0.0015;
input double maxur13=0.004;
input double minur3=-0.005;
input double minur13=-0.0005;

input string p4="Настройки паттерна №4(D)";
input bool p4_enable=true;
input int stoplossbars4=10;
input int takeprofitbars4=32;
input int otstup4=45;
input int slow_ema_period_4=9;
input int fast_ema_period_4=4;

input int sum_bars_bup4=10;
input double maxur4=0.0165;
input double maxur14=0.0001;
input double minur4=-0.0005;
input double minur14=-0.0006;

input string p5="Настройки паттерна №5(I)";
input bool p5_enable=true;
input int stoplossbars5=8;
input int takeprofitbars5=47;
input int otstup5=45;
input int slow_ema_period_5=2;
input int fast_ema_period_5=6;

input double maxu5=0.0005;
input double maxur5=0.0015;
double maxur15=0.0000;

input double minu5=-0.0005;
input double minur5=-0.0030;
double minur15=0.0000;

input string p6="Настройки паттерна №6(F)";
input bool p6_enable=true;
input int stoplossbars6=26;
input int takeprofitbars6=42;
input int otstup6=20;
input int slow_ema_period_6=8;
input int fast_ema_period_6=4;

input string ma="Настройки MA:";
input  int perema1=7;
input  int perema2=21;
input  int persma3=98;
input  int perema4=365;

input double Lots=0.1;
datetime Bar=0;
ulong m_magic=24250;                         // magic number

int buy,sell;int nummodb,nummods;int flaglot,bars_bup;
//---
int    handle_iMACD_1;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMACD_2;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMACD_3;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMACD_4;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMACD_5;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMACD_6;                       // variable for storing the handle of the iMACD indicator 
int    handle_iMA_1;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_2;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_3;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_4;                         // variable for storing the handle of the iMA indicator 
int    digits_adjust;
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
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
//--- create handle of the indicator iMACD
   handle_iMACD_1=iMACD(Symbol(),Period(),fast_ema_period_1,slow_ema_period_1,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_2=iMACD(Symbol(),Period(),fast_ema_period_2,slow_ema_period_2,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_3=iMACD(Symbol(),Period(),fast_ema_period_3,slow_ema_period_3,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_4=iMACD(Symbol(),Period(),fast_ema_period_4,slow_ema_period_4,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_4==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_5=iMACD(Symbol(),Period(),fast_ema_period_5,slow_ema_period_5,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_5==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_6=iMACD(Symbol(),Period(),fast_ema_period_6,slow_ema_period_6,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_6==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_1=iMA(Symbol(),Period(),perema1,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_2=iMA(Symbol(),Period(),perema2,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_3=iMA(Symbol(),Period(),persma3,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_4=iMA(Symbol(),Period(),perema4,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_4==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Comment("FORTRADER.RU");
   if(Bar!=iTime(0))
     {
      Bar=iTime(0);
      if(p6_enable==true)
        {
         AOPattern6(stoplossbars6,otstup6,takeprofitbars6);
        }
      if(p5_enable==true)
        {
         AOPattern5(stoplossbars5,otstup5,takeprofitbars6);
        }
      if(p4_enable==true)
        {
         AOPattern4(stoplossbars4,otstup4,takeprofitbars4);
        }
      if(p3_enable==true)
        {
         AOPattern3(stoplossbars3,otstup3,takeprofitbars3);
        }
      if(p2_enable==true)
        {
         AOPattern2(stoplossbars2,otstup2,takeprofitbars2);
        }
      if(p1_enable==true)
        {
         AOPattern1(stoplossbars1,otstup1,takeprofitbars1);
        }
      ActivePosManager();
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern6(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_6,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_6,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_6,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern6");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern6");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern5(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_5,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_5,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_5,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern5");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern5");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern4(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_4,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_4,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_4,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern4");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern4");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern3(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_3,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_3,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_3,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern3");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern3");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern2(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_2,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_2,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_2,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern2");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern2");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern1(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   string comment=IntegerToString(m_magic);
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_1,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_1,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_1,MAIN_LINE,3);

   if(macdlast3>0.0 || macdcurr<0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(0,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl<m_symbol.Bid())
            sl=sl+10*Point();
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern1");
         return;
        }
   if(macdlast3<0.0 || macdcurr>0.0)
      if(MathAbs(macdlast3/macdlast)>=5.0 && MathAbs(macdcurr/macdlast)>=5.0)
        {
         sl=StopLoss(1,stoplossbars,otstup);
         if(!RefreshRates())
            return;
         if(sl>m_symbol.Ask())
            sl=sl-10*Point();
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern1");

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLoss(int type,int stoplossbars,int otstup)
  {
   double stoploss=0.0;
   if(type==0)
     {
      stoploss=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,stoplossbars,1))+otstup*Point()*digits_adjust;
      return(stoploss);
     }
   if(type==1)
     {
      stoploss=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,stoplossbars,1))-otstup*Point()*digits_adjust;
      return(stoploss);
     }
   return(stoploss);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeProfit(int type,int takeprofitbars)
  {
   int x=0,stop=0;double takeprofit=0;

   if(type==0)
     {
      while(stop==0)
        {
         takeprofit=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x));
         if(takeprofit>iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x+takeprofitbars)))
           {
            takeprofit=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x+takeprofitbars));
            x=x+takeprofitbars;
           }
         else
           {
            stop=1;
            return(takeprofit);
           }
        }
     }

   if(type==1)
     {
      while(stop==0)
        {
         takeprofit=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x));
         if(takeprofit<iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x+takeprofitbars)))
           {
            takeprofit=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x+takeprofitbars));
            x=x+takeprofitbars;
           }
         else
           {
            stop=1;
            return(takeprofit);
           }
        }
     }
   return(takeprofit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  ActivePosManager()
  {
   string comment=IntegerToString(m_magic);

   double lt=0.0;
   double ema1=iMAGet(handle_iMA_1,1);
   double ema2=iMAGet(handle_iMA_2,1);
   double sma1=iMAGet(handle_iMA_3,1);
   double ema3=iMAGet(handle_iMA_4,1);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Profit()>5 && iClose(m_symbol.Name(),Period(),1)>ema2)
                 {
                  lt=NormalizeDouble(m_position.Volume()/3,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  continue;
                 }
               if(m_position.Profit()>5 && iHigh(m_symbol.Name(),Period(),1)>(sma1+ema3)/2)
                 {
                  lt=NormalizeDouble(m_position.Volume()/2,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  continue;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Profit()>5 && iClose(m_symbol.Name(),Period(),1)<ema2)
                 {
                  lt=NormalizeDouble(m_position.Volume()/3,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  continue;
                 }
               if(m_position.Profit()>5 && iLow(m_symbol.Name(),Period(),1)<(sma1+ema3)/2)
                 {
                  lt=NormalizeDouble(m_position.Volume()/2,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  continue;
                 }
              }
           }
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
double iMACDGet(int handle,const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
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
double iMAGet(int handle,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iLowest(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int type,
            int count=WHOLE_ARRAY,
            int start=0)
  {
   if(start<0)
      return(-1);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,timeframe,start,count,Low);
      return(ArrayMinimum(Low,0,count)+start);
     }
   if(type==MODE_HIGH)
     {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,timeframe,start,count,High);
      return(ArrayMinimum(High,0,count)+start);
     }
   if(type==MODE_CLOSE)
     {
      double Close[];
      ArraySetAsSeries(Close,true);
      CopyClose(symbol,timeframe,start,count,Close);
      return(ArrayMinimum(Close,0,count)+start);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
