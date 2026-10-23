//+------------------------------------------------------------------+
//|                                                 i-FractalsEx.mq5 |
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, RickD"
//--- ссылка на сайт автора
#property link      "www.e2e-fx.net"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки верхнего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета индикатора использован HotPink цвет
#property indicator_color1  clrHotPink
//--- толщина линии индикатора 1 равна 5
#property indicator_width1  5
//--- отображение бычей метки индикатора
#property indicator_label1  "Down Fractal"
//+----------------------------------------------+
//| Параметры отрисовки нижнего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 5
#property indicator_width2  5
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Up Fractal"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Fr_Period=6;     // Количество свечек 
input int  UpLabel=176;     // Код символа верхнего фрактала
input int  DnLabel=176;     // Код символа нижнего фрактала
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double DnBuffer[];
double UpBuffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=int(Fr_Period+1+Fr_Period);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLabel);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLabel);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="i-FractalsEx";
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
   if(rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int limit;
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated+int(Fr_Period); // стартовый номер для расчёта новых баров
     }
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      if(is_upper_fr(rates_total,high,Fr_Period,bar)) UpBuffer[bar]=high[bar];
      if(is_lower_fr(rates_total,low,Fr_Period,bar)) DnBuffer[bar]=low[bar];
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| is_upper_fr                                                      |
//+------------------------------------------------------------------+
bool is_upper_fr(int Rates_Total,const double &High[],int period,int shift)
  {
//---
   if(shift+period >= Rates_Total || shift-period < 0) return (false);
   for(int iii=1; iii<=period; iii++)
     {
      if(High[shift] < High[shift+iii]) return (false);
      if(High[shift] < High[shift-iii]) return (false);
     }
//---
   return (true);
  }
//+------------------------------------------------------------------+
//| is_lower_fr                                                      |
//+------------------------------------------------------------------+
bool is_lower_fr(int Rates_Total,const double &Low[],int period,int shift)
  {
//---
   if(shift+period >= Rates_Total || shift-period < 0) return (false);
   for(int iii=1; iii<=period; iii++)
     {
      if(Low[shift] > Low[shift+iii]) return (false);
      if(Low[shift] > Low[shift-iii]) return (false);
     }
//---
   return (true);
  }
//+------------------------------------------------------------------+
