//+------------------------------------------------------------------+
//|                                            StohasticWithFlat.mq5 |
//|                                 Copyright © 2014, Powered byStep | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property description "Stochastic indicator With Flat"
//--- авторство индикатора
#property copyright "Copyright © 2014, Powered byStep"
//--- авторство индикатора
#property link      ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора CG            |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован Orchid цвет
#property indicator_color1  clrOrchid
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Stohastic Oscillator"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Signal        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  +75
#property indicator_level2  +50
#property indicator_level3  +25
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Ограничение размеров высоты окна индикатора  |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint                BBPeriod=20;                 // Период для расчета Боллинджера
input double              StdDeviation=2.0;            // Кол-во отклонений Боллинджера
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE;   // Тип цены Боллинджера
input uint KPeriod=5;
input uint DPeriod=3;
input uint Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
input uint flat=100;       // Величина флэта в пунктах
input int Shift=0;         // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
double SignalBuffer[];
//--- объявление целых переменных для хендлов индикаторов
int BB_Handle,STO_Handle;
//--- объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(BBPeriod,KPeriod+DPeriod+Slowing));
//--- получение хендла индикатора iBands
   BB_Handle=iBands(Symbol(),PERIOD_CURRENT,BBPeriod,0,StdDeviation,applied_price);
   if(BB_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iBands");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iStochastic
   STO_Handle=iStochastic(Symbol(),PERIOD_CURRENT,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(STO_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SignalBuffer,true);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME,"StohasticWithFlat");
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
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(BB_Handle)<rates_total || BarsCalculated(STO_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double MainSTO[],SignSTO[],UpBB[],MainBB[];
//--- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(BB_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(BB_Handle,BASE_LINE,0,to_copy,MainBB)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,MainSTO)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,SIGNAL_LINE,0,to_copy,SignSTO)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(MainBB,true);
   ArraySetAsSeries(MainSTO,true);
   ArraySetAsSeries(SignSTO,true);
//--- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double res=(UpBB[bar]-MainBB[bar])/_Point;
      if(res<flat)
        {
         if(MainSTO[bar]>SignSTO[bar])
           {
            IndBuffer[bar]=55;
            SignalBuffer[bar]=45;
           }
         if(MainSTO[bar]<SignSTO[bar])
           {
            IndBuffer[bar]=45;
            SignalBuffer[bar]=55;
           }
        }
      else
        {
         IndBuffer[bar]=MainSTO[bar];
         SignalBuffer[bar]=SignSTO[bar];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
