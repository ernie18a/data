//+------------------------------------------------------------------+
//|                                                      WASD_FR.mq5 |
//|                                           Copyright © 2015, WASD |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property description "Фракталы строятся по 3 предыдущим барам (они не перерисовываются т.к. текущий бар не участвует в расчете)"
//--- авторство индикатора
#property copyright "Copyright © 2015, WASD"
//--- ссылка на сайт автора
#property link      "https://forge.mql5.io"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Параметры отрисовки верхнего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//| Параметры отрисовки нижнего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Down Fractal"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int  UpLable=217; // Метка верхнего фрактала
input int  DnLable=218; // Метка нижнего фрактала
input double Range=0.1; // Отступ фрактала от свечи в значениях ATR
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
//---
int min_rates_total;
int ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,4));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="WASD_FR";
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
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit;
   double ATR[];
//--- расчёты необходимого количества копируемых данных и
//--- стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated+2; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы UpFractal и DnFractal
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
//--- основной цикл расчёта индикатора
   for(int bar=2; bar<=limit && !IsStopped(); bar++)
     {
      UpBuffer[bar+1]=EMPTY_VALUE;
      DnBuffer[bar+1]=EMPTY_VALUE;
      if(low[bar+1]<low[bar] && low[bar+1]<low[bar+2]) DnBuffer[bar+1]=low[bar+1]-ATR[bar]*Range;
      if(high[bar+1]>high[bar] && high[bar+1]>high[bar+2]) UpBuffer[bar+1]=high[bar+1]+ATR[bar]*Range;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
