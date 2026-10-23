//+------------------------------------------------------------------+ 
//|                                          PercentageCrossover.mq5 | 
//|                                        Copyright © 2009, Vic2008 | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Vic2008"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов использованы
#property indicator_color1  clrBlueViolet,clrOrange
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "PercentageCrossover"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double percent=1.0; // процентное отклонение цены от предыдущего значения индикатора
input int Shift=0;        // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- объявление глобальных переменных
double plusvar,minusvar;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=2;
   double var1=percent/100;
   plusvar=1+var1;
   minusvar=1-var1;
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Percentage Crossover(percent = ",percent,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчёта баров
                const double &price[]     // ценовой массив для расчёта индикатора
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total+begin) return(0);

//---- Объявление целых переменных
   int first,bar,bar1;
   double Middle;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated==0) // проверка на первый старт расчёта индикатора
     {
      first=1+begin; // стартовый номер для расчёта всех баров
      IndBuffer[first-1]=price[first-1];
      //---- осуществление сдвига начала отсчёта отрисовки индикаторов
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта средней линии
   for(bar=first; bar<rates_total; bar++)
     {
      bar1=bar-1;
      if((price[bar]*minusvar)>IndBuffer[bar1]) Middle=price[bar]*minusvar;
      else
        {
         if(price[bar]*plusvar<IndBuffer[bar1]) Middle=price[bar]*plusvar;
         else Middle=IndBuffer[bar1];
        }
      IndBuffer[bar]=Middle;      
      ColorIndBuffer[bar]=ColorIndBuffer[bar-1];
      
      if(Middle>IndBuffer[bar-1]) ColorIndBuffer[bar]=0;
      if(Middle<IndBuffer[bar-1]) ColorIndBuffer[bar]=1;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
