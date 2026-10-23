//+------------------------------------------------------------------+
//|                                               PChannel3Cloud.mq5 |
//|                                           Copyright © 2005, Xaoc |
//|                                             http://forex.xcd.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Xaoc"
#property link      "http://forex.xcd.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//--- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован PaleGreen
#property indicator_color1  clrPaleGreen
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхней границы         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычьей линии индикатора использован зеленый цвет
#property indicator_color2  clrTeal
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычьей метки индикатора
#property indicator_label2  "TOPBAND"
//+----------------------------------------------+
//|  Параметры отрисовки средней линии           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "MIDBAND"
//+----------------------------------------------+
//|  Параметры отрисовки нижней границы          |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color4  clrRed
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "BOTBAND"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован Pink
#property indicator_color5  clrPink
//---- отображение метки индикатора
#property indicator_label5  "Upper Cloud"
//+----------------------------------------------+
//|  Входные параметры индикатора                |
//+----------------------------------------------+
input uint   PCPeriod=55;
input int    Shift=0;     // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtUp1Buffer[];
double ExtUp2Buffer[];
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtDn1Buffer[];
double ExtDn2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(PCPeriod);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtUp1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtUp1Buffer,true);
   ArraySetAsSeries(ExtUp2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtCBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtCBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtDn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtDn2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtDn1Buffer,true);
   ArraySetAsSeries(ExtDn2Buffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"PChannel3("+string(PCPeriod)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление целочисленных переменных
   int limit;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtABuffer[bar]=High[ArrayMaximum(High,bar,PCPeriod)];
      ExtCBuffer[bar]=Low[ArrayMinimum(Low,bar,PCPeriod)];
      ExtBBuffer[bar]=(ExtABuffer[bar]+ExtCBuffer[bar])/2.0;
      ExtUp1Buffer[bar]=ExtABuffer[bar];
      ExtUp2Buffer[bar]=ExtBBuffer[bar];
      ExtDn1Buffer[bar]=ExtBBuffer[bar];
      ExtDn2Buffer[bar]=ExtCBuffer[bar];
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
