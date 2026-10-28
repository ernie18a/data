//+------------------------------------------------------------------+
//|                              Percentage_Crossover_Channel_EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
sinput   long                 InpMagic       =  1234567;       // Experts magic number
input double                  InpPercent     =  50.0;          // Percent
input    ENUM_APPLIED_PRICE   InpAppliedPrice=  PRICE_CLOSE;   // Applied price
sinput   ENUM_INPUT_YES_NO    InpCrossMiddle =  INPUT_NO;      // Trade at the intersection of the middle line
sinput   ENUM_INPUT_YES_NO    InpReverce     =  INPUT_NO;      // Reverse trade
input    double               InpVolume      =  0.1;           // Lots
input    uint                 InpStopLoss    =  0;             // Stop loss in points
input    uint                 InpTakeProfit  =  0;             // Take profit in points
sinput   ulong                InpDeviation   =  10;            // Slippage of price
sinput   uint                 InpSizeSpread  =  2;             // Multiplier spread for stops
//--- includes
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//--- global variables
struct SIndicator
  {
   double      m_buffer_up[];       // Буфер 0 - верхняя линия индикатора
   double      m_buffer_md[];       // Буфер 1 - средняя линия индикатора
   double      m_buffer_dn[];       // Буфер 2 - нижняя линия индикатора
  }
SDataInd;
//---
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
CAccountInfo   account_info;        // Объект-CAccountInfo
CTerminalInfo  terminal_info;       // Объект-CTerminalInfo
CTrade         trade;               // Объект-CTrade
CArrayLong     list_tickets_buy;    // Список тикетов длинных позиций
CArrayLong     list_tickets_sell;   // Список тикетов коротких позиций
double         total_volume_buy;    // Общий объём длинных позиций
double         total_volume_sell;   // Общий объём коротких позиций
double         lot;                 // Объём позиции
string         symb;                // Символ
datetime       last_time;           // Время последнего бара
int            prev_total;          // Количество позиций на прошлой проверке
int            size_spread;         // Множитель спреда
int            handle_ind;          // Хэндл индикатора Percentage_Crossover_Channel
double         percent_ind;         // Параметр "Percent" индикатора
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Установка торговых параметров
   if(!SetTradeParameters())
      return INIT_FAILED;
//--- Установка значений переменных
   percent_ind=(InpPercent<=0 ? 0.1 : InpPercent);
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   symb=symbol_info.Name();
   last_time=0;
   prev_total=0;
//--- Инициализация массивов буферов индикатора
   ArraySetAsSeries(SDataInd.m_buffer_up,true);
   ArraySetAsSeries(SDataInd.m_buffer_md,true);
   ArraySetAsSeries(SDataInd.m_buffer_dn,true);
   ArrayResize(SDataInd.m_buffer_up,2);
   ArrayResize(SDataInd.m_buffer_md,2);
   ArrayResize(SDataInd.m_buffer_dn,2);
   ArrayInitialize(SDataInd.m_buffer_up,0);
   ArrayInitialize(SDataInd.m_buffer_md,0);
   ArrayInitialize(SDataInd.m_buffer_dn,0);
//--- Создание и проверка хэндла индикатора Percentage_Crossover_Channel
   handle_ind=iCustom(symb,PERIOD_CURRENT,"Percentage_Crossover_Channel",percent_ind,InpAppliedPrice);
   if(handle_ind==INVALID_HANDLE)
     {
      Print("The Percentage_Crossover_Channel(",DoubleToString(percent_ind,2),") object was not created: Error ",GetLastError());
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
      //--- Заполнение массивов буферов индикатора
      if(!FillingBuffersArrays())
         return;
   //--- Получение данных от индикатора
      double line_up1=LineUP(1);
      double line_up2=LineUP(2);
      double line_md1=LineMD(1);
      double line_md2=LineMD(2);
      double line_dn1=LineDN(1);
      double line_dn2=LineDN(2);
   //--- Проверка сигналов от индикатора
      bool open_long=false;
      bool open_short=false;
   //--- Если сигналы по пересечению средней линии
      if(InpCrossMiddle)
        {
         if(Close(2)>line_md2 && Close(1)<line_md1)
           {
            if(!InpReverce)
               open_long=true;
            else
               open_short=true;
           }
         if(Close(2)<line_md2 && Close(1)>line_md1)
           {
            if(!InpReverce)
               open_short=true;
            else
               open_long=true;
           }
        }
   //--- Если сигналы по пересечению границ канала
      else
        {
         if(Low(2)>line_dn2 && Low(1)<=line_dn1)
           {
            if(!InpReverce)
               open_long=true;
            else
               open_short=true;
           }
         if(High(2)<line_up2 && High(1)>=line_up1)
           {
            if(!InpReverce)
               open_short=true;
            else
               open_long=true;
           }
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
//| Возвращает данные буфера индикатора из массива                   |
//+------------------------------------------------------------------+
double GetBuffer(const int buffer,const int shift)
  {
   return(buffer==0 ? SDataInd.m_buffer_up[shift-1] : buffer==1 ? SDataInd.m_buffer_md[shift-1] : SDataInd.m_buffer_dn[shift-1]);
  }
//+------------------------------------------------------------------+
//| Возвращает данные верхнего буфера по индексу значения            |
//+------------------------------------------------------------------+
double LineUP(const int shift)
  {
   return GetBuffer(0,shift);
  }
//+------------------------------------------------------------------+
//| Возвращает данные среднего буфера по индексу значения            |
//+------------------------------------------------------------------+
double LineMD(const int shift)
  {
   return GetBuffer(1,shift);
  }
//+------------------------------------------------------------------+
//| Возвращает данные нижнего буфера по индексу значения             |
//+------------------------------------------------------------------+
double LineDN(const int shift)
  {
   return GetBuffer(2,shift);
  }
//+------------------------------------------------------------------+
//| Заполняет массивы данных буферов индикатора                      |
//+------------------------------------------------------------------+
bool FillingBuffersArrays(void)
  {
   int copied=0,count=2;
   copied=CopyBuffer(handle_ind,0,1,count,SDataInd.m_buffer_up);
   if(copied!=count) return false;
   copied=CopyBuffer(handle_ind,1,1,count,SDataInd.m_buffer_md);
   if(copied!=count) return false;
   copied=CopyBuffer(handle_ind,2,1,count,SDataInd.m_buffer_dn);
   if(copied!=count) return false;
   return true;
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
//| Возвращает цену закрытия заданного бара                          |
//+------------------------------------------------------------------+
double Close(int shift)
  {
   double array[];
   if(CopyClose(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
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
   FillingListTickets();
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
   FillingListTickets();
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
