//+------------------------------------------------------------------+ 
//|                                                  ColorStdDev.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов диаграммы индикатора использованы
#property indicator_color1 clrGray,clrBlue,clrRed,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "StdDev"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint period = 12;                               // Период усреднения
input ENUM_MA_METHOD MA_Method=MODE_EMA;              // Метод усреднения гистограммы
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE;  // Ценовая константа
input uint MaxTrendLevel=100;                         // Уровень максимального тренда
input uint MiddLeTrendLevel=40;                       // Уровень умеренного тренда
input uint FlatLevel=10;                              // Уровень флета
//+-----------------------------------+
//---- индикаторныe буферы
double StdDevBuffer[],ColorBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int StdDev_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| StdDev indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(period);
//---- получение хендла индикатора RSI
   StdDev_Handle=iStdDev(NULL,0,period,0,MA_Method,applied_price);
   if(StdDev_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора StdDev");
//---- превращение динамического массива StdDevBuffer в индикаторный буфер
   SetIndexBuffer(0,StdDevBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(StdDevBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorStdDev( ",period," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,MaxTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddLeTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,FlatLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Blue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Gray);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| StdDev iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(BarsCalculated(StdDev_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление целочисленных переменных
   int limit,to_copy,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      limit=rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(StdDev_Handle,0,0,to_copy,StdDevBuffer)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      StdDevBuffer[bar]/=_Point;
      ColorBuffer[bar]=0;
      if(StdDevBuffer[bar]>MaxTrendLevel) ColorBuffer[bar]=3;
      else if(StdDevBuffer[bar]>MiddLeTrendLevel) ColorBuffer[bar]=2;
      else if(StdDevBuffer[bar]>FlatLevel) ColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
