//+------------------------------------------------------------------+
//|                                                  DSSBressert.mq5 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1 clrBlue,clrDeepPink
//---- отображение метки индикатора
#property indicator_label1  "DSS Bressert"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 20.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint  EMA_period=8;  // Период EMA
input uint  Sto_period=13; // Период стохастика
input int   Shift=0;       // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double DssBuffer[],MitBuffer[];
//---- объявление глобальных переменных
double smooth_coefficient;
//+------------------------------------------------------------------+   
//| XMA indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(Sto_period+1);
//---- инициализация переменных   
   smooth_coefficient=2.0/(1.0+EMA_period);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DssBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DssBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,MitBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MitBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"DSS Bressert(",EMA_period,", ",Sto_period,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XMA iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double HighRange,LowRange,delta,MIT,DSS;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      MitBuffer[limit+1]=50;
      DssBuffer[limit+1]=50;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора Mit
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HighRange=high[ArrayMaximum(high,bar,Sto_period)];
      LowRange=low[ArrayMinimum(low,bar,Sto_period)];
      delta=close[bar]-LowRange;
      MIT=delta/(HighRange-LowRange)*100.0;
      MitBuffer[bar]=smooth_coefficient*(MIT-MitBuffer[bar+1])+MitBuffer[bar+1];
     }
//---- основной цикл расчета индикатора DSS
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HighRange=MitBuffer[ArrayMaximum(MitBuffer,bar,Sto_period)];
      LowRange=MitBuffer[ArrayMinimum(MitBuffer,bar,Sto_period)];
      delta=MitBuffer[bar]-LowRange;
      DSS=delta/(HighRange-LowRange)*100.0;
      DssBuffer[bar]=smooth_coefficient*(DSS-DssBuffer[bar+1])+DssBuffer[bar+1];
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
