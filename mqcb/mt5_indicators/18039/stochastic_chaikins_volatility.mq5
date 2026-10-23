//+------------------------------------------------------------------+
//|                               Stochastic_Chaikins_Volatility.mq5 |
//|                                         Copyright © 2014, Giaras |
//|                                   giampiero.raschetti@gmail.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2014, Giaras"
//---- авторство индикатора
#property link      "giampiero.raschetti@gmail.com/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrDarkTurquoise,clrIndianRed
//---- отображение метки линии индикатора
#property indicator_label1  "Stochastic_Chaikins_Volatility"
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_; //метод усреднения первого сглаживания 
input uint Length1=10; //глубина  первого сглаживания                    
input int Phase1=15; //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint StocLength=5;
input Smooth_Method MA_Method2=MODE_JJMA; //метод усреднения второго сглаживания 
input uint Length2 = 5; //глубина  второго сглаживания 
input int Phase2=15;  //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящейinput int Shift=0;        // Сдвиг индикатора по горизонтали в барах
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах 
input uint HighLevel=80;
input uint MiddleLevel=50;
input uint LowLevel=20;
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double IndBuffer[];
double TriggerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1,min_rates_2;
//---- объявление глобальных переменных
int Count[];
double chakin[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
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
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_2=min_rates_1+int(StocLength)+1;
   min_rates_total=min_rates_2+GetStartBars(MA_Method2,Length2,Phase2);

//---- распределение памяти под массивы переменных  
   ArrayResize(Count,StocLength);
   ArrayResize(chakin,StocLength);

//---- превращение динамического массива IndBuffer[] в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива TriggerBuffer[] в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);

//---- инициализации переменной для короткого имени индикатора
   string shortname="Stochastic_Chaikins_Volatility";
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1;                   // стартовый номер для расчета всех баров
      ArrayInitialize(Count,NULL);
      ArrayInitialize(chakin,NULL);
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      chakin[Count[0]]=XMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar]-low[bar],bar,false);      
      double hh=chakin[Count[0]],ll=chakin[Count[0]];
      for(int iii=0; iii<int(StocLength); iii++)
        {
         hh=MathMax(hh,chakin[iii]);
         ll=MathMin(ll,chakin[iii]);
        }
      double Value1=chakin[Count[0]]-ll;
      double Value2=MathMax(1*_Point,hh-ll);          
      IndBuffer[bar]=100*XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,Value1/Value2,bar,false);
      TriggerBuffer[bar]=IndBuffer[bar-1];
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,StocLength);
     }
//----     
   return(rates_total);
  }

//+------------------------------------------------------------------+
