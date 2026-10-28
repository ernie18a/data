//+------------------------------------------------------------------+
//|            MacdPatternTraderAll0.01(barabashkakvn's edition).mq5 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+
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
23 номер
http://www.fortrader.ru/ftgate.php?id=0&num=67

В каждом номере торговая стратегия и советник. Присоединяйтесь!
Приглашаем авторов статей по трейдингу.

История изменений:
0.01 добавлено возможность выбора диапазона работы по в ремени с startdate по stopdate
0.01 добавлена возможность работы с растянутым мартингейлом

Скачать номер журнала и исследованием данного эксперта вы можете по данной ссылке:

Original description strategies:
http://www.unfx.ru/strategies_to_trade/strategies_134.php
 
Подробное описание параметров советника доступно в номере журнала от 26 Июля, 
предложения и отзывы мы будем рады видеть в нашей электропочте: letters@fortrader.ru
http://www.fortrader.ru/arhiv.php
 
A detailed description of the parameters adviser available issue of the journal dated Iule 26, 
suggestions and feedback we will be glad to see in our e-mail: letters@fortrader.ru
http://www.fortrader.ru/arhiv.php
 
Looking for an interpreter for the English version of the magazine on partnership.
*/
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.001"

input string p1="Настройки паттерна №1(A)";
input bool p1enable=true;
input int stoplossbars1=22;
input int takeprofitbars1=32;
input int otstup1= 40;
input int lowema1=13;
input int fastema1=24;
input double maxur1=0.0095;
input double minur1=-0.0045;

input string p2="Настройки паттерна №2(B)";
input bool p2enable=true;
input int stoplossbars2=2;
input int takeprofitbars2=2;
input int otstup2= 50;
input int lowema2=7;
input int fastema2=17;
input double maxur2=0.0045;
input double minur2=-0.0035;

input string p3="Настройки паттерна №3(C)";
input bool p3enable=true;
input int stoplossbars3=8;
input int takeprofitbars3=12;
input int otstup3= 2;
input int lowema3=2;
input int fastema3=32;

input double maxur3=0.0015;
input double maxur13=0.004;
input double minur3=-0.005;
input double minur13=-0.0005;

input string p4="Настройки паттерна №4(D)";
input bool p4enable=true;
input int stoplossbars4=10;
input int takeprofitbars4=32;
input int otstup4= 45;
input int lowema4=9;
input int fastema4=4;

input int sum_bars_bup4=10;
input double maxur4=0.0165;
input double maxur14=0.0001;
input double minur4=-0.0005;
input double minur14=-0.0006;

input string p5="Настройки паттерна №5(I)";
input bool p5enable=true;
input int stoplossbars5=8;
input int takeprofitbars5=47;
input int otstup5= 45;
input int lowema5=2;
input int fastema5=6;

input double maxu5=0.0005;
input double maxur5=0.0015;
double maxur15=0.0000;

input double minu5=-0.0005;
input double minur5=-0.0030;
double minur15=0.0000;

input string p6="Настройки паттерна №6(F)";
input bool p6enable=true;
input int stoplossbars6=26;
input int takeprofitbars6=42;
input int otstup6= 20;
input int lowema6=8;
input int fastema6=4;

input double maxur6=0.0005;
input double minur6=-0.0010;
int maxbars6=5;
int minbars6=5;
int countbars6=4;

input string xx="Настройки MA:";
input  int perema1=7;
input  int perema2=21;
input  int persma3=98;
input  int perema4=365;

input double InpLots=0.1;
datetime Bar;
ulong m_magic=24250;                         // magic number

input bool timecontrol=true;
input string starttime= "07:00:00";
input string stoptime = "17:00:00";

input bool slowmartin=true;
int buy,sell;
int nummodb,nummods;
int flaglot,bars_bup;
//---
//---
double ExtLots=0.0;
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
//---
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
   ExtLots=InpLots;
