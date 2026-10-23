//+------------------------------------------------------------------+
//|                                                  AdaptiveRVI.mq5 |
//|                                                                  |
//| Adaptive RVI                                                     |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Coded by Witold Wozniak"
//---- авторство индикатора
#property link      "www.mqlsoft.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора Adaptive RVI  |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета основной линии индикатора использован цвет Red
#property indicator_color1  Red
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки линии индикатора
#property indicator_label1  "Adaptive RVI"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Trigger       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета сигнальной линии индикатора использован цвет Blue
#property indicator_color2  Blue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки линии индикатора
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
#define MAXPERIOD 100 // константа для ограничения маскимального периода
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;  // Коэффициент усреднения индикатора 
input int Shift=0;        // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double ARVIBuffer[];
double TriggerBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int CP_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Value1[],Value2[];
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
//|  Получение разницы значений ценовых таймсерий                    |
//+------------------------------------------------------------------+   
double Get_dPrice(const double  &Price1[],const double  &Price2[],int bar)
  {
//----
   return(Price1[bar]-Price2[bar]);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=4;

//---- получение хендла индикатора CyclePeriod
   CP_Handle=iCustom(NULL,0,"CyclePeriod",Alpha);
   if(CP_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора CyclePeriod");
      return(1);
     }

//---- распределение памяти под массивы переменных  
   ArrayResize(Count,MAXPERIOD);
   ArrayResize(Value1,MAXPERIOD);
   ArrayResize(Value2,MAXPERIOD);
   
   ArrayInitialize(Count,0);
   ArrayInitialize(Value1,0.0);
   ArrayInitialize(Value2,0.0);

//---- превращение динамического массива ARVIBuffer[] в индикаторный буфер
   SetIndexBuffer(0,ARVIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива TriggerBuffer[] в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Adaptive RVI(",DoubleToString(Alpha,4),", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   
   return(0);
//----
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
   if(BarsCalculated(CP_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar,Length;
   double Num,Denom,rvi,period[4];

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=3;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(CP_Handle,0,rates_total-1-bar,4,period)<=0) return(RESET);

      Length=int(MathFloor((4.0*period[3]+3.0*period[2]+2.0*period[1]+period[0])/20.0));
      if(bar<Length) Length=bar; // урезание усреднения до действительного числа баров

      Value1[Count[0]]=(Get_dPrice(close,open,bar)
                        +2.0*Get_dPrice(close,open,bar-1)
                        +2.0*Get_dPrice(close,open,bar-2)
                        +Get_dPrice(close,open,bar-3))/6.0;

      Value2[Count[0]]=(Get_dPrice(high,low,bar)
                        +2.0*Get_dPrice(high,low,bar-1)
                        +2.0*Get_dPrice(high,low,bar-2)
                        +Get_dPrice(high,low,bar-3))/6.0;

      Num=0.0;
      Denom=0.0;

      for(int iii=0; iii<Length; iii++)
        {
         Num+=Value1[Count[iii]];
         Denom+=Value2[Count[iii]];
        }

      if(Denom!=0.0) rvi=Num/Denom;
      else rvi=EMPTY_VALUE;

      ARVIBuffer[bar]=rvi;
      TriggerBuffer[bar]=ARVIBuffer[bar-1];

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,MAXPERIOD);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
