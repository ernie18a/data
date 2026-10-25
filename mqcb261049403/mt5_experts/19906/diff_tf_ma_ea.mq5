//+------------------------------------------------------------------+
//|                                                Diff_TF_MA_EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.01"
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
sinput   long              InpMagic       =  1234567;    // Experts magic nember
input    uint              InpPeriodMA    =  10;         // Period of MA
input    ENUM_TIMEFRAMES   InpTimeframeMA =  PERIOD_H4;  // Timeframe of MA
sinput   ENUM_INPUT_YES_NO InpReverce     =  INPUT_NO;   // Reverse trade
input    double            InpVolume      =  0.1;        // Lots
input    uint              InpStopLoss    =  0;          // Stop loss in points
input    uint              InpTakeProfit  =  0;          // Take profit in points
sinput   ulong             InpDeviation   =  10;         // Slippage of price
sinput   uint              InpSizeSpread  =  2;          // Multiplier spread for stops
//--- includes
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//--- global variables
CSymbolInfo                symbol_info;                  // Объект-CSymbolInfo
CAccountInfo               account_info;                 // Объект-CAccountInfo
CTerminalInfo              terminal_info;                // Объект-CTerminalInfo
CTrade                     trade;                        // Объект-CTrade
CArrayLong                 list_tickets_buy;             // Список тикетов длинных позиций
CArrayLong                 list_tickets_sell;            // Список тикетов коротких позиций
double                     array_data_ma_senior[];       // Данные буфера МА старшего таймфрейма
double                     array_data_ma_current[];      // Данные буфера МА текущего таймфрейма
double                     total_volume_buy;             // Общий объём длинных позиций
double                     total_volume_sell;            // Общий объём коротких позиций
double                     lot;                          // Объём позиции
string                     symb;                         // Символ
datetime                   last_time;                    // Время последнего бара
int                        prev_total;                   // Количество позиций на прошлой проверке
int                        size_spread;                  // Множитель спреда
int                        period_ma1;                   // Период старшей MA
int                        period_ma2;                   // Период младшей MA рассчитанный от InpTimeframeMA
int                        handle_ma;                    // Хэндл МА текущего таймфрейма
int                        handle_ma_tf;                 // Хэндл МА старшего таймфрейма
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Установка торговых параметров
   if(!SetTradeParameters())
      return INIT_FAILED;
//--- Установка значений переменных
   period_ma1=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   int v1=PeriodSeconds(InpTimeframeMA)/60;
   int v2=PeriodSeconds(Period())/60;
   int v3=period_ma1*v1/v2;
   period_ma2=(v3>0 ? v3 : 1);
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   symb=symbol_info.Name();
   last_time=0;
   prev_total=0;
//--- Установка индексации массивов данных МА как таймсерий
   ArraySetAsSeries(array_data_ma_current,true);
   ArraySetAsSeries(array_data_ma_senior,true);
