//+---------------------------------------------------------------------+
//|                                                       BWImp-T01.mq5 | 
//|                             Copyright © 2006, HomeSoft-Tartan Corp. | 
//|                        spiky@transkeino.ru - http:\\www.fxexpert.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, HomeSoft-Tartan Corp."
#property link      "spiky@transkeino.ru - http:\\www.fxexpert.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "BWImp-T01"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Period1=96; // Период 1
input uint Period2=3;  // Период 2
input Smooth_Method XMA_Method=MODE_T3; // Метод сглаживания
input uint XLength=8; // Глубина сглаживания                    
input int XPhase=70;  // Параметр сглаживания
                      // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
                      // для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;    // Сдвиг индикатора по горизонтали в барах
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
double Point10;
//---- объявление целочисленных переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//---- объявление глобальных переменных
int Count[];
double impr[],impb[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
   int numb,Max1,Max2;
   static int count=1;
   Max2=Size;
   Max1=Max2-1;
   count--;
   if(count<0) count=Max1;
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Получение разницы значений ценовых таймсерий                     |
//+------------------------------------------------------------------+   
double Get_dPrice(const double  &Price1[],const double  &Price2[],int index)
  {
   return(Price1[index]-Price2[index]);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   min_rates_1=int(Period1+Period2);
   min_rates_total=min_rates_1+XMA1.GetStartBars(XMA_Method,XLength,XPhase);
   Point10=_Point/10;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,Period2);
   ArrayResize(impr,Period2);
   ArrayResize(impb,Period2);
   ArrayInitialize(Count,0);
   ArrayInitialize(impr,0.0);
   ArrayInitialize(impb,0.0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"BWImp-T01(",XLength,", ",Smooth1,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double imppr,imppb,sipr,sipb,sum;
//---- объявление целых переменных и получение уже посчитанных баров
   int first,bar;
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=int(Period1); // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      imppr=0;
      imppb=0;
      for(int kkk=0; kkk<int(Period1); kkk++)
        {
         double diff=Get_dPrice(close,open,bar-kkk);
         if(diff>0) imppr+=diff;
         if(diff<0) imppb+=diff;
        }
      imppr=MathRound(imppr/_Point);
      imppb=MathRound(imppb/_Point);
      if(!imppr) imppr=Point10;
      if(!imppb) imppb=Point10;
      impr[Count[0]]=imppr;
      impb[Count[0]]=imppb;
      sipr=0;
      sipb=0;
      for(int kkk=0; kkk<int(Period2); kkk++)
        {
         sipr+=impr[kkk];
         sipb+=impb[kkk];
        }
      sipr=MathRound((sipr/Period2));
      sipb=MathRound((sipb/Period2));
      sum=sipr+sipb;
      IndBuffer[bar]=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,sum,bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,Period2);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
