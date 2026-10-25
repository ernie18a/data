//+---------------------------------------------------------------------+
//|                                                       RealValue.mq5 | 
//|                                  Copyright © 2015, rzegorz Szczerba | 
//|                                         grzegorz.szczerba@gmail.com | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, rzegorz Szczerba"
#property link "grzegorz.szczerba@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "RealValue"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=1;
input double Variation=3.0;
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input uint XLength=20;                   // Глубина сглаживания                    
input int XPhase=15;                     // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                       // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                  // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//---- объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| RealValue indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"RealValue");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| RealValue iteration function                                     | 
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
   double var,xvar,val,diffB,diff,res;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=2; // стартовый номер для расчета всех баров
      IndBuffer[first-1]=(high[first-1]+low[first-1])/2.0;
      IndBuffer[first-2]=(high[first-2]+low[first-2])/2.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      var=MathAbs((high[bar]-low[bar])-(high[bar-1]-low[bar-1]));
      xvar=XMA1.XMASeries(2,prev_calculated,rates_total,XMA_Method,XPhase,XLength,var,bar,false);
      val=(high[bar]+low[bar])/2.0;
      diffB=IndBuffer[bar-1]-IndBuffer[bar-2];
      diff=val-(high[bar-1]+low[bar-1])/2.0;
      res=Alpha*var;
      if(diffB>res) diffB=res;
      if(diffB<-res) diffB=-res;
      //---
      double c=var/Variation;
      if(val>IndBuffer[bar-1])
        {
         if(diff<0)
           {
            c=0;
            diffB=0;
           }
         IndBuffer[bar]=IndBuffer[bar-1]+diffB+c;
        }
      else
        {
         if(diff>0)
           {
            c=0;
            diffB=0;
           }
         IndBuffer[bar]=IndBuffer[bar-1]+diffB-c;
        }
      IndBuffer[bar]=(IndBuffer[bar]+IndBuffer[bar-1])/2.0;
      IndBuffer[bar]+=dPriceShift;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
