//+------------------------------------------------------------------+
//|                                                       TimeEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- enums
enum ENUM_OPENED_TYPE
  {
   OPENED_TYPE_BUY,  // Long position
   OPENED_TYPE_SELL  // Short position
  };
//--- input parameters
sinput   long              InpMagic       =  1234567;          // Experts magic number
input    uint              InpHourOpen    =  1;                // Hour of position open
input    uint              InpMinuteOpen  =  0;                // Minute of position open
input    uint              InpHourClose   =  0;                // Hour of position close
input    uint              InpMinuteClose =  0;                // Minute of position close
input    ENUM_OPENED_TYPE  InpOpenedType  =  OPENED_TYPE_BUY;  // Position type
input    double            InpVolume      =  0.1;              // Lots
input    uint              InpStopLoss    =  0;                // Stop loss in points
input    uint              InpTakeProfit  =  0;                // Take profit in points
sinput   ulong             InpDeviation   =  10;               // Slippage of price
sinput   uint              InpSizeSpread  =  2;                // Multiplier spread for stops
//--- includes
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//--- objects
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
CAccountInfo   account_info;        // Объект-CAccountInfo
CTerminalInfo  terminal_info;       // Объект-CTerminalInfo
CTrade         trade;               // Объект-CTrade
//--- structures
struct SDatas
  {
   CArrayLong  list_tickets;        // список тикетоа
   double      total_vilume;        // Общий объём
  };
struct SDataPositions
  {
   SDatas      Buy;                 // Данные позиций Buy
   SDatas      Sell;                // Данные позиций Sell
  } Data;
//--- global variables
double         lot;                 // Объём позиции
string         symb;                // Символ
int            prev_total;          // Количество позиций на прошлой проверке
int            size_spread;         // Множитель спреда
int            hour_open;           // Час открытия позиции
int            minute_open;         // Минута открытия позиции
int            hour_close;          // Час закрытия позиции
int            minute_close;        // Минута закрытия позиции
ulong          open_time;           // Время открытия в милисекундах
ulong          close_time;          // Время закрытия в милисекундах
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Установка торговых параметров
   if(!SetTradeParameters())
      return INIT_FAILED;
//--- Установка значений переменных
   hour_open=int(InpHourOpen>23 ? 23 : InpHourOpen);
   minute_open=int(InpMinuteOpen>59 ? 59 : InpMinuteOpen);
   hour_close=int(InpHourClose>23 ? 23 : InpHourClose);
   minute_close=int(InpMinuteClose>59 ? 59 : InpMinuteClose);
   open_time=hour_open*60+minute_open;
   close_time=hour_close*60+minute_close;
//---
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   symb=symbol_info.Name();
//last_time=0;
   prev_total=0;
//--- Успешная инициализация
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
//--- Проверка нулевых цен
   if(!RefreshRates()) return;
//--- Заполнение списков тикетов позиций
   int positions_total=PositionsTotal();
   if(prev_total!=positions_total)
     {
      FillingListTickets();
      prev_total=positions_total;
     }
   int num_b=NumberBuy();
   int num_s=NumberSell();
