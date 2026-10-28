//+------------------------------------------------------------------+
//|                                                   ChannelEA1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ChannelEA"
//+------------------------------------------------------------------+
//| Входные параметры                                                |
//+------------------------------------------------------------------+
input    uint              InpBeginHour   =  1;                      // Begin hour
input    uint              InpEndHour     =  10;                     // End hour
sinput   long              InpMagic       =  1234567;                // Experts magic number
input    double            InpVolume      =  0.1;                    // Lots
sinput   ulong             InpDeviation   =  10;                     // Slippage of price
sinput   uint              InpSizeSpread  =  2;                      // Multiplier spread for stops
sinput   uint              InpSleep       =  1;                      // Waiting for environment update (in seconds)
sinput   uint              InpNumAttempt  =  3;                      // Number of attempts to get the state of the environment
//+------------------------------------------------------------------+
//| Включения                                                        |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Объекты классов                                                  |
//+------------------------------------------------------------------+
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
CAccountInfo   account_info;        // Объект-CAccountInfo
CTerminalInfo  terminal_info;       // Объект-CTerminalInfo
CTrade         trade;               // Объект-CTrade
//+------------------------------------------------------------------+
//| Структура позиций                                                |
//+------------------------------------------------------------------+
struct SDatas
  {
   CArrayLong  list_tickets;        // список тикетоа
   double      total_volume;        // Общий объём
  };
//+------------------------------------------------------------------+
//| Структура данных позиций по типам                                |
//+------------------------------------------------------------------+
struct SDataPositions
  {
   SDatas      Buy;                 // Данные позиций Buy
   SDatas      BuyLimit;            // Данные ордеров BuyLimit
   SDatas      Sell;                // Данные позиций Sell
   SDatas      SellLimit;           // Данные ордеров SellLimit
  }
Data;
//+------------------------------------------------------------------+
//| Глобальные переменные                                            |
//+------------------------------------------------------------------+
double         lot;                 // Объём позиции
string         symb;                // Символ
int            hour_begin;          // Час начала
int            hour_end;            // Час окончания
int            prev_total_pos;      // Количество позиций на прошлой проверке
int            prev_total_ord;      // Количество ордеров на прошлой проверке
int            size_spread;         // Множитель спреда
uint           num_attempts;        // Количество попыток получения точного окружения
bool           trade_enabled;       // Флаг разрешения торговли
int            sleep;               // Ожидание обновления в секундах
datetime       last_time;           // Время открытия бара на прошлой проверке
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Установка торговых параметров
   if(!SetTradeParameters())
      return INIT_FAILED;
//--- Установка значений переменных
   symb=symbol_info.Name();
   hour_begin=int(InpBeginHour>23 ? 23 : InpBeginHour);
   hour_end=int(InpEndHour>23 ? 23 : InpEndHour);
   prev_total_pos=prev_total_ord=0;
   last_time=0;
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
//--- Заполнение списков тикетов ордеров и позиций
   int positions_total=PositionsTotal();
   int orders_total=OrdersTotal();
   if(prev_total_pos!=positions_total || prev_total_ord!=orders_total)
     {
      if(FillingListTickets(num_attempts))
        {
         if(prev_total_pos!=positions_total)
            prev_total_pos=positions_total;
         if(prev_total_ord!=orders_total)
            prev_total_ord=orders_total;
        }
      else return;
     }
//--- Проверка нового бара
   if(Time(0)!=last_time)
     {
      //--- Получение рабочего времени
      datetime StartTime=GetTime(TimeCurrent(),InpBeginHour);
      datetime EndTime=GetTime(TimeCurrent(),InpEndHour);
      //--- Удаление ордеров по времени
      if(Time(0)>=StartTime && Time(1)<StartTime)
        {
         if(!ClearAll())
            return;
        }
      //--- Установка ордеров по времени
      if(Time(1)>=EndTime && Time(2)<EndTime)
        {
         if(!EntryOrders())
            return;
        }
      //--- Все действия на новом баре выполнены
      last_time=Time(0);
     }
