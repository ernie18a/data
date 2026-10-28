//+------------------------------------------------------------------+
//|                                                  XprofuterDD.mq5 |
//|                                                                  |
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"

//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использован три буфера
#property indicator_buffers 3
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Signal"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
///---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "MA"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
///---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color3  clrTeal
//---- линия индикатора - штрихпунктир
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Signal2"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint per       = 14;  // Число баров для прогноза
input uint drawShift = 14;  // Количество баров для прогноза
input uint maPeriod  = 34;  // Период усреднения
//+-----------------------------------+

//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer1[];
double ExtLineBuffer2[];
double ExtLineBuffer3[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(per+maPeriod);

//---- превращение динамического массива ExtLineBuffer1 в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на drawShift
   PlotIndexSetInteger(0,PLOT_SHIFT,drawShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);

//---- превращение динамического массива ExtLineBuffer2 в индикаторный буфер
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на drawShift
   PlotIndexSetInteger(1,PLOT_SHIFT,drawShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- превращение динамического массива ExtLineBuffer3 в индикаторный буфер
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на drawShift
   PlotIndexSetInteger(2,PLOT_SHIFT,drawShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer3,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XprofuterDD(",per," ,",drawShift," ,",maPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление локальных переменных
   int limit,bar,lim;
   double imp;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else limit=int(rates_total-prev_calculated+per); // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(int(bar-per)<0) lim=0;
      else lim=int(bar-per);

      imp=0;
      for(int i=bar; i>=lim; i--) imp+=(close[i]-open[i])/_Point;
      ExtLineBuffer1[bar]=imp;
      ExtLineBuffer3[bar]=(close[bar]-open[bar])/_Point;
      
      imp=0;
      for(int i=bar; i<int(bar+maPeriod); i++) imp+=ExtLineBuffer1[i];
      ExtLineBuffer2[bar]=imp/maPeriod;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
