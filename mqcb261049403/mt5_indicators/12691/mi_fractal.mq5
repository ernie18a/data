//+------------------------------------------------------------------+
//|                                                   MI_Fractal.mq5 |
//|                                    Copyright © 2009 Орешкин А.В. |
//|                                        http://www.vk.com/mtforex |
//+------------------------------------------------------------------+
#property description "Фракталы с возможностью выбора количества свеч по бокам"
//--- авторство индикатора
#property copyright "Copyright © 2009 Орешкин А.В."
//--- ссылка на сайт автора
#property link      "http://www.vk.com/mtforex"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки верхнего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета индикатора использован MediumSeaGreen цвет
#property indicator_color1  clrMediumSeaGreen
//--- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//--- отображение бычей метки индикатора
#property indicator_label1  "Up MI_Fractal"
//+----------------------------------------------+
//| Параметры отрисовки нижнего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета индикатора использован Tomato цвет
#property indicator_color2  clrTomato
//--- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Down MI_Fractal"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint LeftCount=10; // Количество свечей слева
input uint RightCount=2; // Количество свечей справа
input uint MinDiff=10;   // Минимально допустимое расстояние от экстремумов до пиков 
input int  UpLable=217;  // Метка верхнего фрактала
input int  DnLable=218;  // Метка нижнего фрактала
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
//---
double dMinDiff;
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   dMinDiff=MinDiff*_Point;
   int ATR_Period=10;
   min_rates_total=int(MathMax(ATR_Period,LeftCount+RightCount));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="MI_Fractal";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit;
   double ATR[];
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated+2; // стартовый номер для расчета новых баров
     }
   to_copy=limit+min_rates_total;
//--- копируем вновь появившиеся данные в массив
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bool UP_Fractal=true;
      bool DOWN_Fractal=true;
      //---
      for(int index=bar+int(LeftCount); index>=bar-int(RightCount); index--)
        {
         if(index==bar) continue;
         if(high[bar]-high[index]<dMinDiff) UP_Fractal=false;
         if(low[index]-low[bar]<dMinDiff) DOWN_Fractal=false;
        }
      //---
      UpBuffer[bar]=0.0;
      DnBuffer[bar]=0.0;
      //---
      if(UP_Fractal && !DOWN_Fractal) UpBuffer[bar]=high[bar]+ATR[bar]*3/8;
      if(!UP_Fractal && DOWN_Fractal) DnBuffer[bar]=low[bar]-ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