//---
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

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
//--- Установка множителя спреда для расчёта стоп-приказов
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
//--- Установка количества попыток и времени ожидания при получении окружения
   num_attempts=int(InpNumAttempt<1 ? 1 : InpNumAttempt);
   sleep=int(InpSleep<1 ? 1 : InpSleep)*1000;
   Print(__FUNCTION__,"sleep: ",sleep);
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
//| Возвращает цену High заданного бара                              |
//+------------------------------------------------------------------+
double High(int shift)
  {
   double array[];
   if(CopyHigh(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает цену Low заданного бара                               |
//+------------------------------------------------------------------+
double Low(int shift)
  {
   double array[];
   if(CopyLow(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает цену закрытия заданного бара                          |
//+------------------------------------------------------------------+
double Close(int shift)
  {
   double array[];
   if(CopyClose(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия заданного бара                         |
//+------------------------------------------------------------------+
datetime Time(const int shift)
  {
   datetime array[];
   if(CopyTime(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает время + час                                           |
//+------------------------------------------------------------------+
datetime GetTime(const datetime time,const int hour)
  {
   MqlDateTime tm;
   if(time==0 || !TimeToStruct(time,tm))
      return 0;
   tm.hour=hour;
   return StructToTime(tm);
  }
//+------------------------------------------------------------------+
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.hour;
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
   double total_volume=(position_type==POSITION_TYPE_BUY ? Data.Buy.total_volume : Data.Sell.total_volume);
   return(total_volume+volume<=symbol_info.LotsLimit());
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double stop_loss,const double open_price=0)
  {
   if(stop_loss==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(open_price>0 ? open_price : position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmin(price-lv*pt,stop_loss),dg) :
    NormalizeDouble(::fmax(price+lv*pt,stop_loss),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double take_profit,const double open_price=0)
  {
   if(take_profit==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(open_price>0 ? open_price : position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmax(price+lv*pt,take_profit),dg) :
    NormalizeDouble(::fmin(price-lv*pt,take_profit),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный уровень установки Limit-ордера             |
//+------------------------------------------------------------------+
double CorrectPriceLimit(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_order=0)
  {
   ENUM_ORDER_TYPE type=(order_type==ORDER_TYPE_BUY_LIMIT || order_type==ORDER_TYPE_BUY_STOP_LIMIT || order_type==ORDER_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (type==ORDER_TYPE_BUY ?
    NormalizeDouble(::fmin(price-lv*pt,price_order),dg) :
    NormalizeDouble(::fmax(price+lv*pt,price_order),dg)
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
bool CloseBuy(void)
  {
   int total=Data.Buy.list_tickets.Total();
   bool res=true;
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Buy.list_tickets.At(i);
      if(ticket==NULL) continue;
      if(!trade.PositionClose(ticket,InpDeviation))
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Удаляет ордера BuyLimit                                          |
//+------------------------------------------------------------------+
bool DeleteBuyLimit(void)
  {
   int total=Data.BuyLimit.list_tickets.Total();
   bool res=true;
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.BuyLimit.list_tickets.At(i);
      if(ticket==NULL) continue;
      if(!trade.OrderDelete(ticket))
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Закрывает позиции Sell                                           |
//+------------------------------------------------------------------+
bool CloseSell(void)
  {
   int total=Data.Sell.list_tickets.Total();
   bool res=true;
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Sell.list_tickets.At(i);
      if(ticket==NULL) continue;
      if(!trade.PositionClose(ticket,InpDeviation))
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Удаляет ордера SellLimit                                         |
//+------------------------------------------------------------------+
bool DeleteSellLimit(void)
  {
   int total=Data.SellLimit.list_tickets.Total();
   bool res=true;
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.SellLimit.list_tickets.At(i);
      if(ticket==NULL) continue;
      if(!trade.OrderDelete(ticket))
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Заполняет массивы тикетов ордеров и позиций                      |
//+------------------------------------------------------------------+
bool FillingListTickets(const uint number_of_attempts)
  {
//--- Проверка состояния окружения
   int n=0,attempts=int(number_of_attempts<1 ? 1 : number_of_attempts);
   while(IsUncertainStateEnv(symb,InpMagic) && n<attempts && !IsStopped())
     {
      n++;
      Sleep(sleep);
     }
   if(n>=attempts && IsUncertainStateEnv(symb,InpMagic))
     {
      Print(__FUNCTION__,": Uncertain state of the environment. Please try again.");
      return false;
     }
//---
   Data.Buy.list_tickets.Clear();
   Data.Sell.list_tickets.Clear();
   Data.Buy.total_volume=0;
   Data.Sell.total_volume=0;
//---
   int total=PositionsTotal();
   for(int i=total-1; i>WRONG_VALUE; i--)
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
         Data.Buy.total_volume+=volume;
        }
      else
        {
         Data.Sell.list_tickets.Add(ticket);
         Data.Sell.total_volume+=volume;
        }
     }
//---
   Data.BuyLimit.list_tickets.Clear();
   Data.SellLimit.list_tickets.Clear();
   Data.BuyLimit.total_volume=0;
   Data.SellLimit.total_volume=0;
   total=OrdersTotal();
//---
   for(int i=total-1; i>WRONG_VALUE; i--)
     {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=InpMagic)   continue;
      if(OrderGetString(ORDER_SYMBOL)!=symb)       continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double volume=OrderGetDouble(ORDER_VOLUME_INITIAL);
      if(type==ORDER_TYPE_BUY_LIMIT)
        {
         Data.BuyLimit.list_tickets.Add(ticket);
         Data.BuyLimit.total_volume+=volume;
        }
      if(type==ORDER_TYPE_SELL_LIMIT)
        {
         Data.SellLimit.list_tickets.Add(ticket);
         Data.SellLimit.total_volume+=volume;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает "неопределённое" состояние торгового окружения        |
//+------------------------------------------------------------------+
bool IsUncertainStateEnv(const string symbol_name,const ulong magic_number)
  {
   if(MQLInfoInteger(MQL_TESTER)) return false;
   int total=OrdersTotal();
   for(int i=total-1; i>WRONG_VALUE; i--)
     {
      if(OrderGetTicket(i)==0) continue;
      if(OrderGetInteger(ORDER_TYPE)>ORDER_TYPE_SELL) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=magic_number) continue;
      if(!OrderGetInteger(ORDER_POSITION_ID) && OrderGetString(ORDER_SYMBOL)==symbol_name)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Buy                                |
//+------------------------------------------------------------------+
int NumberBuy(void)
  {
   return Data.Buy.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество ордеров BuyLimit                           |
//+------------------------------------------------------------------+
int NumberBuyLimit(void)
  {
   return Data.BuyLimit.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Sell                               |
//+------------------------------------------------------------------+
int NumberSell(void)
  {
   return Data.Sell.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество ордеров SellLimit                          |
//+------------------------------------------------------------------+
int NumberSellLimit(void)
  {
   return Data.SellLimit.list_tickets.Total();
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
//| Возвращает тип истечения ордера, равный Expiration,              |
//| если он доступен на символе Symb, иначе - корректный вариант     |
//| https://www.mql5.com/ru/forum/170952/page4#comment_4128871       |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_TIME GetExpirationType(const string symbol_name,uint expiration=ORDER_TIME_GTC)
  {
   const int expiration_mode=(int)::SymbolInfoInteger(symbol_name,SYMBOL_EXPIRATION_MODE);

   if((expiration>ORDER_TIME_SPECIFIED_DAY) || (((expiration_mode>>expiration) &1)==0))
     {
      if((expiration<ORDER_TIME_SPECIFIED) || (expiration_mode<SYMBOL_EXPIRATION_SPECIFIED))
         expiration=ORDER_TIME_GTC;
      else if(expiration>ORDER_TIME_DAY)
         expiration=ORDER_TIME_SPECIFIED;

      uint i=1<<expiration;
      while((expiration<=ORDER_TIME_SPECIFIED_DAY) && ((expiration_mode  &i)!=i))
        {
         i<<=1;
         expiration++;
        }
     }

   return((ENUM_ORDER_TYPE_TIME)expiration);
  }
//+------------------------------------------------------------------+
//| Устанавливает два отложенных ордера на уровни канала             |
//+------------------------------------------------------------------+
bool EntryOrders()
  {
   FillingListTickets(num_attempts);
   int n=1;
   bool res=true,bl_res=true,sl_res=true;
   datetime StartTime=GetTime(TimeCurrent(),InpBeginHour);
   if(InpBeginHour>InpEndHour) StartTime-=86400;
   double MinPrice=DBL_MAX;
   double MaxPrice=0;
   while(Time(n)>=StartTime)
     {
      MinPrice=fmin(MinPrice,Low(n));
      MaxPrice=fmax(MaxPrice,High(n));
      n++;
     }
   if(n>2)
     {
      int num_bl=NumberBuyLimit();
      int num_sl=NumberSellLimit();
      if(num_bl==0)
        {
         double price=CorrectPriceLimit(symb,ORDER_TYPE_BUY,MinPrice);
         if(!SetOrder(ORDER_TYPE_BUY_LIMIT,lot,price,0,MaxPrice,""))
            bl_res=false;
        }
      if(num_sl==0)
        {
         double price=CorrectPriceLimit(symb,ORDER_TYPE_SELL,MaxPrice);
         if(!SetOrder(ORDER_TYPE_SELL_LIMIT,lot,price,0,MinPrice,""))
            sl_res=false;
        }
     }
   if(!bl_res || !sl_res)
      res=false;
   return res;
  }
//+------------------------------------------------------------------+
//| Закрывает позиции и удаляет ордера                               |
//+------------------------------------------------------------------+
bool ClearAll()
  {
   FillingListTickets(num_attempts);
   bool res=true,b_res=true,s_res=true,bl_res=true,sl_res=true;
   if(NumberBuy()>0)
     {
      if(!CloseBuy()) b_res=false;
     }
   if(NumberSell()>0)
     {
      if(!CloseSell()) s_res=false;
     }
   if(NumberBuyLimit()>0)
     {
      if(!DeleteBuyLimit()) bl_res=false;
     }
   if(NumberSellLimit()>0)
     {
      if(!DeleteSellLimit()) sl_res=false;
     }
   if(!b_res || !s_res || !bl_res || !sl_res) res=false;
   return res;
  }
//+------------------------------------------------------------------+
//| Установка ордера                                                 |
//+------------------------------------------------------------------+
bool SetOrder(const ENUM_ORDER_TYPE type,const double volume,const double price,const double stop_loss,const double take_profit,const string comment)
  {
   ENUM_POSITION_TYPE position_type=(type==ORDER_TYPE_BUY_LIMIT ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   double sl=CorrectStopLoss(symb,position_type,stop_loss,price);
   double tp=CorrectTakeProfit(symb,position_type,take_profit,price);
   double ll=trade.CheckVolume(symb,volume,price,(type==ORDER_TYPE_BUY_LIMIT ? ORDER_TYPE_BUY : ORDER_TYPE_SELL));
   if(ll>0 && CheckLotForLimitAccount(position_type,ll))
     {
      if(RefreshRates())
        {
         if(type==ORDER_TYPE_BUY_LIMIT)
           {
            if(trade.BuyLimit(ll,price,symb,sl,tp,GetExpirationType(symb),0,comment)) return true;
           }
         else
           {
            if(trade.SellLimit(ll,price,symb,sl,tp,GetExpirationType(symb),0,comment)) return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