//--- Открытие позиций по времени
   datetime time_hour_curr=TimeHour(TimeCurrent());
   datetime time_minutes_curr=TimeMinute(TimeCurrent());
   datetime time_hour_0=TimeHour(Time(0));
   datetime time_minutes_0=TimeMinute(Time(0));
   if(time_hour_curr<0 || time_minutes_curr<0 || time_hour_0<0 || time_minutes_0<0) return;
   ulong time_now=time_hour_curr*60+time_minutes_curr;
   ulong time_0=time_hour_0*60+time_minutes_0;
   if(time_0<=open_time && time_now>=open_time)
     {
      if(InpOpenedType==OPENED_TYPE_BUY)
        {
         if(num_s>0) CloseSell();
         if(num_b==0)
           {
            double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(ORDER_TYPE_BUY,InpStopLoss));
            double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(ORDER_TYPE_BUY,InpTakeProfit));
            double ll=trade.CheckVolume(symb,lot,SymbolInfoDouble(symb,SYMBOL_ASK),ORDER_TYPE_BUY);
            if(ll>0 && CheckLotForLimitAccount(POSITION_TYPE_BUY,ll))
              {
               if(trade.Buy(ll,symb,0,sl,tp))
                  FillingListTickets();
              }
           }
        }
      else
        {
         if(num_b>0) CloseBuy();
         if(num_s==0)
           {
            double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(ORDER_TYPE_SELL,InpStopLoss));
            double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(ORDER_TYPE_SELL,InpTakeProfit));
            double ll=trade.CheckVolume(symb,lot,SymbolInfoDouble(symb,SYMBOL_BID),ORDER_TYPE_SELL);
            if(ll>0 && CheckLotForLimitAccount(POSITION_TYPE_SELL,ll))
              {
               if(trade.Sell(ll,symb,0,sl,tp))
                  FillingListTickets();
              }
           }
        }
     }
   if(time_0<=close_time && time_now>=close_time)
     {
      if(InpOpenedType==OPENED_TYPE_BUY)
        {
         if(num_b>0) CloseBuy();
        }
      else
        {
         if(num_s>0) CloseSell();
        }
     }
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime date)
  {
   MqlDateTime tm={0};
   if(!TimeToStruct(date,tm)) return WRONG_VALUE;
   return tm.hour;
  }
//+------------------------------------------------------------------+
//| Возвращает минуту указанного времени                             |
//+------------------------------------------------------------------+
int TimeMinute(const datetime date)
  {
   MqlDateTime tm={0};
   if(!TimeToStruct(date,tm)) return WRONG_VALUE;
   return tm.min;
  }
