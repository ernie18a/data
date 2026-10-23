//+------------------------------------------------------------------+
//|                                                         WPR3.mq5 |
//|                                       Copyright © 2005, Dark Han |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Dark Han"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
#property description "Williams’ Percent Range"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано три графических построения
#property indicator_plots   3
//---- ограничения масштаба размеров окна индикатора по вертикали
#property indicator_maximum 0
#property indicator_minimum -100
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован оливковый цвет
#property indicator_color1 clrOliveDrab
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "High WPR"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован серый цвет
#property indicator_color2 clrGray
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Close WPR"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован какао цвет
#property indicator_color3 clrPaleVioletRed
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Low WPR"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 -30
#property indicator_level2 -70
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_            //PRICE_LOW
  };
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ExtWPRPeriod=11;                       // Период усреднения
input int Shift = 0;                              // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpperBuffer[],MiddleBuffer[],LowerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(ExtWPRPeriod);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"WPR3(",ExtWPRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MiddleBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int limit,bar;
   double range,HH,LL;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MiddleBuffer[bar]=UpperBuffer[bar]=LowerBuffer[bar]=50;
      HH=high[ArrayMaximum(high,bar,ExtWPRPeriod)];
      LL=low[ArrayMinimum(low,bar,ExtWPRPeriod)];
      range=HH-LL;
      //----
      if(!CompareDouble(range,0.0))
        {
         MiddleBuffer[bar]=-100*(HH-close[bar])/range;
         UpperBuffer[bar]=-100*(HH-high[bar])/range;
         LowerBuffer[bar]=-100*(HH-low[bar])/range;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Функция сравнения двух вещественных чисел                        |
//+------------------------------------------------------------------+
bool CompareDouble(double Number1,double Number2)
  {
//----
   bool Compare=NormalizeDouble(Number1-Number2,8)==0;
//----
   return(Compare);
  }
//+------------------------------------------------------------------+
