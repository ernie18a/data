//+------------------------------------------------------------------+
//|                                                  SerialMA_EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Входной параметр "Да/Нет"                                        |
//+------------------------------------------------------------------+
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,                      // Yes
   INPUT_NO    =  0                       // No
  };
//+------------------------------------------------------------------+
//| Перечисление разрешённых типов позиций                           |
//+------------------------------------------------------------------+
enum ENUM_OPENED_MODE
  {
   OPENED_MODE_ALL_SWING,                 // Position on each signal in one direction (swing)
   OPENED_MODE_ONE_SWING,                 // Always one position (swing)
  };
//+------------------------------------------------------------------+
//| Входные параметры                                                |
//+------------------------------------------------------------------+
sinput   long              InpMagic       =  1234567;                // Experts magic number
input    ENUM_OPENED_MODE  InpModeOpen    =  OPENED_MODE_ALL_SWING;  // Mode of opening positions
input    ENUM_INPUT_YES_NO InpEnableBuy   =  INPUT_YES;              // Long positions is enabled
input    ENUM_INPUT_YES_NO InpEnableSell  =  INPUT_YES;              // Short positions is enabled
input    ENUM_INPUT_YES_NO InpReverse     =  INPUT_NO;               // Reverse trade
input    double            InpVolume      =  0.1;                    // Lots
input    uint              InpStopLoss    =  0;                      // Stop loss in points
input    uint              InpTakeProfit  =  0;                      // Take profit in points
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
CArrayObj      list_lines;          // Список объектов-линий
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
   SDatas      Sell;                // Данные позиций Sell
  }
Data;
//+------------------------------------------------------------------+
//| Структура данных индикатора                                      |
//+------------------------------------------------------------------+
struct SDataInd
  {
   double      line[];              // Буфер линии
   double      point[];             // Буфер точек
   double      Line0(void)    const { return line[0];  }
   double      Line1(void)    const { return line[1];  }
   double      Point0(void)   const { return point[0]; }
   double      Point1(void)   const { return point[1]; }
  }
DataInd;
//+------------------------------------------------------------------+
//| Глобальные переменные                                            |
//+------------------------------------------------------------------+
double         lot;                 // Объём позиции
string         symb;                // Символ
int            prev_total;          // Количество позиций на прошлой проверке
int            size_spread;         // Множитель спреда
uint           num_attempts;        // Количество попыток получения точного окружения
int            sleep;               // Ожидание обновления в секундах
int            handle_ind;          // Хэндл Serial_MA
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
   prev_total=0;
   last_time=0;
