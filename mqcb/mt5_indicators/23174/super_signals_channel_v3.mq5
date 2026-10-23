//+------------------------------------------------------------------+
//|                                     Super_Signals_Channel_V3.mq5 |
//|                Copyright © 2006, Nick Bilak, beluck[AT]gmail.com |
//|                                        http://www.forex-tsd.com/ |                                      
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, Nick Bilak, beluck[AT]gmail.com"
//---- ссылка на сайт автора
#property link      "http://www.forex-tsd.com/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано семь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован цвет 185,255,228
#property indicator_color1  C'185,255,228'
//---- отображение метки индикатора
#property indicator_label1  "Upper Super_Signals_Channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован цвет 255,215,255
#property indicator_color2  C'255,215,255'
//---- отображение метки индикатора
#property indicator_label2  "Lower Super_Signals_Channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Teal цвет
#property indicator_color3  clrTeal
//---- линия индикатора 3 - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение метки линии индикатора
#property indicator_label3  "Upper Super_Signals_Channel"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Teal цвет
#property indicator_color4  clrBlue
//---- линия индикатора 4 - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение метки линии индикатора
#property indicator_label4  "Middle Super_Signals_Channel"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет Magenta
#property indicator_color5  clrMagenta
//---- линия индикатора 5 - сплошная
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора 5 равна 3
#property indicator_width5  3
//---- отображение метки линии индикатора
#property indicator_label5  "Lower Super_Signals_Channel"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Lime
#property indicator_color6  clrLime
//---- толщина индикатора 6 равна 1
#property indicator_width6  1
//---- отображение метки индикатора
#property indicator_label6  "Buy Super_Signals_Channel"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде значка
#property indicator_type7   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Red
#property indicator_color7  clrRed
//---- толщина индикатора 7 равна 1
#property indicator_width7  1
//---- отображение метки индикатора
#property indicator_label7  "Sell Super_Signals_Channel"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint  SignalGap=4;
input uint  dist=24;                // величина заскока в будущее
input bool  repaint = false;        // перерисовка
input int   Shift=0;                // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpUpBuffer[];
double UpDnBuffer[];
double DnUpBuffer[];
double DnDnBuffer[];
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferMiddle[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];

double dSignalGap;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,dist2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(dist+1);
   dSignalGap=SignalGap*_Point;
   dist2=int(dist/2);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpDnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpUpBuffer,true);
   ArraySetAsSeries(UpDnBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DnDnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnUpBuffer,true);
   ArraySetAsSeries(DnDnBuffer,true);

//---- превращение динамического массива ExtMapBufferUp[] в индикаторный буфер
   SetIndexBuffer(4,ExtMapBufferUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамического массива ExtMapBufferUp[] в индикаторный буфер
   SetIndexBuffer(5,ExtMapBufferMiddle,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferMiddle,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива ExtMapBufferDown[] в индикаторный буфер
   SetIndexBuffer(6,ExtMapBufferDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива ExtMapBufferUp1[] в индикаторный буфер
   SetIndexBuffer(7,ExtMapBufferUp1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,108);

//---- превращение динамического массива ExtMapBufferDown1[] в индикаторный буфер
   SetIndexBuffer(8,ExtMapBufferDown1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- символ для индикатора
   PlotIndexSetInteger(6,PLOT_ARROW,108);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Super_Signals_Channel_V3(",SignalGap,", ",dist,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int hhb,llb,limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated+dist2;           // стартовый номер для расчета новых баров
     }

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;
      uint barx;
      //----
      if(repaint) barx=MathMax(bar-dist2,0);
      else barx=bar;
      //----
      hhb=ArrayMaximum(high,barx,dist);
      llb=ArrayMinimum(low,barx,dist);
      //----
      if(bar==hhb) ExtMapBufferUp1[bar]=high[hhb]+dSignalGap;
      if(bar==llb) ExtMapBufferDown1[bar]=low[llb]-dSignalGap;
      //----
      ExtMapBufferUp[bar]=UpUpBuffer[bar]=high[hhb];//+SignalGap*Point;
      ExtMapBufferMiddle[bar]=UpDnBuffer[bar]=DnUpBuffer[bar]=(high[hhb]+low[llb])/2;
      ExtMapBufferDown[bar]=DnDnBuffer[bar]=low[llb];//-SignalGap*Point;
      
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
