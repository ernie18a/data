//+------------------------------------------------------------------+
//|                                                    ATR ratio.mq5 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
//---- ссылка на сайт автора
#property link      "http://www.damianifx.com.br"
#property description "ATR ratio"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии использован MediumOrchid цвет
#property indicator_color1 clrMediumOrchid
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "ATR ratio"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 1
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Short_ATRPeriod=7; // Период быстрого ATR
input int Long_ATRPeriod=49; // Период медленного ATR
input int ATRShift=0; // Сдвиг индикатора по горизонтали в барах 
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---- объявление переменных для хранения хендлов индикаторов
int SATR_Handle,LATR_Handle;
//---- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- получение хендла индикатора ATR
   SATR_Handle=iATR(NULL,PERIOD_CURRENT,Short_ATRPeriod);
   if(SATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- получение хендла индикатора ATR
   LATR_Handle=iATR(NULL,PERIOD_CURRENT,Long_ATRPeriod);
   if(LATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- инициализация переменных начала отсчёта данных
   min_rates_total=MathMax(Short_ATRPeriod,Long_ATRPeriod);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ATR ratio(",Short_ATRPeriod," ",Long_ATRPeriod,")");
//---- осуществление сдвига индикатора 1 по горизонтали на ATRShift
   PlotIndexSetInteger(0,PLOT_SHIFT,ATRShift);
//---- создание метки для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer,true);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(SATR_Handle)<rates_total
      || BarsCalculated(LATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double SRange[],LRange[];
//---- расчёты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы SRange[] и LRange[]
   if(CopyBuffer(SATR_Handle,0,0,to_copy,SRange)<=0) return(RESET);
   if(CopyBuffer(LATR_Handle,0,0,to_copy,LRange)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(SRange,true);
   ArraySetAsSeries(LRange,true);
//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(LRange[bar]!=0.0 && LRange[bar]!=EMPTY_VALUE) ExtLineBuffer[bar]=SRange[bar]/LRange[bar];
      else ExtLineBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