//--- create handle of the indicator iMACD
   handle_iMACD_1=iMACD(m_symbol.Name(),Period(),fastema1,lowema1,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_2=iMACD(m_symbol.Name(),Period(),fastema2,lowema2,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_3=iMACD(m_symbol.Name(),Period(),fastema3,lowema3,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_4=iMACD(m_symbol.Name(),Period(),fastema4,lowema4,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_4==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_5=iMACD(m_symbol.Name(),Period(),fastema5,lowema5,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_5==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD_6=iMACD(m_symbol.Name(),Period(),fastema6,lowema6,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD_6==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_1=iMA(m_symbol.Name(),Period(),perema1,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_2=iMA(m_symbol.Name(),Period(),perema2,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_3=iMA(m_symbol.Name(),Period(),persma3,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_4=iMA(m_symbol.Name(),Period(),perema4,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_4==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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

   if(timecontrol)
     {
      if(timecontrol(starttime,stoptime)==1)
         return;
     }
   if(Bar!=iTime(m_symbol.Name(),Period(),0))
     {
      Bar=iTime(m_symbol.Name(),Period(),0);
      if(p6enable)
         AOPattern6(countbars6,maxbars6,minbars6,maxur6,minur6,stoplossbars6,otstup6,takeprofitbars6);
      if(p5enable)
         AOPattern5(maxur5,minur5,stoplossbars5,otstup5,takeprofitbars6);
      if(p4enable)
         AOPattern4(stoplossbars4,otstup4,takeprofitbars4);
      if(p3enable)
         AOPattern3(stoplossbars3,otstup3,takeprofitbars3);
      if(p2enable)
         AOPattern2(stoplossbars2,otstup2,takeprofitbars2);
      if(p1enable)
         AOPattern1(stoplossbars1,otstup1,takeprofitbars1);
      ActivePosManager();
     }
   else
      return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int timecontrol(string start_time,string stop_time)
  {
   if(iTime(m_symbol.Name(),Period(),0)<=StringToTime(start_time) || iTime(m_symbol.Name(),Period(),0)>=StringToTime(stop_time))
     {
      return(1);
     }
   return(0);
  }
int stop,sstop,barnumm,barnumms,aopmaxur,aop_oksell,aop_okbuy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern6(int countbars,int maxbars,int minbars,double maxur,double minur,int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_6,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_6,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_6,MAIN_LINE,3);
   if(macdcurr<maxur)
      sstop=0;
   if(macdcurr>maxur && barnumm<=maxbars && sstop==0)
      barnumm=barnumm+1;
   if(barnumm>maxbars)
      barnumm=0;sstop=1;
   if(barnumm<minbars && macdcurr<maxur)
      barnumm=0;
   if(macdcurr<maxur && barnumm>countbars)
      aop_oksell=1;
   if(aop_oksell==1)
     {
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern6");
      aop_oksell=0;barnumm=0;
      nummods=0;
      sstop=0;
      flaglot=0;
      return;
     }
   if(macdcurr>minur)
      stop=0;
   if(macdcurr<minur && barnumms<=maxbars && stop==0)
      barnumms=barnumms+1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(barnumms>maxbars)
     {
      stop=1;
      barnumms=0;
     }
   if(barnumms<minbars && macdcurr>minur)
      barnumms=0;
   if(macdcurr>minur && barnumms>countbars)
      aop_okbuy=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(aop_okbuy==1)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern6");
      barnumms=0;
      aop_okbuy=0;
      nummodb=0;
      stop=0;
      flaglot=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern5(double maxur,double minur,int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   int stops5=0,Sb5=0,aop_oksell5=0,stopb5=0,Ss5=0,aop_okbuy5=0;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_5,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_5,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_5,MAIN_LINE,3);

   if(macdcurr<minu5 && stops5==0)
      stops5=1;
   if(macdcurr>minur && stops5==1)
     {
      stops5=0;
      Sb5=1;
     }
   if(Sb5==1 && macdcurr<macdlast && macdlast>macdlast3 && macdcurr<minur && macdlast>minur)
     {
      aop_oksell5=1;
      Sb5=0;
     }
   if(macdcurr>minur15)
     {
      stops5=0;
      aop_oksell5=0;
      Sb5=0;
     }
   if(aop_oksell5==1)
     {
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern5");
      aop_oksell5=0;
      nummods=0;
      stops5=0;
      Sb5=0;
      flaglot=0;
      return;
     }

   if(macdcurr>maxu5 && stopb5==0)
      stopb5=1;
   if(macdcurr<maxur15)
     {
      stopb5=0;
      aop_okbuy5=0;
      Ss5=0;
     }
   if(macdcurr<maxur && stopb5==1)
     {
      stopb5=0;
      Ss5=1;
     }
   if(Ss5==1 && macdcurr>macdlast && macdlast<macdlast3 && macdcurr>maxur && macdlast<maxur)
     {
      aop_okbuy5=1;
      Ss5=0;
     }
   if(aop_okbuy5==1)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern5");
      aop_okbuy5=0;
      nummodb=0;
      Ss5=0;
      flaglot=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern4(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   int aop_oksell4=0,aop_okbuy4=0,stops4=0,sstop4=0;
   double max14=0,min14=0;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_4,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_4,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_4,MAIN_LINE,3);
   if(macdcurr>maxur4 && macdcurr<macdlast && macdlast>macdlast3 && stops4==0)
     {
      max14=macdlast;
      stops4=1;
     }
   if(macdcurr<maxur4)
     {
      stops4=0;
      max14=0;
     }
   if(stops4==1 && macdcurr>maxur4 && macdcurr<macdlast && macdlast>macdlast3 && macdlast<max14)
      aop_oksell4=1;
   if(macdcurr<maxur4)
      aop_oksell4=0;
   if(aop_oksell4==1)
     {
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      max14=0;
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern4");
      aop_oksell4=0;
      nummods=0;
      flaglot=0;
      return;
     }
   if(macdcurr<minur4 && macdcurr>macdlast && macdlast<macdlast3 && sstop4==0)
     {
      min14=macdlast;
      sstop4=1;
     }
   if(macdcurr>minur4)
     {
      sstop4=0;
      min14=0;
     }
   if(sstop4==1 && macdcurr<minur4 && macdcurr>macdlast && macdlast<macdlast3 && macdlast>min14)
      aop_okbuy4=1;
   if(macdcurr>maxur4)
      aop_okbuy4=0;
   if(aop_okbuy4==1)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern4");
      aop_okbuy4=0;
      nummodb=0;
      sstop4=0;
      min14=0;
      flaglot=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern3(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;

   int aop_oksell3=0,aop_okbuy3=0,S3=0,bS3=0,stops3=0,stops13=0,sstops3=0,sstops13=0;
   double max13=0,max23=0,max33=0,min13=0,min23=0,min33=0;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_3,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_3,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_3,MAIN_LINE,3);
   if(macdcurr>maxur13){S3=1;bars_bup=bars_bup+1;}

   if(S3==1 && macdcurr<macdlast && macdlast>macdlast3 && macdlast>max13 && stops3==0)
      max13=macdlast;
   if(max13>0 && macdcurr<maxur3)
      stops3=1;
   if(macdcurr<maxur13)
     {
      stops3=0;max13=0;S3=0;
     }
   if(stops3==1 && macdcurr>maxur3 && macdcurr<macdlast && macdlast>macdlast3 && macdlast>max13 && macdlast>max23 && stops13==0)
      max23=macdlast;
   if(max23>0 && macdcurr<maxur3)
      stops13=1;
   if(macdcurr<maxur13)
     {
      stops13=0;
      max23=0;
     }
   if(stops13==1 && macdcurr<maxur3 && macdlast<maxur3 && macdlast3<maxur3 && macdcurr<macdlast && macdlast>macdlast3 && macdlast<max23 && aop_oksell3==0)
     {
      max33=macdlast;
      aop_oksell3=1;
     }
   if(macdcurr<maxur13)
      aop_oksell3=0;
   if(aop_oksell3==1)
     {
      max13=0;max23=0;max33=0;
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern3");
      aop_oksell3=0;
      nummods=0;
      bars_bup=0;
      flaglot=0;
      return;
     }
   if(macdcurr<minur3)
      bS3=1;
   if(bS3==1 && macdcurr>macdlast && macdlast<macdlast3 && macdlast<min13 && sstops3==0)
      min13=macdlast;
   if(min13<0 && macdcurr>minur3)
     {
      sstops3=1;
      bS3=0;
     }
   if(macdcurr>minur13)
     {
      sstops3=0;
      min13=0;
      bS3=0;
     }
   if(sstops3==1 && macdcurr<maxur3 && macdcurr>macdlast && macdlast<macdlast3 && macdlast<min13 && macdlast<min23 && sstops13==0)
      min23=macdlast;
   if(min23<0 && macdcurr>minur3)
     {
      sstops13=1;
      sstops3=0;
     }
   if(macdcurr>minur13)
     {
      sstops13=0;
      min23=0;
     }
   if(sstops13==1 && macdcurr>minur3 && macdlast>minur3 && macdlast3>minur3 && macdcurr>macdlast && macdlast<macdlast3 && macdlast>min23 && aop_okbuy3==0)
     {
      min33=macdlast;
      aop_okbuy3=1;
      sstops13=0;
     }
   if(macdcurr>maxur13)
      aop_okbuy3=0;
   if(aop_okbuy3==1)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern3");
      aop_okbuy3=0;
      nummodb=0;
      sstops13=0;
      min13=0;
      min23=0;
      min33=0;
      flaglot=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern2(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   double value_min2=0.0;
   double value_curr2=0.0;
   int aop_maxur2=0,aop_minur2=0,aop_oksell2=0,aop_okbuy2=0;double value_max2=0;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_2,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_2,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_2,MAIN_LINE,3);
   if(macdcurr>0)
     {
      aop_maxur2=1;
      aop_oksell2=0;
     }
   if(macdcurr>macdlast && macdlast<macdlast3 && aop_maxur2==1 && macdcurr>minur2 && macdcurr<0 && aop_oksell2==0)
     {
      aop_oksell2=1;
      value_min2=MathAbs(macdlast*10000);
     }
   value_curr2=MathAbs(macdcurr*10000);
   if(aop_oksell2==1 && macdcurr<macdlast && macdlast>macdlast3 && macdcurr<0 && value_min2<=value_curr2)
      aop_maxur2=0;
   if(aop_oksell2==1 && macdcurr<macdlast && macdlast>macdlast3 && macdcurr<0)
     {
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern2");
      aop_oksell2=0;
      aop_maxur2=0;
      nummods=0;
      flaglot=0;
      return;
     }
   if(macdcurr<0)
     {
      aop_minur2=1;
      aop_okbuy2=0;
     }
   if(macdcurr<maxur2 && macdcurr<macdlast && macdlast>macdlast3 && aop_minur2==1 && macdcurr>0)
     {
      aop_okbuy2=1;
      value_max2=MathAbs(macdlast*10000);
     }
   value_curr2=MathAbs(macdcurr*10000);
   if(aop_okbuy2==1 && macdcurr>macdlast && macdlast<macdlast3 && macdcurr>0 && value_max2<=value_curr2)
      aop_minur2=0;
   if(aop_okbuy2==1 && macdcurr>macdlast && macdlast<macdlast3 && macdcurr>0)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern2");
      aop_okbuy2=0;
      aop_minur2=0;
      nummodb=0;
      flaglot=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AOPattern1(int stoplossbars,int otstup,int takeprofitbars)
  {
   double sl=0.0;
   int aop_maxur1=0,aop_minur1=0,aop_oksell1=0,aop_okbuy1=0;
//--- опрашиваем индикаторы
   double macdcurr =iMACDGet(handle_iMACD_1,MAIN_LINE,1);
   double macdlast =iMACDGet(handle_iMACD_1,MAIN_LINE,2);
   double macdlast3=iMACDGet(handle_iMACD_1,MAIN_LINE,3);

   if(macdcurr>maxur1)
      aop_maxur1=1;
   if(macdcurr<0)
      aop_maxur1=0;
   if(macdcurr<maxur1 && macdcurr<macdlast && macdlast>macdlast3 && aop_maxur1==1 && macdcurr>0 && macdlast3<maxur1)
      aop_oksell1=1;
   if(aop_oksell1==1)
     {
      sl=StopLoss(0,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl<m_symbol.Bid())
         sl=sl+10*Point();
      m_trade.Sell(ExtLots,NULL,m_symbol.Bid(),sl,TakeProfit(0,takeprofitbars),"Pattern1");
      return;
      aop_oksell1=0;
      aop_maxur1=0;
      nummods=0;
      flaglot=0;
     }
   if(macdcurr<minur1)
      aop_minur1=1;
   if(macdcurr>0)
      aop_minur1=0;
   if(macdcurr>minur1 && macdcurr<0 && macdcurr>macdlast && macdlast<macdlast3 && aop_minur1==1 && macdlast3>minur1)
      aop_okbuy1=1;
   if(aop_okbuy1==1)
     {
      sl=StopLoss(1,stoplossbars,otstup);
      if(!RefreshRates())
         return;
      if(sl>m_symbol.Ask())
         sl=sl-10*Point();
      m_trade.Buy(ExtLots,NULL,m_symbol.Ask(),sl,TakeProfit(1,takeprofitbars),"Pattern1");
      aop_okbuy1=0;
      aop_minur1=0;
      nummodb=0;
      flaglot=0;
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
   int x=0,_stop=0;double takeprofit=0;
   if(type==0)
     {
      while(_stop==0)
        {
         takeprofit=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x));
         if(takeprofit>iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x+takeprofitbars)))
           {
            takeprofit=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,takeprofitbars,x+takeprofitbars));
            x=x+takeprofitbars;
           }
         else
           {
            _stop=1;
            return(takeprofit);
           }
        }
     }
   if(type==1)
     {
      while(_stop==0)
        {
         takeprofit=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x));
         if(takeprofit<iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x+takeprofitbars)))
           {
            takeprofit=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,takeprofitbars,x+takeprofitbars));
            x=x+takeprofitbars;
           }
         else
           {
            _stop=1;
            return(takeprofit);
           }
        }
     }
   return(takeprofit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActivePosManager()
  {
   double lt;

   double ema1=iMAGet(handle_iMA_1,1);
   double ema2=iMAGet(handle_iMA_2,1);
   double sma1=iMAGet(handle_iMA_3,1);
   double ema3=iMAGet(handle_iMA_4,1);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Profit()>5 && iClose(m_symbol.Name(),Period(),1)>ema2 && nummodb==0)
                 {
                  lt=NormalizeDouble(m_position.Volume()/3,2);
                  if(lt<=0.01)
                     lt=0.01;
                  //--- Partial Closing 
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  nummodb++;
                  continue;
                 }
               if(m_position.Profit()>5 && iHigh(m_symbol.Name(),Period(),1)>(sma1+ema3)/2.0 && nummodb==1)
                 {
                  lt=NormalizeDouble(m_position.Volume()/2,2);
                  if(lt<=0.01)
                     lt=0.01;
                  //--- Partial Closing 
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  nummodb++;
                  continue;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Profit()>5 && iClose(m_symbol.Name(),Period(),1)<ema2 && nummods==0)
                 {
                  lt=NormalizeDouble(m_position.Volume()/3,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  nummods++;
                  continue;
                 }
               if(m_position.Profit()>5 && iLow(m_symbol.Name(),Period(),1)<(sma1+ema3)/2 && nummods==1)
                 {
                  lt=NormalizeDouble(m_position.Volume()/2,2);
                  if(lt<=0.01)
                     lt=0.01;
                  m_trade.PositionClose(m_position.Ticket(),-1,lt);
                  nummods++;
                  continue;
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
               ExtLots=InpLots;
            else
               ExtLots*=2;
           }
     }
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
