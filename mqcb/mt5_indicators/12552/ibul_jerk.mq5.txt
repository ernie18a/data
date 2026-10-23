//+------------------------------------------------------------------+
//|                                                   i-Bul_Jerk.mq5 |
//|                         Copyright © 2013, Ким Игорь В. aka KimIV | 
//|                                              http://www.kimiv.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2013, Ким Игорь В. aka KimIV"
//--- ссылка на сайт автора
#property link      "http://www.kimiv.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0    // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "i-Bul_Jerk Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "i-Bul_Jerk Buy"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint NumbOfBars    = 3;     // Количество сигнальных баров
input uint PriceDistance = 1000;  // Расстояние в пунктах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
double dPriceDistance;
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   dPriceDistance=_Point*PriceDistance;
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,NumbOfBars));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон
   string short_name="i-Bul_Jerk";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double ATR[];
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы и ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
//--- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      double bs=GetSignal(bar,High,Low,Close);
      if(bs>0) BuyBuffer[bar]=Low[bar]-0.3*ATR[bar];
      if(bs<0) SellBuffer[bar]=High[bar]+0.3*ATR[bar];
     }
//---     
   return(rates_total);
  }
//+----------------------------------------------------------------------------+
//|                                                                            |
//|  ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ                                                  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//|  Автор    : Александр Багрянов, al22bag@live.com.au                        |
//|           : http://ruforum.mt5.com/members/11292-al22bag                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 29.06.2013                                                     |
//|  Описание : Формирует и возвращает торговый сигнал.                        |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    nb - номер бара                 (0 - текущий бар)                       |
//+----------------------------------------------------------------------------+
//|  Возвращаемое значение:                                                    |
//|     1 - покупай                                                            |
//|     0 - сиди, кури бамбук                                                  |
//|    -1 - продавай                                                           |
//+----------------------------------------------------------------------------+
int GetSignal(int nb,const double &high[],const double &low[],const double &close[])
  {
//---
   int bs=0;
   double hi=NormalizeDouble(high[ArrayMaximum(high,nb,NumbOfBars)],_Digits);
   double lo=NormalizeDouble(low[ArrayMinimum(low,nb,NumbOfBars)],_Digits);
//---
   if(close[nb]-lo>=dPriceDistance) bs=-1;
   if(hi-close[nb]>=dPriceDistance) bs=+1;
//---
   return(bs);
  }
//+------------------------------------------------------------------+
