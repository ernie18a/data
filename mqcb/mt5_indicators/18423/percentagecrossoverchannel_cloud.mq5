//+------------------------------------------------------------------+ 
//|                             PercentageCrossoverChannel_Cloud.mq5 | 
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
#property indicator_buffers 7 
//---- использовано пять графических построений
#property indicator_plots   5
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLawnGreen
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrPink
//---- отображение метки индикатора
#property indicator_label2  "Lower Cloud"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color3 clrGreen
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Upper PC Channel"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color4 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "Middle PC Channel"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован розовый цвет
#property indicator_color5 clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "Lower PC Channel"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double percent=1.0; //процентное отклонение цены от предыдущего значения индикатора
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpperBuffer[],MiddleBuffer[],LowerBuffer[];
double UpBuffer1[],UpBuffer2[],DnBuffer1[],DnBuffer2[];
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
   SetIndexBuffer(0,UpBuffer2,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnBuffer1,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Percentage Crossover Channel(percent = ",percent,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated==0) // проверка на первый старт расчёта индикатора
     {
      first=1+begin; // стартовый номер для расчёта всех баров
      MiddleBuffer[first-1]=price[first-1];
      //---- осуществление сдвига начала отсчёта отрисовки индикаторов
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта средней линии канала
   for(bar=first; bar<rates_total; bar++)
     {
      bar1=bar-1;
      if((price[bar]*minusvar)>MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*minusvar;
      else
        {
         if(price[bar]*plusvar<MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*plusvar;
         else MiddleBuffer[bar]=MiddleBuffer[bar1];
        }
      UpBuffer1[bar]=DnBuffer1[bar]=MiddleBuffer[bar];
      
      UpperBuffer[bar]=UpBuffer2[bar]=MiddleBuffer[bar]+(MiddleBuffer[bar]/100)*percent;
      LowerBuffer[bar]=DnBuffer2[bar]=MiddleBuffer[bar]-(MiddleBuffer[bar]/100)*percent;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
