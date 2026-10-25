//+------------------------------------------------------------------+
//|                                            Cross_Line_Trader.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- enums
enum ENUM_OPENED_MODE
  {
   OPENED_TYPE_DESCR,      // From line description
   OPENED_TYPE_BUY,        // Long position
   OPENED_TYPE_SELL        // Short position
  };
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,       // Yes
   INPUT_NO    =  0        // No
  };
//--- input parameters
input    ENUM_OPENED_MODE  InpModeOpen    =  OPENED_TYPE_DESCR;// Direction of opening positions
input    string            InpBuyDescr    =  "Buy";            // Description for Buy position
input    string            InpSellDescr   =  "Sell";           // Description for Sell position
input    ENUM_LINE_STYLE   InpInactiveLS  =  STYLE_DOT;        // Inactive Line Style
sinput   long              InpMagic       =  1234567;          // Experts magic number
input    double            InpVolume      =  0.1;              // Lots
input    uint              InpStopLoss    =  0;                // Stop loss in points
input    uint              InpTakeProfit  =  0;                // Take profit in points
sinput   ulong             InpDeviation   =  10;               // Slippage of price
sinput   uint              InpSizeSpread  =  2;                // Multiplier spread for stops
sinput   uint              InpSleep       =  1;                // Waiting for environment update (in seconds)
sinput   uint              InpNumAttempt  =  3;                // Number of attempts to get the state of the environment
sinput   ENUM_INPUT_YES_NO InpPrintToLog  =  INPUT_NO;         // Log messages
//--- includes
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
#include "Objects.mqh"
//--- classes
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
   CArrayLong        list_tickets;  // список тикетоа
   double            total_volume;  // Общий объём
  };
//+------------------------------------------------------------------+
//| Структура данных позиций по типам                                |
//+------------------------------------------------------------------+
struct SDataPositions
  {
   SDatas            Buy;           // Данные позиций Buy
   SDatas            Sell;          // Данные позиций Sell
  }
Data;
//+------------------------------------------------------------------+
//| Глобальные переменные                                            |
//+------------------------------------------------------------------+
double         lot;                 // Объём позиции
string         symb;                // Символ
string         descr_buy;           // Описание в линии для Buy-позиций
string         descr_sell;          // Описание в линии для Sell-позиций
long           chart_idn;           // Идентификатор графика
int            sub_wnd;             // Идентификатор подокна графика
int            prev_total;          // Количество позиций на прошлой проверке
int            size_spread;         // Множитель спреда
uint           num_attempts;        // Количество попыток получения точного окружения
int            sleep;               // Ожидание обновления в секундах
bool           need_update;         // Флагнеобходимости обновления
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
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   symb=symbol_info.Name();
   prev_total=0;
   need_update=false;
   chart_idn=ChartID();
   sub_wnd=0;
   descr_buy=InpBuyDescr;
   descr_sell=InpSellDescr;
   num_attempts=int(InpNumAttempt<1 ? 1 : InpNumAttempt);
   last_time=0;
/* Если нужно преобразовать символы описания в строчные
   ResetLastError();
   if(StringToLower(descr_buy))
     {
      Print("Failed to convert '",InpBuyDescr,"' characters to lowercase. Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   if(StringToLower(descr_sell))
     {
      Print("Failed to convert '",InpSellDescr,"' characters to lowercase. Error ",GetLastError());
      return INIT_FAILED;
     }
   */
