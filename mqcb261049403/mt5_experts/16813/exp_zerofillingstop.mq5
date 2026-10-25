//+------------------------------------------------------------------+
//|                                          Exp_ZeroFillingStop.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
#property description   "Эксперт переводит позицию в безубыток, то есть ставит стоплосс на уровне цены открывания позиции,"
#property description   "при достижении ценой финансового актива количества пунктов прибыли, которое определяется входными параметрами эксперта"
//+----------------------------------------------+
//  Торговые алгоритмы                           | 
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//| Входные параметры эксперта                   |
//+----------------------------------------------+
input uint   ZeroFillingStop=500;     //профит позиции в пунктах
input uint    Deviation_=10;          //макс. отклонение цены в пунктах
//+----------------------------------------------+
//---- объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   GlobalVariableDel_(Symbol());
//----
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- проверка количества баров на достаточность для расчёта
   if(Bars(Symbol(),PERIOD_CURRENT)<min_rates_total) return;

//---- Объявление локальных переменных
   double ;
//---- Объявление и обнуление переменных сигналов трейлинстопов   
   bool BUY_tral=false;
   bool SELL_tral=false;
   double NewStop=0.0;
//---- Инициализация сигналов трейлинстопов и перевода позиции в безубыток
   if(PositionSelect(Symbol())) //Проверка на на наличие открытой позиции
     {
      ENUM_POSITION_TYPE PosType=ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));

      if(PosType==POSITION_TYPE_SELL)
        {
         double LastStop=PositionGetDouble(POSITION_SL);
         double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
         double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
         if(!Bid || !point) return; //нет данных для дальнейшего расчёта
         double OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         int point_profit=int((OpenPrice-Bid)/point);

         //---- Получим сигналы переноса стоплосса шорта в безубыток
         if(LastStop>OpenPrice && point_profit>int(ZeroFillingStop))
           {
            NewStop=OpenPrice;
            SELL_tral=true;
           }
        }

      if(PosType==POSITION_TYPE_BUY)
        {
         double LastStop=PositionGetDouble(POSITION_SL);
         double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
         if(!Ask || !point) return;  //нет данных для дальнейшего расчёта
         double OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         int point_profit=int((Ask-OpenPrice)/point);

         //---- Получим сигналы переноса стоплосса лонга в безубыток
         if(LastStop<OpenPrice && point_profit>int(ZeroFillingStop))
           {
            NewStop=OpenPrice;
            BUY_tral=true;
           }
        }
     }
//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- Модифицируем лонг
   dBuyPositionModify(BUY_tral,Symbol(),Deviation_,NewStop,0.0);

//---- Модифицируем  шорт
   dSellPositionModify(SELL_tral,Symbol(),Deviation_,NewStop,0.0);
//----
  }
//+------------------------------------------------------------------+
