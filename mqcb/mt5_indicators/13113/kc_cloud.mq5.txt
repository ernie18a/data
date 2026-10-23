//+------------------------------------------------------------------+ 
//|                                                     KC_Cloud.mq5 | 
//|                                     Copyright © 2007, John Smith | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, John Smith"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrPaleGreen
//---- отображение метки индикатора
#property indicator_label1  "KC_Cloud"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum PriceMode
  {
   MODE_CLOSE,    //Close
   MODE_HIGHLOW   //High/Low
  };
//---
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
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input PriceMode Mode=MODE_HIGHLOW; // Метод расчета цен
//---- параметры скользящего среднего
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input int XLength=12; // Глубина сглаживания                    
input int XPhase=15;  // Параметр сглаживания
                      // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                      // для VIDIA это период CMO, для AMA это период медленной скользящей
//---- параметры ATR
input uint              ATRPeriod=13;
input double            ATRFactor=1.5;
input int               Shift=0;      // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtHBuffer[],ExtLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(GetStartBars(XMA_Method,XLength,XPhase),ATRPeriod));
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtHBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtLBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- инициализация переменной для короткого имени индикатора
   string shortname="KC_Cloud";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double ATR[1];
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---
   if(Mode==MODE_HIGHLOW)
     {
      static CXMA HXMA,LXMA;
      //---- основной цикл расчета индикатора
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
        {
         //---- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         double res=ATRFactor*ATR[0];
         ExtHBuffer[bar]=HXMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,high[bar],bar,false)+res;
         ExtLBuffer[bar]=LXMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,low[bar],bar,false)-res;
        }
     }
   else
     {
      static CXMA XMA;
      //---- основной цикл расчета индикатора
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
        {
         //---- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         double xma=XMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,close[bar],bar,false);
         double res=ATRFactor*ATR[0];
         ExtHBuffer[bar]=xma+res;
         ExtLBuffer[bar]=xma-res;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
