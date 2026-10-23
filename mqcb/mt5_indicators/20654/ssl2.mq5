//+---------------------------------------------------------------------+
//|                                                            SSL2.mq5 | 
//|                                           Copyright © 2008, Kalenzo | 
//|                                         bartlomiej.gorski@gmail.com | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, Kalenzo"
#property link "bartlomiej.gorski@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использованы
#property indicator_color1  clrAquamarine,clrViolet
//---- отображение метки индикатора
#property indicator_label1  "SSL"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA UpXMA1,DnXMA1,UpXMA2,DnXMA2;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA_; //метод усреднения
input uint XLength1=12;                    //глубина сглаживания первого мувинга
input uint XLength2=26;                    //глубина сглаживания второго мувинга                                      
input int XPhase=15;                      //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   //cдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(XMA_Method,MathMax(XLength1,XLength2),XPhase);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- превращение динамического массива DiPlusBuffer в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);

//---- превращение динамического массива DiMinusBuffer в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);

//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=UpXMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"SSL(",XLength1,", ",XLength2,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

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

//---- Объявление переменных с плавающей точкой  
   double upxma,dnxma,ssl1,ssl2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      upxma=UpXMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,high[bar],bar,false);
      dnxma=DnXMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,low[bar],bar,false);     
      if(close[bar]<dnxma) ssl1=upxma;
      else ssl1=dnxma;
      //----
      upxma=UpXMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,high[bar],bar,false);
      dnxma=DnXMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,low[bar],bar,false);     
      if(close[bar]<dnxma) ssl2=upxma;
      else ssl2=dnxma;
      //----
      UpIndBuffer[bar]=ssl1+dPriceShift;
      DnIndBuffer[bar]=ssl2+dPriceShift;
      
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
