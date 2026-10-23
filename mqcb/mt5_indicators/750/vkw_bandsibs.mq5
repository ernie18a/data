//+---------------------------------------------------------------------+
//|                                                    VKW_BandsIBS.mq5 | 
//|                                              Copyright © 2008, Rosh | 
//|                 http://www.investo.ru/forum/viewtopic.php?t=127513/ | 
//+---------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh следует положить    |
//| в папку (директорию): terminal_data_folder\MQL5\Include             |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, Rosh"
#property link "http://www.investo.ru/forum/viewtopic.php?t=127513/"
#property description "Internal Bar Strength"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет DodgerBlue
#property indicator_color1 DodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Internal Bar Strength"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет DodgerBlue
#property indicator_color2 LimeGreen
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "VKW_Bands Upper"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет DodgerBlue
#property indicator_color3 DeepPink
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "VKW_Bands Lower"
//+-----------------------------------+
//| Параметры уровней                 |
//+-----------------------------------+
#property indicator_level1 60
#property indicator_level2 40
#property indicator_levelcolor Magenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+-----------------------------------+
//|  Объявление перечислений          |
//+-----------------------------------+
enum Applied_price_     // Тип константы
  {
   PRICE_CLOSE_LOW,     // Close-Low
   PRICE_HIGH_CLOSE     // High-Close
  };
//+-----------------------------------+
//|  Объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method IMA_Method=MODE_SMA_;  // Метод усреднения IBS
input int ILength=5;                       // Глубина усреднения IBS                    
input int IPhase=15;                       // Параметр усреднения IBS
input Applied_price_ IPC=PRICE_HIGH_CLOSE; // Ценовая константа IBS
input int IShift=0;                        // Сдвиг индикатора IBS по горизонтали в барах
input bool IDirect=true;                   // Переворот индикатора по вертикали

extern uint RPeriod=25;                    // Период поиска экстремумов
input Smooth_Method SmMA_Method=MODE_SMA_; // Метод сглаживания
input int SLength=3;                       // Глубина сглаживания
input int SPhase=100;                      // Параметр сглаживания
input int SShift=0;                        // Сдвиг индикатора канала по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые в дальнейшем 
//---- будут использованы в качестве индикаторных буферов
double XIBS[],UpVKWB[],DnVKWB[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_ibs,min_rates_extr;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_ibs=XMA1.GetStartBars(IMA_Method,ILength,IPhase);
   min_rates_extr=int(min_rates_ibs+RPeriod);
   min_rates_total=min_rates_extr+XMA1.GetStartBars(SmMA_Method,SLength,SPhase);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("ILength", ILength);
   XMA1.XMAPhaseCheck("IPhase", IPhase, IMA_Method);
   XMA1.XMALengthCheck("SLength", SLength);
   XMA1.XMAPhaseCheck("SPhase", SPhase, SmMA_Method);

//---- превращение динамического массива XIBS[] в индикаторный буфер
   SetIndexBuffer(0,XIBS,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,IShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_ibs);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива UpVKWB[] в индикаторный буфер
   SetIndexBuffer(1,UpVKWB,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,SShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива DnVKWB[] в индикаторный буфер
   SetIndexBuffer(2,DnVKWB,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,SShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- инициализации переменной для короткого имени индикатора
   string shortname="VKW_BandsIBS";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(0);

//---- объявление переменных с плавающей точкой  
   double range,dprice,ibs,n_max=NULL,n_min=NULL;
//---- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(IPC) dprice=close[bar]-low[bar];
      else    dprice=high[bar]-close[bar];

      range=high[bar]-low[bar];

      if(range) ibs=dprice/range;
      else      ibs=dprice/_Point;

      XIBS[bar]=100*XMA1.XMASeries(0,prev_calculated,rates_total,IMA_Method,IPhase,ILength,ibs,bar,false);
      if(!IDirect) XIBS[bar]*=-1;

      if(bar>min_rates_extr+1)
        {
         ArraySetAsSeries(XIBS,true);
         int rate_=rates_total-1-bar;
         n_max=XIBS[ArrayMaximum(XIBS,rate_,RPeriod)];
         n_min=XIBS[ArrayMinimum(XIBS,rate_,RPeriod)];
         ArraySetAsSeries(XIBS,false);
        }

      UpVKWB[bar]=XMA2.XMASeries(min_rates_extr,prev_calculated,rates_total,SmMA_Method,SPhase,SLength,n_max,bar,false);
      DnVKWB[bar]=XMA3.XMASeries(min_rates_extr,prev_calculated,rates_total,SmMA_Method,SPhase,SLength,n_min,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

   