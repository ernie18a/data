//+------------------------------------------------------------------+
//|                                                  TrendlessAG.mq5 |
//|                                       Copyright © 2012, Barmaley | 
//|                                                                  | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2012, Barmaley"
//--- ссылка на сайт автора
#property link ""
#property description "Осциллятор Бестрендовости написан в соответствии с описанием,"
#property description "приведенным в книге Джо ДиНаполи \"Торговля с применением уровней ДиНаполи\""
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 1
//--- использовано два графических построения
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "TrendlessAG"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +100
#property indicator_level2 +80
#property indicator_level3 +60
#property indicator_level4  0
#property indicator_level5 -60
#property indicator_level6 -80
#property indicator_level7 -100
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint MAPeriod=7;                          // Период скользящей средней в формуле осциллятора
input  ENUM_MA_METHOD   MAType=MODE_EMA;        // Метод усреднения скользящей средней в формуле осциллятора
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE; // Входная цена скользящей средней в формуле осциллятора
input uint PointsCount=600;                     // Количество точек для расчета индикатора. Форекс-клуб рекомендует месяц для часовиков
input uint In100=90;                            // Сколько % точек индикатора должны входить в интервал +-100%
input int  Shift=0;                             // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
//--- объявление глобальных переменных
int Count[],Start;
double Value[],Sort[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle;
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//---
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
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(PointsCount+MAPeriod);
   Start=int(PointsCount*In100/100);
//--- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,PointsCount);
   ArrayResize(Value,PointsCount);
   ArrayResize(Sort,PointsCount);
//---
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);   
//--- превращение динамического массива PVIBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendlessAG");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявление локальных переменных
   int to_copy,limit,bar;
   double Ma[];
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=int(rates_total-MAPeriod-1);   // расчетное количество всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Ma,true);
   ArraySetAsSeries(close,true);
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MA_Handle,0,0,to_copy,Ma)<=0) return(RESET);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {     
      double Res=close[bar]-Ma[bar];
      Value[Count[0]]=MathAbs(Res);     
      if(bar>0) Recount_ArrayZeroPos(Count,PointsCount);      
      if(bar>rates_total-min_rates_total-1) continue;      
      ArrayCopy(Sort,Value,0,0,WHOLE_ARRAY);
      ArraySort(Sort);      
      double level_100=Sort[Start];
      if(level_100) Res*=100/(level_100);
      else Res=EMPTY_VALUE;   
      IndBuffer[bar]=Res;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
