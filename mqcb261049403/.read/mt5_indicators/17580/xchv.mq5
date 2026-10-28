//+---------------------------------------------------------------------+
//|                                                            XCHV.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Chaikin Volatility"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован бледно-синий цвет
#property indicator_color1 clrSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "XCHV"

//+-----------------------------------+
//| Описание классов CXMA и CMomentum |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных классов CXMA и CMomentum из файла SmoothAlgorithms.mqh
CXMA XMA;
CMomentum MOM;
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method //перечисление объявлено в файле SmoothAlgorithms.mqh
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int SmoothPeriod=10;  //период усреднения
input int Phase_=15;   //параметр усреднения,
  //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  // Для VIDIA это период CMO, для AMA это период медленной скользящей
input int CHVPeriod=10;     // CHV период
input Smooth_Method SmoothMethod=MODE_T3; //метод усреднения
input int Shift=0; //сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double XCHV[];
//---- Объявление целых переменных начала отсчёта данных
int StartBars;
//+------------------------------------------------------------------+   
//| XCHV indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBars=CHVPeriod+XMA.GetStartBars(SmoothMethod,SmoothPeriod,Phase_);   
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("SmoothPeriod", SmoothPeriod);
   XMA.XMALengthCheck("CHVPeriod", CHVPeriod);
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMAPhaseCheck("Phase_", Phase_, SmoothMethod);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XCHV,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XCHV");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname, Smooth=XMA.GetString_MA_Method(SmoothMethod);
   StringConcatenate(shortname,"Chaikin Volatility(",string(SmoothPeriod),",",string(CHVPeriod),",",Smooth,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XCHV iteration function                                          | 
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
   if(rates_total<StartBars) return(0);

//---- Объявление переменных с плавающей точкой  
   double velue,xvelue,mom,dmom;
//---- Объявление целых переменных
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      velue=high[bar]-low[bar];

      //---- Один вызов функции XMASeries и один вызов функции MomentumSeries 
      xvelue=XMA.XMASeries(0,prev_calculated,rates_total,SmoothMethod,Phase_,SmoothPeriod,velue,bar,false);
      mom = MOM.MomentumSeries(SmoothPeriod, prev_calculated, rates_total, CHVPeriod, xvelue, bar, false);
      dmom=xvelue-mom;

      //---- инициализация индикаторного буфера
      if(bar<StartBars)
        {
         XCHV[bar]=EMPTY_VALUE;
         continue;
        }
      else if(dmom!=0.0) XCHV[bar]=100.0*mom/(dmom);
      else XCHV[bar]=EMPTY_VALUE;;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
