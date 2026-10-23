//+------------------------------------------------------------------+
//|                                                   DeltaForce.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "https://www.metaquotes.net/" 
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов двухцветной гистограммы использованы
#property indicator_color1  clrBlue,clrDodgerBlue
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "High"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type2   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов двухцветной гистограммы использованы
#property indicator_color2  clrMagenta,clrPurple
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "Low"

//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double HIndBuffer[],ColorHIndBuffer[];
double LIndBuffer[],ColorLIndBuffer[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,HIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorHIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorLIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"DeltaForce");

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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

//---- Объявление переменных с плавающей точкой  
   double;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;
   int diff,deltah,deltal,resh,resl;
   static int deltah_prev,deltal_prev,resh_prev,resl_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      deltah_prev=NULL;
      deltal_prev=NULL;
      resh_prev=NULL;
      resl_prev=NULL;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

   deltah=deltah_prev;
   deltal=deltal_prev;
   resh=resh_prev;
   resl=resl_prev;

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      HIndBuffer[bar]=NULL;
      LIndBuffer[bar]=NULL;
      
      diff=int((close[bar]-close[bar-1])/_Point);
      if(diff>0)
        {
         resl=0;
         if(!resh) deltah=NULL;
         deltah+=diff;
         resh=1;
        }
      if(!resh) deltah=NULL;
      HIndBuffer[bar]=deltah;

      if(diff<0)
        {
         resh=0;
         if(!resl) deltal=NULL;
         deltal+=diff;
         resl=1;
        }
      if(!resl) deltal=NULL;
      LIndBuffer[bar]=deltal;

      if(bar<rates_total-1)
        {
         deltah_prev=deltah;
         deltal_prev=deltal;
         resh_prev=resh;
         resl_prev=resl;
        }
     }

//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total+1; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ColorHIndBuffer[bar]=ColorHIndBuffer[bar-1];
      if(HIndBuffer[bar-1]<HIndBuffer[bar]) ColorHIndBuffer[bar]=0;
      else if(HIndBuffer[bar-1]>HIndBuffer[bar]) ColorHIndBuffer[bar]=1;
      //----
      ColorLIndBuffer[bar]=ColorLIndBuffer[bar-1];
      if(LIndBuffer[bar-1]>LIndBuffer[bar]) ColorLIndBuffer[bar]=0;
      else if(LIndBuffer[bar-1]<LIndBuffer[bar]) ColorLIndBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