//--- Установка параметров графика
   ResetLastError();
   if(!ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,true))
     {
      Print("Failed to set the property OBJECT_CREATE-event of the chart, error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   if(!ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,true))
     {
      Print("Failed to set the property OBJECT_DELETE-event of the chart, error ",GetLastError());
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
      if(FillingListTickets(positions_total,num_attempts))
         prev_total=positions_total;
      else return;
     }
//--- Обновление списка объектов
   RefreshObjects();
//--- Проверка нового бара
   if(Time(0)!=last_time || need_update)
     {
      RefreshObjects();
      //--- Текущее количество позиций
      int num_b=NumberBuy();
      int num_s=NumberSell();
      //--- Поиск пересечений
      bool open_long=false;
      bool open_short=false;
      int total=list_lines.Total();
      if(total>0)
        {
         for(int i=total-1; i>WRONG_VALUE; i--)
           {
            CLineObj *line=list_lines.At(i);
            if(line==NULL)       continue;
            if(!line.IsActive()) continue;
            ENUM_POSITION_TYPE position_type=TypePosition(line);
            ENUM_OBJECT type=line.TypeLine();
            double cross=line.PriceValueForIntersection(line.Ray() ? 0 : line.BarRight());
            //--- Вертикальная линия
            if(type==OBJ_VLINE && line.BarRight()==1)
              {
               if(InpPrintToLog)
                  Print("Crossing ",line.DescriptTypeLine());
               if(OpenPosition(position_type,CorrectLots(lot),line.DescriptTypeLine()))
                  line.Style(InpInactiveLS);
              }
            else
              {
               double open0=Open(0),open1=Open(1);
               if(open0==0 || open1==0) continue;
               //--- Трендовая линия и трендовая по углу
               if(type==OBJ_TREND || type==OBJ_TRENDBYANGLE)
                 {
                  if(!line.Ray() && line.BarRight()>1)
                    {
                     line.Style(InpInactiveLS);
                     continue;
                    }
                  double price1=line.PriceValueForIntersection(1);
                  if(position_type==POSITION_TYPE_BUY && open1<=price1 && open0>cross)
                    {
                     if(InpPrintToLog)
                        Print("The ",line.DescriptTypeLine()," is crossed upwards");
                     if(OpenPosition(position_type,CorrectLots(lot),line.DescriptTypeLine()))
                        line.Style(InpInactiveLS);
                    }
                  if(position_type==POSITION_TYPE_SELL && open1>=price1 && open0<cross)
                    {
                     if(InpPrintToLog)
                        Print("The ",line.DescriptTypeLine()," is crossed downwards");
                     if(OpenPosition(position_type,CorrectLots(lot),line.DescriptTypeLine()))
                        line.Style(InpInactiveLS);
                    }
                 }
               //--- Горизонтальная линия
               else
                 {
                  if(position_type==POSITION_TYPE_BUY && open1<=cross && open0>cross)
                    {
                     if(InpPrintToLog)
                        Print("The ",line.DescriptTypeLine()," is crossed upwards");
                     if(OpenPosition(position_type,CorrectLots(lot),line.DescriptTypeLine()))
                        line.Style(InpInactiveLS);
                    }
                  if(position_type==POSITION_TYPE_SELL && open1>=cross && open0<cross)
                    {
                     if(InpPrintToLog)
                        Print("The ",line.DescriptTypeLine()," is crossed downwards");
                     if(OpenPosition(position_type,CorrectLots(lot),line.DescriptTypeLine()))
                        line.Style(InpInactiveLS);
                    }
                 }
              }
           }
        }
      //--- Все операции на новом баре выполнены
      last_time=Time(0);
      if(need_update) need_update=false;
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE || id==CHARTEVENT_OBJECT_DRAG || id==CHARTEVENT_OBJECT_CHANGE)
     {
      RefreshObjects();
      need_update=true;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает требуемый тип позиции                                 |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE TypePosition(CLineObj &line)
  {
   return
   (
    InpModeOpen==OPENED_TYPE_DESCR ? (line.Description()==descr_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL) :
    InpModeOpen==OPENED_TYPE_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL
    );
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
//| Обновление списка объектов-линий                                 |
//+------------------------------------------------------------------+
uint RefreshObjects(void)
  {
   list_lines.Clear();
   int total=ObjectsTotal(chart_idn,sub_wnd);
   for(int i=total; i>WRONG_VALUE; i--)
     {
      string name=::ObjectName(chart_idn,i,sub_wnd);
      ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(chart_idn,name,OBJPROP_TYPE);
      if((type!=OBJ_VLINE && type!=OBJ_HLINE && type!=OBJ_TREND && type!=OBJ_TRENDBYANGLE) || name=="") continue;
      ENUM_LINE_STYLE style=(ENUM_LINE_STYLE)ObjectGetInteger(chart_idn,name,OBJPROP_STYLE);
      if(style==InpInactiveLS) continue;
      string   descr=ObjectGetString(chart_idn,name,OBJPROP_TEXT);
      if(InpModeOpen==OPENED_TYPE_DESCR && descr!=descr_buy && descr!=descr_sell) continue;
      datetime t0=(datetime)ObjectGetInteger(chart_idn,name,OBJPROP_TIME,0);
      datetime t1=(datetime)ObjectGetInteger(chart_idn,name,OBJPROP_TIME,1);
      double   p0=ObjectGetDouble(chart_idn,name,OBJPROP_PRICE,0);
      double   p1=ObjectGetDouble(chart_idn,name,OBJPROP_PRICE,1);
      bool     ray=ObjectGetInteger(chart_idn,name,OBJPROP_RAY_RIGHT);
      CLineObj *line=new CLineObj(chart_idn,name,type);
      if(line==NULL) continue;
      line.SetParameters(t0,p0,t1,p1,ray,descr,style,InpInactiveLS);
      list_lines.Add(line);
     }
   return (uint)list_lines.Total();
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
//| Возвращает цену открытия заданного бара                          |
//+------------------------------------------------------------------+
double Open(int shift)
  {
   double array[];
   if(CopyOpen(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
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
bool FillingListTickets(const int positions_total,const uint number_of_attempts)
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
   int total=positions_total;
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
