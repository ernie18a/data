//+------------------------------------------------------------------+
//|                                             iFreeNumFractals.mq5 |
//|            Copyright © 2017, Artem A. Trishkin, Skype artmedia70 |
//|                      https://login.mql5.com/ru/users/artmedia70/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2017, Artem A. Trishkin, Skype artmedia70"
//---- ссылка на сайт автора
#property link      "https://login.mql5.com/ru/users/artmedia70/"
//---- номер версии индикатора
#property version   "3.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//---- отображение бычей метки индикатора
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован синий цвет
#property indicator_color2  clrBlueViolet
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Down Fractal"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_TYPE_FRACTAL
  {
   TYPE_FRACTAL_ACCURATE   =  0,    // Accurate fractal
   TYPE_FRACTAL_INACCURATE =  1,    // Inaccurate fractal
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TYPE_FRACTAL TypeFractals   =  TYPE_FRACTAL_ACCURATE;  // Type of fractal
input uint              LeftNumUp=2;                              // The number of bars on the left for upper fractals
int leftNumUp; // Количество баров слева для верхнего фрактала
input uint              RightNumUp=2;                             // The number of bars on the right for upper fractals
int rightNumUp;// Количество баров справа для верхнего фрактала
input uint              LeftNumDn=2;                              // The number of bars on the left for lower fractals
int leftNumDn; // Количество баров слева для нижнего фрактала
input uint              RightNumDn=2;                             // The number of bars on the right for lower fractals
int rightNumDn;// Количество баров справа для нижнего фрактала
input uint              UpLable=217;                              // лейба верхнего фрактала
input uint              DnLable=218;                              // лейба нижнего фрактала
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=int(MathMax(LeftNumUp+RightNumUp,LeftNumDn+RightNumDn));   
   leftNumUp=(int(LeftNumUp)<1?1:int(LeftNumUp));
   rightNumUp=(int(RightNumUp)<1?1:int(RightNumUp));
   leftNumDn=(int(LeftNumDn)<1?1:int(LeftNumDn));
   rightNumDn=(int(RightNumDn)<1?1:int(RightNumDn));

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Up Fractal");
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Down Fractal");
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name=MQLInfoString(MQL_PROGRAM_NAME)+"("+(string)leftNumUp+","+(string)rightNumUp+")("+(string)leftNumDn+","+(string)rightNumDn+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>fmin(rightNumUp,rightNumDn) && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      
      if(GetFreeUpperFractal(rates_total,high,bar,leftNumUp,rightNumUp)>0) UpBuffer[bar]=high[bar];
      if(GetFreeLowerFractal(rates_total,low,bar,leftNumDn,rightNumDn)>0) DnBuffer[bar]=low[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| GetFreeUpperFractal() iteration function                         |
//+------------------------------------------------------------------+
double GetFreeUpperFractal(const int Rates_Total,const double &High[],int shift,int left_dimension=2,int right_dimension=2)
  {
//---
   if(left_dimension<1) left_dimension=1;
   if(right_dimension<1) right_dimension=1;
   if(shift-right_dimension<1 || shift+left_dimension>Rates_Total-1) return(-1);
   if(TypeFractals==TYPE_FRACTAL_ACCURATE) 
     {
      for(int iii=shift-1; iii>=shift-right_dimension; iii--) if(High[iii]>High[iii+1]) return(-1);
      for(int iii=shift+1; iii<=shift+left_dimension; iii++)  if(High[iii]>High[iii-1]) return(-1);
     }
   else 
     {
      for(int iii=shift-1; iii>=shift-right_dimension; iii--) if(High[iii]>High[shift]) return(-1);
      for(int iii=shift+1; iii<=shift+left_dimension; iii++)  if(High[iii]>High[shift]) return(-1);
     }
//---
   return(High[shift]);
  }
//+------------------------------------------------------------------+
//| GetFreeLowerFractal() iteration function                         |
//+------------------------------------------------------------------+
double GetFreeLowerFractal(const int Rates_Total,const double &Low[],int shift,int left_dimension=2,int right_dimension=2)
  {
//---
   if(left_dimension<1) left_dimension=1;
   if(right_dimension<1) right_dimension=1;
   if(shift-right_dimension<1 || shift+left_dimension>Rates_Total-1) return(-1);
   if(TypeFractals==TYPE_FRACTAL_ACCURATE) 
     {
      for(int iii=shift-1; iii>=shift-right_dimension; iii--) if(Low[iii]<Low[iii+1]) return(-1);
      for(int iii=shift+1; iii<=shift+left_dimension; iii++)  if(Low[iii]<Low[iii-1]) return(-1);
     }
   else 
     {
      for(int iii=shift-1; iii>=shift-right_dimension; iii--) if(Low[iii]<Low[shift]) return(-1);
      for(int iii=shift+1; iii<=shift+left_dimension; iii++)  if(Low[iii]<Low[shift]) return(-1);
     }
//---
   return(Low[shift]);
  }
//+------------------------------------------------------------------+
