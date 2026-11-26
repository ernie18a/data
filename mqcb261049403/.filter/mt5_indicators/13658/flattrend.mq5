//+---------------------------------------------------------------------+
//|                                                      Flat-Trend.mq5 | 
//|                                            Copyright © 2009, Sergey | 
//|                                                  http://wsforex.ru/ | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, Sergey"
#property link "http://wsforex.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrGray,clrBlueViolet,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Flat-Trend"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint StDevPeriod=20; // Период StDev 
input Smooth_Method StDev_Method=MODE_LWMA; // Метод усреднения StDev
input uint StDevLength=5; // Глубина сглаживания StDev
input int StDevPhase=15;  // Параметр сглаживания StDev
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                          // для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ATRPeriod=20;  // Период StDev
input Smooth_Method ATR_Method=MODE_LWMA; // Метод усреднения ATR
input uint ATRLength=5; // Глубина сглаживания ATR
input int ATRPhase=15;  // Параметр сглаживания ATR
                        // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                        // для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle,StDev_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Flat-Trend indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   int min_rate_1=int(StDevPeriod)+XMA1.GetStartBars(StDev_Method,StDevLength,StDevPhase);
   int min_rate_2=int(ATRPeriod)+XMA2.GetStartBars(ATR_Method,ATRLength,ATRPhase);
//----
   min_rates_total=MathMax(min_rate_1,min_rate_2)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("StDevLength",StDevLength);
   XMA2.XMALengthCheck("ATRLength",ATRLength);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("StDevPhase",StDevPhase,StDev_Method);
   XMA2.XMAPhaseCheck("ATRPhase",ATRPhase,ATR_Method);
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- получение хендла индикатора StdDev
   StDev_Handle=iStdDev(NULL,PERIOD_CURRENT,ATRPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(StDev_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора StdDev");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ColorIndBuffer,true);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Flat-Trend");
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации 
  }
//+------------------------------------------------------------------+ 
//| Flat-Trend iteration function                                    | 
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(StDev_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double StDev[],ATR[],xatr,xstdev;
//---- объявление целочисленных переменных
   int to_copy,limit,bar,maxbar1,maxbar2,res;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(StDev,true);
   ArraySetAsSeries(ATR,true);
//---- объявление статических переменных
   static double prev_xatr,prev_xstdev;
//----
   maxbar1=int(rates_total-ATRPeriod-1);
   maxbar2=int(rates_total-StDevPeriod-1);
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
      prev_xatr=0.0;
      prev_xstdev=0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//----   
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(StDev_Handle,0,0,to_copy,StDev)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- два вызова функции XMASeries
      //---- во втором вызове параметр begin увеличен на StartBars1, т.к. это повторное XMA сглаживание
      xatr=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,ATR_Method,ATRPhase,ATRLength,ATR[bar],bar,true);
      xstdev=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,StDev_Method,StDevPhase,StDevLength,StDev[bar],bar,true);
      //----       
      res=0;
      if(prev_xatr>xatr && prev_xstdev>xstdev) res=1;
      if(prev_xatr<xatr && prev_xstdev<xstdev) res=2;
      //----
      IndBuffer[bar]=res+1;
      ColorIndBuffer[bar]=res;
      //---- сохранение значений переменных перед многократным прогоном на текущем баре
      if(bar)
        {
         prev_xatr=xatr;
         prev_xstdev=xstdev;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