//--- Создание и проверка хэндла MA старшего таймфрейма
   handle_ma_tf=iMA(NULL,InpTimeframeMA,period_ma1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma_tf==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma1,",",NameTimeframe(InpTimeframeMA),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- Создание и проверка хэндла MA текущего таймфрейма
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma2,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma2,",",NameTimeframe(PERIOD_CURRENT),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Торговля на новом баре
   if(last_time!=Time(0))
     {
      //--- Заполнение массивов данными МА
      if(!FillingArrayMACurrent())
         return;
      if(!FillingArrayMASenior())
         return;
      //--- Получение данных от МА
      double ma_tf1=MASenior(1); // МА старшего таймфрейма на первом баре
      double ma_tf2=MASenior(2); // МА старшего таймфрейма на втором баре
      double ma1=MACurrent(1);   // МА текущего таймфрейма на первом баре
      double ma2=MACurrent(2);   // МА текущего таймфрейма на втором баре
      //--- Проверка сигналов от МА
      bool open_long=false;
      bool open_short=false;
      if(ma_tf2<ma2 && ma_tf1>ma1)
        {
         if(!InpReverce)
            open_long=true;
         else
            open_short=true;
        }
      if(ma_tf2>ma2 && ma_tf1<ma1)
        {
         if(!InpReverce)
            open_short=true;
         else
            open_long=true;
        }
      //--- Открытие позиций по сигналам
      if(open_long)
        {
         if(num_s>0) CloseSell();
         if(num_b==0)
           {
            double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(ORDER_TYPE_BUY,InpStopLoss));
            double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(ORDER_TYPE_BUY,InpTakeProfit));
            double ll=trade.CheckVolume(symb,lot,symbol_info.Ask(),ORDER_TYPE_BUY);
            if(ll>0 && CheckLotForLimitAccount(POSITION_TYPE_BUY,ll))
              {
               if(trade.Buy(ll,symb,0,sl,tp))
                  FillingListTickets();
              }
           }
        }
      if(open_short)
        {
         if(num_b>0) CloseBuy();
         if(num_s==0)
           {
            double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(ORDER_TYPE_SELL,InpStopLoss));
            double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(ORDER_TYPE_SELL,InpTakeProfit));
            double ll=trade.CheckVolume(symb,lot,symbol_info.Ask(),ORDER_TYPE_SELL);
            if(ll>0 && CheckLotForLimitAccount(POSITION_TYPE_SELL,ll))
              {
               if(trade.Sell(ll,symb,0,sl,tp))
                  FillingListTickets();
              }
           }
        }
      //--- сохранение времени на следующую проверку
      last_time=Time(0);
     }
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
//| Заполняет массив данных МА со старшего таймфрейма                |
//+------------------------------------------------------------------+
bool FillingArrayMASenior(void)
  {
   int copied=0,count=Bars(symb,InpTimeframeMA);
   copied=CopyBuffer(handle_ma_tf,0,0,count,array_data_ma_senior);
   if(copied!=count) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Заполняет массив данных МА с текущего таймфрейма                 |
//+------------------------------------------------------------------+
bool FillingArrayMACurrent(void)
  {
   int copied=0,count=Bars(symb,PERIOD_CURRENT);
   copied=CopyBuffer(handle_ma,0,0,count,array_data_ma_current);
   if(copied!=count) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает данные МА старшего таймфрейма на заданном баре        |
//+------------------------------------------------------------------+
double MASenior(const int shift)
  {
   return array_data_ma_senior[shift];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACurrent(const int shift)
  {
   return array_data_ma_current[shift];
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
   double total_volume=(position_type==POSITION_TYPE_BUY ? total_volume_buy : total_volume_sell);
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
   int total=list_tickets_buy.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=list_tickets_buy.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
  }
//+------------------------------------------------------------------+
//| Закрывает позиции Sell                                           |
//+------------------------------------------------------------------+
void CloseSell(void)
  {
   int total=list_tickets_sell.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=list_tickets_sell.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
  }
//+------------------------------------------------------------------+
//| Заполняет массивы тикетов позиций                                |
//+------------------------------------------------------------------+
void FillingListTickets(void)
  {
   list_tickets_buy.Clear();
   list_tickets_sell.Clear();
   total_volume_buy=0;
   total_volume_sell=0;
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
         list_tickets_buy.Add(ticket);
         total_volume_buy+=volume;
        }
      else if(type==POSITION_TYPE_SELL)
        {
         list_tickets_sell.Add(ticket);
         total_volume_sell+=volume;
        }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Buy                                |
//+------------------------------------------------------------------+
int NumberBuy(void)
  {
   return list_tickets_buy.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Sell                               |
//+------------------------------------------------------------------+
int NumberSell(void)
  {
   return list_tickets_sell.Total();
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
//| Returns the name timeframe                                       |
//+------------------------------------------------------------------+
string NameTimeframe(int timeframe=PERIOD_CURRENT)
  {
   if(timeframe==PERIOD_CURRENT) timeframe=Period();
   switch(timeframe)
     {
      case 1      : return "M1";
      case 2      : return "M2";
      case 3      : return "M3";
      case 4      : return "M4";
      case 5      : return "M5";
      case 6      : return "M6";
      case 10     : return "M10";
      case 12     : return "M12";
      case 15     : return "M15";
      case 20     : return "M20";
      case 30     : return "M30";
      case 16385  : return "H1";
      case 16386  : return "H2";
      case 16387  : return "H3";
      case 16388  : return "H4";
      case 16390  : return "H6";
      case 16392  : return "H8";
      case 16396  : return "H12";
      case 16408  : return "D1";
      case 32769  : return "W1";
      case 49153  : return "MN1";
      default     : return (string)(int)Period();
     }
  }
//+------------------------------------------------------------------+
