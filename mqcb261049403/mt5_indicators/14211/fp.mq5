//+------------------------------------------------------------------+
//|                                                           FP.mq5 | 
//|                                 Copyright © 2006, Nick A. Zhilin |
//|                                              rebus@dialup.etr.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick A. Zhilin"
#property link      "rebus@dialup.etr.ru"
#property description "FP channel"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего 3 графических построений
#property indicator_plots   3
//+--------------------------------------------+ 
//| Объявление констант                        |
//+--------------------------------------------+
#define RESET 0  // константа для возврата терминалу команды на пересчет индикатора
//+--------------------------------------------+
//| Параметры отрисовки индикатора             |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии индикатора использован MediumBlue цвет
#property indicator_color1 MediumBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "FP"
//+--------------------------------------------+
//| Параметры отрисовки канала                 |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней
#property indicator_color2  LightSeaGreen
#property indicator_color3  FireBrick
//---- уровни - непрерывные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней равна 2
#property indicator_width2  2
#property indicator_width3  2
//---- отображение меток уровней 
#property indicator_label2  "+FP"
#property indicator_label3  "-FP"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint IPeriod=100;  // Период индикатора
input int  Shift=0;      // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double FPBuffer[],UpFPBuffer[],DnFPBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(IPeriod);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,FPBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(FPBuffer,true);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,UpFPBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnFPBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикаторов по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- установка позиции, с которой начинается отрисовка индикаторов
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(UpFPBuffer,true);
   ArraySetAsSeries(DnFPBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"FP channel");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int limit;
   double max,min,pivot,middle;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {      
      max=high[ArrayMaximum(high,bar,IPeriod)];
      min=low [ArrayMinimum(low, bar,IPeriod)];
      pivot=(close[bar+1]+close[bar+2]+close[bar+3])/3;
      middle=(max+min+pivot)/3;     
      FPBuffer[bar]=middle;
      middle*=3;
      UpFPBuffer[bar]=(middle-min)/2;
      DnFPBuffer[bar]=(middle-max)/2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
