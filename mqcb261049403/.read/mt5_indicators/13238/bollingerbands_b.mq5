//+------------------------------------------------------------------+
//|                                             BollingerBands_b.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                                    Modified by Alejandro Galindo |
//|                                                                  |
//|                                           You are free to use it |
//|                                                                  |
//|      If you want and if this work/modification is helpful to you |
//|             you can send me a PayPal donation to ag@elcactus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычьей линии индикатора использован clrMediumSlateBlue цвет
#property indicator_color1 clrMediumSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1 1
//---- отображение метки индикатора
#property indicator_label1  "Bollinger Bands% b"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint BBPeriod=20;                              // Период для расчета средней линии
input double StdDeviation=2;                         // Девиация
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; // Тип цены
input int Shift=0;                                   // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- индикаторный буфер
double IndBuffer[];
//---- объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Bollinger Bands% b indicator initialization function             | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(BBPeriod);
//---- получение хендла индикатора iBands
   Ind_Handle=iBands(NULL,0,BBPeriod,0,StdDeviation,applied_price);
   if(Ind_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iBands");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Bollinger Bands% b",BBPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Bollinger Bands% b iteration function                            | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double UpBB[],DnBB[];
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(close[bar]-UpBB[bar])/(DnBB[bar]-UpBB[bar]);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