//--- Хэндл Serial_MA
   ResetLastError();
   handle_ind=iCustom(symb,PERIOD_CURRENT,"SerialMA");
   if(handle_ind==INVALID_HANDLE)
     {
      Print("The 'Serial_MA' object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- Инициализация массивов буферов
   ResetLastError();
   if(ArrayResize(DataInd.line,2,2)==WRONG_VALUE)
     {
      Print("Error setting the first buffer size ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   if(ArrayResize(DataInd.point,2,2)==WRONG_VALUE)
     {
      Print("Error setting the second buffer size ",GetLastError());
      return INIT_FAILED;
     }
   ArraySetAsSeries(DataInd.line,true);
   ArraySetAsSeries(DataInd.point,true);
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
   if(!RefreshRates() || Point()==0) return;
//--- Заполнение списков тикетов позиций
   int positions_total=PositionsTotal();
   if(prev_total!=positions_total)
     {
      if(FillingListTickets(num_attempts))
         prev_total=positions_total;
      else return;
     }
//--- Проверка нового бара
   if(Time(0)!=last_time)
     {
   //--- Заполнение данных индикатора и проверка получения цены Close
      if(!FillingDataInd(1) || Close(1)==0)
         return;
   //--- Получение сигналов от индикатора
      bool open_long=false;
      bool open_short=false;
      if(fabs(MALine(1)-MAPoint(1))<Point())
        {
         if(Close(1)>MALine(0))
           {
            if(!InpReverse)
               open_long=(InpEnableBuy ? true : false);
            else
               open_short=(InpEnableSell ? true : false);
           }
         if(Close(1)<MALine(0))
           {
            if(!InpReverse)
               open_short=(InpEnableSell ? true : false);
            else
               open_long=(InpEnableBuy ? true : false);
           }
        }
   //--- Текущее количество позиций
      int num_b=NumberBuy();
      int num_s=NumberSell();
   //--- Открытие позиций по сигналам
      if(open_long && (InpModeOpen==OPENED_MODE_ALL_SWING || (InpModeOpen==OPENED_MODE_ONE_SWING && num_b==0)))
        {
         if(num_s>0)
           {
            bool res=CloseSell();
            if(!FillingListTickets(num_attempts) || !res)
               return;
           }
         if(OpenPosition(POSITION_TYPE_BUY,CorrectLots(lot),""))
           {
            if(!FillingListTickets(num_attempts))
               return;
           }
         else return;
        }
      if(open_short && (InpModeOpen==OPENED_MODE_ALL_SWING || (InpModeOpen==OPENED_MODE_ONE_SWING && num_s==0)))
        {
         if(num_b>0)
           {
            bool res=CloseBuy();
            if(!FillingListTickets(num_attempts) || !res)
               return;
           }
         if(OpenPosition(POSITION_TYPE_SELL,CorrectLots(lot),""))
           {
            if(!FillingListTickets(num_attempts))
               return;
           }
         else return;
        }
   //--- Все действия на новом баре выполнены успешно
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
//| Заполнение данных индикатора                                     |
//+------------------------------------------------------------------+
bool FillingDataInd(const int shift)
  {
   int count=2,copied=0;
   ZeroMemory(DataInd);
   copied=CopyBuffer(handle_ind,0,shift,count,DataInd.line);
   if(copied!=count) return false;
   copied=CopyBuffer(handle_ind,1,shift,count,DataInd.point);
   if(copied!=count) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Получение данных буфера линии по индексу 0 или 1                 |
//+------------------------------------------------------------------+
double MALine(const int index)
  {
   return(index==0 ? DataInd.Line0() : DataInd.Line1());
  }
//+------------------------------------------------------------------+
//| Получение данных буфера точек по индексу 0 или 1                 |
//+------------------------------------------------------------------+
double MAPoint(const int index)
  {
   return(index==0 ? DataInd.Point0() : DataInd.Point1());
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
   double total_volume=(position_type==POSITION_TYPE_BUY ? Data.Buy.total_volume : Data.Sell.total_volume);
   return(total_volume+volume<=symbol_info.LotsLimit());
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const ENUM_POSITION_TYPE position_type,const int stop_loss)
  {
   if(stop_loss==0) return 0;
   double pt=symbol_info.Point();
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symb,SYMBOL_ASK) : SymbolInfoDouble(symb,SYMBOL_BID));
   int lv=StopLevel(),dg=symbol_info.Digits();
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(fmin(price-lv*pt,price-stop_loss*pt),dg) :
    NormalizeDouble(fmax(price+lv*pt,price+stop_loss*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const ENUM_POSITION_TYPE position_type,const int take_profit)
  {
   if(take_profit==0) return 0;
   double pt=symbol_info.Point();
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symb,SYMBOL_ASK) : SymbolInfoDouble(symb,SYMBOL_BID));
   int lv=StopLevel(),dg=symbol_info.Digits();
   return
   (position_type==POSITION_TYPE_BUY ?
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
//| Заполняет массивы тикетов позиций                                |
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
//| Открытие позиции                                                 |
//+------------------------------------------------------------------+
bool OpenPosition(const ENUM_POSITION_TYPE type,const double volume,const string comment)
  {
   double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(type,InpStopLoss));
   double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(type,InpTakeProfit));
   double ll=trade.CheckVolume(symb,volume,(type==POSITION_TYPE_BUY ? SymbolInfoDouble(symb,SYMBOL_ASK) : SymbolInfoDouble(symb,SYMBOL_BID)),(ENUM_ORDER_TYPE)type);
   if(ll>0 && CheckLotForLimitAccount(type,ll))
     {
      if(RefreshRates())
        {
         if(type==POSITION_TYPE_BUY)
           {
            if(trade.Buy(ll,symb,symbol_info.Ask(),sl,tp,comment))
               return true;
           }
         else
           {
            if(trade.Sell(ll,symb,symbol_info.Bid(),sl,tp,comment))
               return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
