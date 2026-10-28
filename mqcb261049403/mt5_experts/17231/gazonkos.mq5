//+------------------------------------------------------------------+
//|                            gazonkos(barabashkakvn's edition).mq5 |
//|                                                    1H   EUR/USD  |
//|                                                    Smirnov Pavel |
//|                                                 www.autoforex.ru |
//+------------------------------------------------------------------+
#property copyright "Smirnov Pavel"
#property link      "www.autoforex.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
input ulong  m_magic       = 12345; // magic number
input ushort InpTakeProfit = 16;    // Уровень тейкпрофит в пунктах
input ushort InpRollback   = 16;    // Величина отката в пунктах
input ushort InpStopLoss   = 40;    // Уровень стоплосс в пунктах
input int    t1            = 3;
input int    t2            = 2;
input ushort InpDelta      = 40;    // iClose(t2)-iClose(t1)
input double lot           = 0.1;   // Размер позиции
input int    active_trades = 1;     // Максимальное количество одновременно открытых позиций
//---
int STATE=0;
int Trade=0;
double maxprice=0.0;
double minprice=10000.0;
bool cantrade=true;
int LastTradeTime=0;
int LastSignalTime=0;
//---
double ExtTakeProfit       = 0.0;
double ExtRollback         = 0.0;
double ExtStopLoss         = 0.0;
double ExtDelta            = 0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenLong(double volume=0.1)
  {
   bool result=false;
   if(!RefreshRates())
      return(false);

   string comment="gazonkos expert (Long)";

   if(m_trade.Buy(volume,m_symbol.Name(),
      m_symbol.Ask(),
      m_symbol.Ask()-ExtStopLoss,
      m_symbol.Ask()+ExtTakeProfit,comment))
     {
      Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
      result=true;
     }
   else
     {
      Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
      result=false;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenShort(double volume=0.1)
  {
   bool result=false;
   if(!RefreshRates())
      return(false);

   string comment="gazonkos expert (Short)";

   if(m_trade.Sell(volume,m_symbol.Name(),
      m_symbol.Bid(),
      m_symbol.Bid()+ExtStopLoss,
      m_symbol.Bid()-ExtTakeProfit,comment))
     {
      Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
      result=true;
     }
   else
     {
      Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
      result=false;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Подсчёт позиций на текущем символе и с нужным MagicValue         |
//+------------------------------------------------------------------+
int PositionsTotalMagic(ulong MagicValue)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // выбираем позицию
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++; // считаем только те, у которых совпадает символ и magic
//--- Возвращаем количество подсчитанных ордеров с magic = MagicValue.  
   return(total);
  }
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTakeProfit  = InpTakeProfit * m_symbol.Point() * digits_adjust;
   ExtRollback    = InpRollback   * m_symbol.Point() * digits_adjust;
   ExtStopLoss    = InpStopLoss   * m_symbol.Point() * digits_adjust;
   ExtDelta       = InpDelta      * m_symbol.Point() * digits_adjust;
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
   if(!RefreshRates())
      return;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

//--- STATE = 0  Ждем сигнала к началу работы советника
   if(STATE==0)
     {
      //---
      cantrade=true;
      //--- запрещаем торговать пока не наступит новый час после последней 
      //--- открытой сделки (чтобы избежать множественных открываний сделок на одном и том же часовом баре)    
      if(str1.hour==LastTradeTime)
         cantrade=false;
      //--- проверяем на допустимое количество открытых позиций
      if(PositionsTotalMagic(m_magic)>=active_trades)
         cantrade=false;
      //--- если не было ни одного запрета на открытие сделок, 
      //--- то переходим к ожиданию сигналов системы на открытие ордеров
      if(cantrade)
         STATE=1;
     }

//--- STATE = 1  Ждем импульса (движения) цены 
   if(STATE==1)
     {
      if((iClose(t2)-iClose(t1))>ExtDelta) // сигнал для входа в длинную позицию
        {
         Trade=1; //идентификатор позиции, для которой получен сигнал на открытие  "-1" - короткая позиция, "1"-длинная
         maxprice=m_symbol.Bid();   // запоминаем текущее положение цены (необходимо для определения отката в STATE=2)
         LastSignalTime=str1.hour;  //Запоминаем время получения сигнала
         STATE=2; // перейти в следующее состояние
        }

      if((iClose(t1)-iClose(t2))>ExtDelta) // сигнал для входа в короткую позицию
        {
         Trade=-1; // идентификатор позиции, для которой получен сигнал на открытие  "-1" - короткая позиция, "1"-длинная
         minprice=m_symbol.Bid();   // запоминаем текущее положение цены (необходимо для определения отката в STATE=2)
         LastSignalTime=str1.hour;  //Запоминаем время получения сигнала
         STATE=2; // перейти в следующее состояние
        }
     }

//--- STATE = 2 - Ждем отката цены    
   if(STATE==2)
     {
      //--- Если на баре на котором получен сигнал не произошло отката,то переходим в состояние STATE=0
      if(LastSignalTime!=str1.hour)
        {
         STATE=0;
         return;
        }
      if(Trade==1) // ожидаем отката для длинной позиции
        {
         //--- если цена пошла еще выше, то меняем значение maxprice на текущее значение цены
         if(m_symbol.Bid()>maxprice)
            maxprice=m_symbol.Bid();
         //--- проверяем наличие отката цены после импульса 
         if(m_symbol.Bid()<(maxprice-ExtRollback))
            STATE=3; // если произошел откат на величину ExtRollback, то переходим в состояние открытия длинной позиции
        }
      if(Trade==-1) // ожидаем отката для короткой позиции
        {
         //--- если цена пошла еще ниже, то меняем значение minprice на текущее значение цены
         if(m_symbol.Bid()<minprice)
            minprice=m_symbol.Bid();
         //--- проверяем наличие отката цены после импульса
         if(m_symbol.Bid()>(minprice+ExtRollback))
            STATE=3; // если произошел откат на величину ExtRollback, то переходим в состояние открытия короткой позиции
        }
     }

//--- STATE = 3 - открываем позиции согласно переменной Trade ("-1" - короткую, "1" - длинную)  
   if(STATE==3)
     {
      if(Trade==1) // открываем длинную позицию
        {
         if(OpenLong(lot)) // если Длинная позиция открыта удачно
           {
            LastTradeTime=str1.hour;   // запоминаем время совершения последней сделки
            STATE=0;                   // переходим в состояние ожидания
           }
        }
      if(Trade==-1) // открываем короткую позицию
        {
         if(OpenShort(lot)) // если короткая позиция открыта удачно  
           {
            LastTradeTime=str1.hour;   //запоминаем время совершения последней сделки
            STATE=0;                   //переходим в состояние ожидания
           }
        }
     }
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
