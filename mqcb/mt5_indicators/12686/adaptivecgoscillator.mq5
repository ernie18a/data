//+------------------------------------------------------------------+
//|                                         AdaptiveCGOscillator.mq5 |
//|                                                                  |
//| Adaptive CG Oscillator                                           |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Coded by Witold Wozniak"
//--- авторство индикатора
#property link      "www.mqlsoft.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора CG            |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  Red
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Adaptive CG Oscillator"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Trigger       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  Blue
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET 0 // Rонстанта для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;  // Коэффициент усреднения индикатора 
input int Shift=0;        // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ACGBuffer[];
double TriggerBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int CP_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=1;
//--- получение хендла индикатора CyclePeriod
   CP_Handle=iCustom(NULL,0,"CyclePeriod",Alpha);
   if(CP_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора CyclePeriod");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ACGBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Adaptive CG Oscillator(",DoubleToString(Alpha,4),", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
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
   if(BarsCalculated(CP_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int first,bar,intperiod;
   double price,Num,Denom,period[1];
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- копируем вновь появившиеся данные в массив
      if(CopyBuffer(CP_Handle,0,rates_total-1-bar,1,period)<=0) return(RESET);
      intperiod=int(MathFloor(period[0]/2.0));
      //---
      Num=0.0;
      Denom=0.0;
      if(bar<intperiod) intperiod=bar; // урезание усреднения до действительного числа баров
      //---
      for(int count=0; count<intperiod; count++)
        {
         price=(high[bar-count]+low[bar-count])/2.0;
         Num += (1.0 + count) * price;
         Denom+=price;
        }
      //---
      if(Denom!=0.0) ACGBuffer[bar]=-Num/Denom+(intperiod+1.0)/2.0;
      else           ACGBuffer[bar]=EMPTY_VALUE;
      //---
      TriggerBuffer[bar]=ACGBuffer[bar-1];
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
