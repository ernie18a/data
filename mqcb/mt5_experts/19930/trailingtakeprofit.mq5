//+------------------------------------------------------------------+
//|                                           TrailingTakeProfit.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,                   // Yes
   INPUT_NO    =  0                    // No
  };
enum ENUM_INPUT_TYPE
  {
   TYPE_ALL    =  WRONG_VALUE,         // Any position
   TYPE_BUY    =  POSITION_TYPE_BUY,   // Buy position
   TYPE_SELL   =  POSITION_TYPE_SELL   // Sell position
  };
//--- input parameters
sinput   uint              InpTakeProfit     =  100;        // Take Profit size in points
sinput   ENUM_INPUT_TYPE   InpPositionType   =  TYPE_ALL;   // Positions type
sinput   string            InpTrailingSymbol =  "";         // Positions symbol ("" - any symbol)
sinput   long              InpTrailingMagic  =  0;          // Positions magic number (0 - any magic)
sinput   ulong             InpTrailingTicket =  0;          // Position ticket (0 - all tickets)
sinput   uint              InpTrailingStep   =  10;         // Trailing step
sinput   ENUM_INPUT_YES_NO InpTrailingLoss   =  INPUT_NO;   // Trailing in the unprofitable zone
sinput   int               InpBreakevenPT    =  6;          // Breakeven in points
sinput   uint              InpSizeSpread     =  2;          // Spread multiplier
//--- global variables
MqlTradeRequest   g_request;     // Структура торгового запроса (для проверки в тестере)
MqlTradeResult    g_result;      // Структура результата торгового запроса (для проверки в тестере)
int               size_spread;   // Множитель спреда
datetime          prev_time;     // Предыдущее время открытия бара
//--- includes
#include <Trade\Trade.mqh>       // Торговый класс (для проверки в тестере)
//--- objects
CTrade   trade;                  // Объект-CTrade (для проверки в тестере)
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Проверка типа счёта
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
     {
      Print("Netting-account. EA should work on a hedge account.");
      return INIT_FAILED;
     }
//--- Установка значений переменных
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   prev_time=0;
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
//--- 
   if(MQLInfoInteger(MQL_TESTER))
     {
      static ulong mn=0;
      if(prev_time!=Time(0))
        {
         mn++;
         trade.SetExpertMagicNumber(mn);
         if(InpPositionType==TYPE_ALL || InpPositionType==TYPE_BUY) 
            trade.Buy(0.1);
         if(InpPositionType==TYPE_ALL || InpPositionType==TYPE_SELL) 
            trade.Sell(0.1);
         prev_time=Time(0);
        }
     }
   Trailing();
  }