//+------------------------------------------------------------------+
//| Установка торговых параметров                                    |
//+------------------------------------------------------------------+
bool SetTradeParameters()
  {
//--- Установка символа
   ResetLastError();
   if(!symbol_info.Name(Symbol()))
     {
      Print("Error setting ",Symbol()," symbol: ",GetLastError());
      return false;
     }
//--- Получение цен
   ResetLastError();
   if(!symbol_info.RefreshRates())
     {
      Print("Error obtaining ",symbol_info.Name()," data: ",GetLastError());
      return false;
     }
   if(account_info.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
     {
      Print(account_info.MarginModeDescription(),"-account. EA should work on a hedge account.");
      return false;
     }
//--- Автоматическая установка типа заполнения
   trade.SetTypeFilling(GetTypeFilling());
//--- Установка магика
   trade.SetExpertMagicNumber(InpMagic);
//--- Установка проскальзывания
   trade.SetDeviationInPoints(InpDeviation);
//--- Установка лота с корректировкой введённого значения
   lot=CorrectLots(InpVolume);
//--- 
   return true;
  }
//+------------------------------------------------------------------+
//| Обновление цен                                                   |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
   if(!symbol_info.RefreshRates()) return false;
   if(symbol_info.Ask()==0 || symbol_info.Bid()==0) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия заданного бара                         |
//+------------------------------------------------------------------+
datetime Time(int shift)
  {
   datetime array[];
   if(CopyTime(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает корректный лот                                        |
//+------------------------------------------------------------------+
double CorrectLots(const double lots,const bool to_min_correct=true)
  {
   double min=symbol_info.LotsMin();
   double max=symbol_info.LotsMax();
   double step=symbol_info.LotsStep();
   return(to_min_correct ? VolumeRoundToSmaller(lots,min,max,step) : VolumeRoundToCorrect(lots,min,max,step));
  }
//+------------------------------------------------------------------+
//| Возвращает ближайший корректный лот                              |
//+------------------------------------------------------------------+
double VolumeRoundToCorrect(const double volume,const double min,const double max,const double step)
  {
   return(step==0 ? min : fmin(fmax(round(volume/step)*step,min),max));
  }
//+------------------------------------------------------------------+
//| Возвращает ближайший в меньшую сторону корректный лот            |
//+------------------------------------------------------------------+
double VolumeRoundToSmaller(const double volume,const double min,const double max,const double step)
  {
   return(step==0 ? min : fmin(fmax(floor(volume/step)*step,min),max));
  }
//+------------------------------------------------------------------+
//| Возвращает флаг не превышения общего объёма на счёте             |
//+------------------------------------------------------------------+
bool CheckLotForLimitAccount(const ENUM_POSITION_TYPE position_type,const double volume)
  {
   if(symbol_info.LotsLimit()==0) return true;
   double total_volume=(position_type==POSITION_TYPE_BUY ? Data.Buy.total_vilume : Data.Sell.total_vilume);
   return(total_volume+volume<=symbol_info.LotsLimit());
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const ENUM_ORDER_TYPE order_type,const int stop_loss)
  {
   if(stop_loss==0) return 0;
   double pt=symbol_info.Point();
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_info.Name(),SYMBOL_ASK) : SymbolInfoDouble(symbol_info.Name(),SYMBOL_BID));
   int lv=StopLevel(),dg=symbol_info.Digits();
   return
   (order_type==ORDER_TYPE_BUY ?
    NormalizeDouble(fmin(price-lv*pt,price-stop_loss*pt),dg) :
    NormalizeDouble(fmax(price+lv*pt,price+stop_loss*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const ENUM_ORDER_TYPE order_type,const int take_profit)
  {
   if(take_profit==0) return 0;
   double pt=symbol_info.Point();
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_info.Name(),SYMBOL_ASK) : SymbolInfoDouble(symbol_info.Name(),SYMBOL_BID));
   int lv=StopLevel(),dg=symbol_info.Digits();
   return
   (order_type==ORDER_TYPE_BUY ?
    NormalizeDouble(fmax(price+lv*pt,price+take_profit*pt),dg) :
    NormalizeDouble(fmin(price-lv*pt,price-take_profit*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает рассчитанный StopLevel                                |
//+------------------------------------------------------------------+
int StopLevel(void)
  {
   int sp=symbol_info.Spread();
   int lv=symbol_info.StopsLevel();
   return(lv==0 ? sp*size_spread : lv);
  }
//+------------------------------------------------------------------+
//| Закрывает позиции Buy                                            |
//+------------------------------------------------------------------+
void CloseBuy(void)
  {
   int total=Data.Buy.list_tickets.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Buy.list_tickets.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
   FillingListTickets();
  }
//+------------------------------------------------------------------+
//| Закрывает позиции Sell                                           |
//+------------------------------------------------------------------+
void CloseSell(void)
  {
   int total=Data.Sell.list_tickets.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Sell.list_tickets.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
   FillingListTickets();
  }
//+------------------------------------------------------------------+
//| Заполняет массивы тикетов позиций                                |
//+------------------------------------------------------------------+
void FillingListTickets(void)
  {
   Data.Buy.list_tickets.Clear();
   Data.Sell.list_tickets.Clear();
   Data.Buy.total_vilume=0;
   Data.Sell.total_vilume=0;
//---
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic)   continue;
      if(PositionGetString(POSITION_SYMBOL)!=symb)       continue;
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double volume=PositionGetDouble(POSITION_VOLUME);
      if(type==POSITION_TYPE_BUY)
        {
         Data.Buy.list_tickets.Add(ticket);
         Data.Buy.total_vilume+=volume;
        }
      else
        {
         Data.Sell.list_tickets.Add(ticket);
         Data.Sell.total_vilume+=volume;
        }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Buy                                |
//+------------------------------------------------------------------+
int NumberBuy(void)
  {
   return Data.Buy.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Sell                               |
//+------------------------------------------------------------------+
int NumberSell(void)
  {
   return Data.Sell.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает тип исполнения ордера, равный type,                   |
//| если он доступен на символе, иначе - корректный вариант          |
//| https://www.mql5.com/ru/forum/170952/page4#comment_4128864       |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetTypeFilling(const ENUM_ORDER_TYPE_FILLING type=ORDER_FILLING_RETURN)
  {
   const ENUM_SYMBOL_TRADE_EXECUTION exe_mode=symbol_info.TradeExecution();
   const int filling_mode=symbol_info.TradeFillFlags();

   return(
          (filling_mode==0 || (type>=ORDER_FILLING_RETURN) || ((filling_mode &(type+1))!=type+1)) ?
          (((exe_mode==SYMBOL_TRADE_EXECUTION_EXCHANGE) || (exe_mode==SYMBOL_TRADE_EXECUTION_INSTANT)) ?
          ORDER_FILLING_RETURN :((filling_mode==SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) : type
          );
  }
//+------------------------------------------------------------------+
