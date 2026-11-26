//+---------------------------------------------------------------------+
//|                                              XFisher_org_v1_Vol.mq5 |
//|                              Copyright © 2006, TrendLaboratory Ltd. |
//|               http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                          E-mail: igorad2004@list.ru |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
//---- авторство индикатора
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| Параметры отрисовки облака канала            |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrLavender
//---- отображение метки линии индикатора
#property indicator_label1  "XFisher_org_v1_Vol Cloud"
//+----------------------------------------------+
//| Параметры отрисовки линии сопротивления      |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Teal цвет
#property indicator_color2 clrTeal
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XFisher_org_v1_Vol Res"
//+----------------------------------------------+
//| Параметры отрисовки линии поддержки          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color3 clrRed
//---- линия индикатора - штрих-пунктир
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "XFisher_org_v1_Vol Supr"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Fisher_org_v1 |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type4   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color4  clrDodgerBlue,clrDeepPink
//---- отображение метки линии индикатора
#property indicator_label4  "XFisher_org_v1_Vol"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint FLength=7;                             // глубина усреднения
input Smooth_Method MA_SMethod=MODE_JJMA;         // Метод сглаживания
input uint MA_Length=5;                           // Глубина сглаживания                    
input int MA_Phase=15;                            // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                  
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       // ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // объём 
input int HighLevel=+150;                         // уровень перекупленности
input int LowLevel=-150;                          // уровень перепроданности
input int Shift=0;                                // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
double UpIndBuffer1[],DnIndBuffer1[];
double IndBuffer[],TriggerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=int(FLength)+1;
   min_rates_total=min_rates_1+GetStartBars(MA_SMethod,MA_Length,MA_Phase);  
//---- превращение динамического массива IndBuffer[] в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива TriggerBuffer[] в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpIndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//----   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnIndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//----
//---- превращение динамического массива IndBuffer[] в индикаторный буфер
   SetIndexBuffer(4,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива TriggerBuffer[] в индикаторный буфер
   SetIndexBuffer(5,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//----
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XFisher_org_v1_Vol(",FLength,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
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
   int first,bar;
   double smax,smin,price,wpr,value,res1,res2,fish,vol,xvol;
   static double value_prev,fish_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_1;                           // стартовый номер для расчета всех баров
      value_prev=0.0;
      IndBuffer[first-1]=fish_prev=0.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      smax=DBL_MIN;
      smin=DBL_MAX;
      //----
      for(int iii=0; iii<int(FLength); iii++)
        {
         int barx=bar-iii;
         smax=MathMax(smax,high[barx]);
         smin=MathMin(smin,low[barx]);
        }
      if(smax==smin) smax+=_Point;
      price=PriceSeries(IPC,bar,open,low,high,close);
      wpr=(price-smin)/(smax-smin);
      value=(wpr-0.5)+0.67*value_prev;
      value=MathMin(value,+DBL_MAX);
      value=MathMax(value,-DBL_MAX);
      res1=1.0-value;
      if(!res1) res1=1.0;
      res2=(1.0+value)/(1.0-value);
      if(res2<0.0000001) res2=1.0;
      fish=0.5*MathLog(res2)+0.5*fish_prev;     
      if(VolumeType==VOLUME_TICK) vol=double(tick_volume[bar]);
      else vol=double(volume[bar]);
      IndBuffer[bar]=fish*vol; //домножаем значение осциллятора на объём  
      IndBuffer[bar]=100*XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,IndBuffer[bar],bar,false);           
      xvol=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,vol,bar,false);  //усредняем объём  
      UpIndBuffer[bar]=UpIndBuffer1[bar]=HighLevel*xvol;
      DnIndBuffer[bar]=DnIndBuffer1[bar]=LowLevel*xvol;      
      TriggerBuffer[bar]=IndBuffer[bar-1];      
      //----
      if(bar<rates_total-1)
        {
         value_prev=value;
         fish_prev=fish;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
