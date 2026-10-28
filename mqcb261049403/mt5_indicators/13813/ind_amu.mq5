//+------------------------------------------------------------------+
//|                                                      ind_aMU.mq5 |
//|                             Copyright © 2012, Yuriy Tokman (YTG) |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2012, Yuriy Tokman (YTG)"
//---- ссылка на сайт автора
#property link      "yuriytokman@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор указывает на трендовые и боковые (флет) движения цены"
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано 2 буфера
#property indicator_buffers 2
//---- использовано всего 1 графическое построение
#property indicator_plots   1
//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_ZIGZAG
//---- отображение метки индикатора
#property indicator_label1  "ind_aMU"
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - длинный пунктир
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint              FastPeriod = 12;
input uint              SlowPeriod = 21;
input  ENUM_MA_METHOD       MAType = MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice = PRICE_CLOSE;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SlowBuffer[];
double FastBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(FastPeriod,SlowPeriod));
//---- получение хендла индикатора Fast iMA
   SlMA_Handle=iMA(Symbol(),PERIOD_CURRENT,FastPeriod,0,MAType,MAPrice);
   if(SlMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fast iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Slow iMA
   FsMA_Handle=iMA(Symbol(),PERIOD_CURRENT,SlowPeriod,0,MAType,MAPrice);
   if(FsMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Slow iMA");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,FastBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SlowBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(FastBuffer,true);
   ArraySetAsSeries(SlowBuffer,true);
//---- установка позиции, с которой начинается отрисовка индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для подокон 
   string shortname;
   StringConcatenate(shortname,"ind_aMU(",FastPeriod,",",SlowPeriod,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy;
//---- расчет стартового номера limit для цикла пересчета баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      to_copy=rates_total-min_rates_total+1; // стартовый номер для расчета всех баров
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // стартовый номер для расчета новых баров
     }
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FastBuffer)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlowBuffer)<=0) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
