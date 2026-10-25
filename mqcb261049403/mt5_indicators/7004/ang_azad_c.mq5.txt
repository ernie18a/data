//+------------------------------------------------------------------+ 
//|                                                   ang_AZad_C.mq5 | 
//|                           Copyright © 2006, ANG3110@latchess.com | 
//|                                             ANG3110@latchess.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, ANG3110@latchess.com"
#property link "ANG3110@latchess.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 1
#property indicator_buffers 1 
//--- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "ang_AZad_C"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input double ki=4;
input int Shift=0;
//+-----------------------------------+
//--- объявление целочисленных переменных начала отсчёта данных
int  min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=4;
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ang_AZad_C");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);
//--- объявление переменных с плавающей точкой 
   double z,z2,Za2,Za;
   static double z_,z2_,Za2_,Za_;
//--- объявление целочисленных переменных
   int limit;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Close,true);
//--- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      Za2_=Za=z2_=z_=Close[limit+1];
     }
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров
   z=z_;
   z2=z2_;
   Za2=Za2_;
   Za=Za_;
//--- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Close[bar]>z && Close[bar]>Close[bar+1]) z=Za_+(Close[bar]-Za_)/ki;
      if(Close[bar]<z && Close[bar]<Close[bar+1]) z=Za_+(Close[bar]-Za_)/ki;
      if(Close[bar]>z2 && Close[bar]<Close[bar+1]) z2=Za2_+(Close[bar]-Za2_)/ki;
      if(Close[bar]<z2 && Close[bar]>Close[bar+1]) z2=Za2_+(Close[bar]-Za2_)/ki;

      Za=z;
      Za2=z2;
      
      IndBuffer[bar]=(Za-Za2)/_Point;

      if(bar)
        {
         z_=z;
         z2_=z2;
         Za2_=Za2;
         Za_=Za;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
