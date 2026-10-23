//+------------------------------------------------------------------+
//|                                              VortexIndicator.mq5 |
//|                                     Copyright © 2010, Scratchman |
//|                   http://creativecommons.org/licenses/by-sa/3.0/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2010, Scratchman"
//---- авторство индикатора
#property link      "http://creativecommons.org/licenses/by-sa/3.0/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета бычей линии индикатора использованы
#property indicator_color1  clrDarkOrange,clrLime
//---- отображение бычей метки индикатора
#property indicator_label1  "VortexIndicator"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint VI_Length=14;// период индикатора 
input int Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double DnBuffer[];
double UpBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
int Count[];
double UpVM[],DnVM[];
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[]// Возврат по ссылке номера текущего значения ценового ряда
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=int(VI_Length);
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
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(VI_Length+1);

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,VI_Length);
   ArrayResize(UpVM,VI_Length);
   ArrayResize(DnVM,VI_Length);

//---- Инициализация массивов переменных
   ArrayInitialize(UpVM,0.0);
   ArrayInitialize(DnVM,0.0);

//---- получение хендла индикатора iATR
   ATR_Handle=iATR(NULL,0,1);
   if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iATR");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"VortexIndicator(",VI_Length,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,MaxBar,limit,bar,kkk;
   double SumUpVM,SumDnVM,SumTR,ATR[];

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-2; // стартовый номер для расчёта всех баров
      to_copy=limit+1;
      //---- Инициализация массивов переменных
      ArrayInitialize(UpVM,NULL);
      ArrayInitialize(DnVM,NULL);
      ArrayInitialize(Count,NULL);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+1+int(VI_Length);
     }

   MaxBar=rates_total-min_rates_total-1;

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpVM[Count[0]]=MathAbs(high[bar]-low[bar+1]);
      DnVM[Count[0]]=MathAbs(low[bar]-high[bar+1]);

      if(bar>MaxBar)
        {
         Recount_ArrayZeroPos(Count);
         continue;
        }

      SumUpVM=0.0;
      SumDnVM=0.0;
      SumTR=0.0;

      for(kkk=0; kkk<int(VI_Length); kkk++)
        {
         SumUpVM+=UpVM[kkk];
         SumDnVM+=DnVM[kkk];
         SumTR+=ATR[bar+kkk];
        }

      if(SumTR)
        {
         UpBuffer[bar]=SumUpVM/SumTR;
         DnBuffer[bar]=SumDnVM/SumTR;
        }
      else
        {
         UpBuffer[bar]=EMPTY_VALUE;
         DnBuffer[bar]=EMPTY_VALUE;
        }

      if(bar) Recount_ArrayZeroPos(Count);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
