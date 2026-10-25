//+------------------------------------------------------------------+ 
//|                                                      TrailCD.mq5 | 
//|                                     Copyright © 2007, John Smith | 
//|                                https://www.mql5.com/ru/code/7383 | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, John Smith"
#property link "https://www.mql5.com/ru/code/7383" 
#property description "Схождение/расхождение быстрого и медленного тралов"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrMagenta,clrMaroon,clrDeepPink,clrGray,clrDodgerBlue,clrGreen,clrAqua
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1 2
//--- отображение метки индикатора
#property indicator_label1 "TrailCD"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint TrailFast=25;     // Быстрый трал
input uint TrailSlow=65;     // Медленный трал
//+-----------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| TrailCD indicator initialization function                        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=2;
//--- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"TrailCD");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| TrailCD iteration function                                       | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,     // количество истории в барах на текущем тике
                const int prev_calculated, // количество истории в барах на предыдущем тике
                const int begin,           // номер начала достоверного отсчета баров
                const double &price[])     // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
///--- объявления локальных переменных 
   int first,bar,nprice,clr;
   int value_fast,value_slow;
   int value_fast_,value_slow_;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1+begin;  // стартовый номер для расчета всех баров
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      value_fast_=value_slow_=int(MathRound(price[first-1]/_Point));
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---
   value_fast=value_fast_;
   value_slow=value_slow_;
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      nprice=int(MathRound(price[bar]/_Point));
      if(value_fast<nprice-int(TrailFast)) value_fast=nprice-int(TrailFast);
      if(value_fast>nprice+int(TrailFast)) value_fast=nprice+int(TrailFast);
      if(value_slow<nprice-int(TrailSlow)) value_slow=nprice-int(TrailSlow);
      if(value_slow>nprice+int(TrailSlow)) value_slow=nprice+int(TrailSlow);
      IndBuffer[bar]=(value_fast-value_slow);
      //---
      if(bar<=rates_total-2)
        {
         value_fast_=value_fast;
         value_slow_=value_slow;
        }
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//--- основной цикл раскраски индикатора Ind
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=3;
      //---
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=6;
         if(IndBuffer[bar]==IndBuffer[bar-1]) clr=5;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=4;
        }
      //---
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]==IndBuffer[bar-1]) clr=1;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=2;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
