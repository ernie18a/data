//+------------------------------------------------------------------+
//|                                                   ColorMETRO.mq5 | 
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"
#property description "METRO"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define UP_TREND +1           // Константа для растущего направления тренда
#define DN_TREND -1           // Константа для падающего направления тренда
//+----------------------------------------------+
//|  Параметры отрисовки индикатора StepRSI      |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использованы
#property indicator_color1  clrLime,clrRed
//---- отображение метки индикатора
#property indicator_label1  "StepRSI Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора RSI          |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет Blue
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "RSI"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  70
#property indicator_level2  50
#property indicator_level3  30
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint PeriodRSI=7;                               // Период индикатора
input int StepSizeFast=5;                             // Быстрый шаг
input int StepSizeSlow=15;                            // Медленный шаг
input int Shift=0;                                    // Сдвиг индикатора по горизонтали в барах 
input ENUM_APPLIED_PRICE  Applied_price=PRICE_CLOSE;  // тип цены или handle 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double Line1Buffer[];
double Line2Buffer[];
double Line3Buffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int RSI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(PeriodRSI);

//---- получение хендла индикатора RSI
   RSI_Handle=iRSI(NULL,0,PeriodRSI,Applied_price);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора RSI");
      return(INIT_FAILED);
     }

//---- превращение динамического массива Line2Buffer[] в индикаторный буфер
   SetIndexBuffer(0,Line2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Line2Buffer,true);

//---- превращение динамического массива Line3Buffer[] в индикаторный буфер
   SetIndexBuffer(1,Line3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Line3Buffer,true);

//---- превращение динамического массива Line1Buffer[] в индикаторный буфер
   SetIndexBuffer(2,Line1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Line1Buffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"METRO(",PeriodRSI,", ",StepSizeFast,", ",StepSizeSlow,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,to_copy,bar,ftrend,strend;
   double fmin0,fmax0,smin0,smax0,RSI0,RSI[];
   static double fmax1,fmin1,smin1,smax1;
   static int ftrend_,strend_;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RSI,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров

      fmin1=+DBL_MAX;
      fmax1=-DBL_MAX;
      smin1=+DBL_MAX;
      smax1=-DBL_MAX;
      ftrend_=NULL;
      strend_=NULL;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(0);

//---- восстанавливаем значения переменных
   ftrend = ftrend_;
   strend = strend_;

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         ftrend_=ftrend;
         strend_=strend;
        }

      RSI0=RSI[bar];

      fmax0=RSI0+2*StepSizeFast;
      fmin0=RSI0-2*StepSizeFast;

      if(RSI0>fmax1)  ftrend=UP_TREND;
      if(RSI0<fmin1)  ftrend=DN_TREND;

      if(ftrend>0 && fmin0<fmin1) fmin0=fmin1;
      if(ftrend<0 && fmax0>fmax1) fmax0=fmax1;

      smax0=RSI0+2*StepSizeSlow;
      smin0=RSI0-2*StepSizeSlow;

      if(RSI0>smax1)  strend=UP_TREND;
      if(RSI0<smin1)  strend=DN_TREND;

      if(strend>0 && smin0<smin1) smin0=smin1;
      if(strend<0 && smax0>smax1) smax0=smax1;

      Line1Buffer[bar]=RSI0;

      if(ftrend>0) Line2Buffer[bar]=fmin0+StepSizeFast;
      if(ftrend<0) Line2Buffer[bar]=fmax0-StepSizeFast;
      if(strend>0) Line3Buffer[bar]=smin0+StepSizeSlow;
      if(strend<0) Line3Buffer[bar]=smax0-StepSizeSlow;

      if(bar>0)
        {
         fmin1=fmin0;
         fmax1=fmax0;
         smin1=smin0;
         smax1=smax0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