//+------------------------------------------------------------------+
//| Функция трейлинга                                                |
//+------------------------------------------------------------------+
void Trailing(void)
  {
   int   total=PositionsTotal();
   for(int i=total; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      string symbol_name=PositionGetString(POSITION_SYMBOL);
      ulong  magic_number=(ulong)PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(InpPositionType>WRONG_VALUE && type!=(ENUM_POSITION_TYPE)InpPositionType) continue;
      if(!Condition(symbol_name,magic_number,ticket)) continue;
      double point=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
      if(point==0) continue;
      int    digits=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
      double op_position=PositionGetDouble(POSITION_PRICE_OPEN);
      double tp_position=PositionGetDouble(POSITION_TP);
      double sl_position=PositionGetDouble(POSITION_SL);
      double take_profit=0;
      double step=InpTrailingStep*point;
      double price=0,breakeven=0;
   //--- Покупки
      if(type==POSITION_TYPE_BUY)
        {
         if(tp_position==0)
           {
            take_profit=CorrectTakeProfit(symbol_name,POSITION_TYPE_BUY,op_position+InpTakeProfit*point,op_position);
            if(!PositionModifyByTicket(symbol_name,magic_number,ticket,sl_position,take_profit))
               Print("Position Buy #",(string)ticket," modification error: ",(string)g_result.retcode," -> ",g_result.comment);
           }
         else
           {
            breakeven=NormalizeDouble(op_position+InpBreakevenPT*point,digits);
            price=SymbolInfoDouble(symbol_name,SYMBOL_ASK);
            take_profit=NormalizeDouble(price+InpTakeProfit*point,digits);
            if(!InpTrailingLoss && NormalizeDouble(take_profit-breakeven,digits)<0) take_profit=breakeven;
            if(take_profit<tp_position-step && CheckCorrectTakeProfit(symbol_name,POSITION_TYPE_BUY,take_profit))
              {
               if(!PositionModifyByTicket(symbol_name,magic_number,ticket,sl_position,take_profit))
                  Print("Position Buy #",(string)ticket," modification error: ",(string)g_result.retcode," -> ",g_result.comment);
              }
           }
        }
   //--- Продажи
      else
        {
         if(tp_position==0)
           {
            take_profit=CorrectTakeProfit(symbol_name,POSITION_TYPE_SELL,op_position-InpTakeProfit*point,op_position);
            if(!PositionModifyByTicket(symbol_name,magic_number,ticket,sl_position,take_profit))
               Print("Position Sell #",(string)ticket," modification error: ",(string)g_result.retcode," -> ",g_result.comment);
           }
         else
           {
            breakeven=NormalizeDouble(op_position-InpBreakevenPT*point,digits);
            price=SymbolInfoDouble(symbol_name,SYMBOL_BID);
            take_profit=price-InpTakeProfit*point;
            if(!InpTrailingLoss && NormalizeDouble(breakeven-take_profit,digits)<0) take_profit=breakeven;
            if(take_profit>tp_position+step && CheckCorrectTakeProfit(symbol_name,POSITION_TYPE_SELL,take_profit))
              {
               if(!PositionModifyByTicket(symbol_name,magic_number,ticket,sl_position,take_profit))
                  Print("Position Sell #",(string)ticket," modification error: ",(string)g_result.retcode," -> ",g_result.comment);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверка истинности условий по символу, магику и тикету          |
//+------------------------------------------------------------------+
bool Condition(const string symbol_name,const ulong magic_number,const long ticket)
  {
   return
   (
    (symbol_name==InpTrailingSymbol || InpTrailingSymbol=="") && 
    (magic_number==InpTrailingMagic || InpTrailingMagic==0) && 
    (ticket==InpTrailingTicket || InpTrailingTicket==0)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const int take_profit)
  {
   if(take_profit==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(fmax(price+lv*pt,price+take_profit*pt),dg) :
    NormalizeDouble(fmin(price-lv*pt,price-take_profit*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Прверяет TakeProfit на корректность относительно StopLevel       |
//+------------------------------------------------------------------+
bool CheckCorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double take_profit)
  {
   if(take_profit==0) return true;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (
    position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(take_profit-price+lv*pt,dg)>0 :
    NormalizeDouble(take_profit-price-lv*pt,dg)<0
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
   double price=(open_price>0 ? open_price : position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmax(price+lv*pt,take_profit),dg) :
    NormalizeDouble(::fmin(price-lv*pt,take_profit),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает рассчитанный StopLevel                                |
//+------------------------------------------------------------------+
int StopLevel(const string symbol_name)
  {
   int sp=(int)SymbolInfoInteger(symbol_name,SYMBOL_SPREAD);
   int lv=(int)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_STOPS_LEVEL);
   return(lv==0 ? sp*size_spread : lv);
  }
//+------------------------------------------------------------------+
//| Модифицирует выбранную по тикету позицию                         |
//+------------------------------------------------------------------+
bool PositionModifyByTicket(const string symbol_name,const ulong magic_number,const ulong ticket,const double sl,const double tp)
  {
//--- check stopped
   if(IsStopped())
      return(false);
//--- clean
   ZeroMemory(g_request);
   ZeroMemory(g_result);
//--- setting request
   g_request.action  =TRADE_ACTION_SLTP;
   g_request.position=ticket;
   g_request.symbol  =symbol_name;
   g_request.magic   =magic_number;
   g_request.sl      =sl;
   g_request.tp      =tp;
//--- action and return the result
   return(OrderSend(g_request,g_result));
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия заданного бара                         |
//+------------------------------------------------------------------+
datetime Time(int shift)
  {
   datetime array[];
   if(CopyTime(Symbol(),PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
