//+------------------------------------------------------------------+
//|                       Price Impulse(barabashkakvn's edition).mq5 |
//|                                                            runik |
//|                                                  ngb2008@mail.ru |
//+------------------------------------------------------------------+
#property copyright "runik"
#property link      "ngb2008@mail.ru"
#property version   "1.000"
//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| ENUM_COPY_TICKS                                                  |
//+------------------------------------------------------------------+
enum  ENUM_COPY_TICKS
  {
   TICKS_INFO=1,     // только Bid и Ask 
   TICKS_TRADE=2,    // только Last и Volume
   TICKS_ALL=-1,     // все тики
  };
//--- input parameters
input double   InpLots           = 0.1;      // Lots
input ushort   InpStopLoss       = 150;      // Stop Loss 
input ushort   InpTakeProfit     = 50;       // Take Profit 
input int      InpPoints         = 15;       // цена должна пройти NNN пунктов
input uchar    InpTicks          = 15;       // за XXX тиков
input int      InpSleep          = 100;      // минимальная пауза между трейдами
//--- массивы для приема тиков
MqlTick        tick_array_curr[];            // массив тиков полученный на текущем тике
MqlTick        tick_array_prev[];            // массви тиков полученный на предыдущем тике
input ENUM_COPY_TICKS tick_flags=TICKS_INFO; // тики, вызванные изменениями Bid и/или Ask
ulong          tick_from=0;                  // если параметр tick_from=0, то отдаются последние tick_count тиков
uint           tick_count=15;                // количество тиков, которые необходимо получить 
//---
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtPoints=0.0;
bool           first_start=false;
long           last_trade_time=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);

   tick_count+=InpTicks;               // будем запрашивать "tick_count" + "за XXX тиков"
   ExtStopLoss=InpStopLoss*Point();
   ExtTakeProfit=InpTakeProfit*Point();
   ExtPoints=InpPoints*Point();
   first_start=false;
//--- запросим тики (первое заполнение)
   int copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
   if(copied!=tick_count)
      first_start=false;
   else
     {
      first_start=true;
      ArrayCopy(tick_array_prev,tick_array_curr);
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
//--- проверка на первый старт
   int copied=-1;
   if(!first_start)
     {
      copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
      if(copied!=tick_count)
         first_start=false;
      else
        {
         first_start=true;
         ArrayCopy(tick_array_prev,tick_array_curr);
        }
     }
//--- запросим тики
   copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
   if(copied!=tick_count)
      return;
   int index_new=-1;
   long last_time_msc=tick_array_prev[tick_count-1].time_msc;
   for(int i=(int)tick_count-1;i>=0;i--)
     {
      if(last_time_msc==tick_array_curr[i].time_msc)
        {
         index_new=i;
         break;
        }
     }
   if(index_new!=-1 && tick_array_curr[tick_count-1].time_msc-last_trade_time>InpSleep*1000)
     {
      int shift=(int)tick_count-1-index_new-InpTicks;   // смещение в текущем масиве тиков
      shift=(shift<0)?0:shift;
      if(tick_array_curr[tick_count-1].ask-tick_array_curr[shift].ask>ExtPoints)
        {
         int d=0;
         //--- открываем BUY
         double sl=(InpStopLoss==0)?0.0:tick_array_curr[tick_count-1].ask-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:tick_array_curr[tick_count-1].ask+ExtTakeProfit;
         m_trade.Buy(InpLots,m_symbol.Name(),tick_array_curr[tick_count-1].ask,
                     m_symbol.NormalizePrice(sl),
                     m_symbol.NormalizePrice(tp));
         last_trade_time=tick_array_curr[tick_count-1].time_msc;
        }
      else if(tick_array_curr[shift].bid-tick_array_curr[tick_count-1].bid>ExtPoints)
        {
         int d=0;
         //--- открываем SELL
         double sl=(InpStopLoss==0)?0.0:tick_array_curr[tick_count-1].bid-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:tick_array_curr[tick_count-1].bid+ExtTakeProfit;
         m_trade.Sell(InpLots,m_symbol.Name(),tick_array_curr[tick_count-1].bid,
                      m_symbol.NormalizePrice(sl),
                      m_symbol.NormalizePrice(tp));
         last_trade_time=tick_array_curr[tick_count-1].time_msc;
        }
     }
   ArrayCopy(tick_array_prev,tick_array_curr);
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
