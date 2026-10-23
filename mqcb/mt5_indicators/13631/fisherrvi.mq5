//+------------------------------------------------------------------+
//|                                                    FisherRVI.mq5 |
//|                                                                  |
//| Fisher RVI                                                       |
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
//| Параметры отрисовки индикатора Fisher RVI    |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1  Red
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Fisher RVI"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Trigger       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color2  Blue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Length=8; // Период индикатора
input int Shift=0;  // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double FRVIBuffer[];
double TriggerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count1[],Count2[];
double RVI[],Value1[],Value2[],Value3[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos1(int &CoArr[])// возврат по ссылке номера текущего значения ценового ряда
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max1=Length-1;
   Max2=Length;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos2(int &CoArr[])// возврат по ссылке номера текущего значения ценового ряда
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max1=3;
   Max2=4;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=Length+3;
//---- распределение памяти под массивы переменных  
   ArrayResize(Count1,Length);
   ArrayResize(Value1,Length);
   ArrayResize(Value2,Length);
   ArrayResize(RVI,Length);
   ArrayResize(Count2,4);
   ArrayResize(Value3,4);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,FRVIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Fisher RVI(",Length,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
   if(rates_total<min_rates_total) return(0);
//---- объявления локальных переменных 
   int first,bar;
   double Num,Denom,hh,ll,tmp,rvi,Value4;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=3; // стартовый номер для расчета всех баров
      for(int numb=0; numb<Length; numb++) Count1[numb]=numb;
      for(int numb=0; numb<4; numb++) Count2[numb]=numb;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Value1[Count1[0]]=((close[bar]-open[bar])+
                         2.0 *(close[bar-1]-open[bar-1])+
                         2.0 *(close[bar-2] - open[bar-2]) +
                         (close[bar-3]-open[bar-3]))/6.0;
      //----
      Value2[Count1[0]]=((high[bar]-low[bar])+
                         2.0 * (high[bar-1] - low[bar-1]) +
                         2.0 * (high[bar-2] - low[bar-2]) +
                         (high[bar-3]-low[bar-3]))/6.0;
      //----
      if(bar<Length+4)
        {
         Recount_ArrayZeroPos1(Count1);
         Recount_ArrayZeroPos2(Count2);
         continue;
        }
      //----
      Num=0.0;
      Denom=0.0;
      //----
      for(int iii=0; iii<Length; iii++)
        {
         Num+=Value1[Count1[iii]];
         Denom+=Value2[Count1[iii]];
        }
      //----
      if(Denom!=0.0) rvi=Num/Denom;
      else rvi=0.0;
      //----
      RVI[Count1[0]]=rvi;
      hh = rvi;
      ll = rvi;
      //----
      for(int iii=0; iii<Length; iii++)
        {
         tmp= RVI[Count1[iii]];
         hh = MathMax(hh, tmp);
         ll = MathMin(ll, tmp);
        }
      //----
      if(hh!=ll) Value3[Count2[0]]=(rvi-ll)/(hh-ll);
      else Value3[Count2[0]]=0.0;
      //----
      Value4=(4.0*Value3[Count2[0]]+3.0*Value3[Count2[1]]+2.0*Value3[Count2[2]]+Value3[Count2[3]])/10.0;
      //----
      double res=1.0-1.98 *(Value4-0.5);
      if(res) FRVIBuffer[bar]=0.5*MathLog((1.0+1.98 *(Value4-0.5))/res);
      else FRVIBuffer[bar]=0.0;
      //----
      TriggerBuffer[bar]=FRVIBuffer[bar-1];
      //----
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos1(Count1);
         Recount_ArrayZeroPos2(Count2);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
