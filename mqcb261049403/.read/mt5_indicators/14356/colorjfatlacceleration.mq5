/*
 * Для работы  индикатора  следует  положить файл
 * SmoothAlgorithms.mqh
 * в папку (директорию): MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                       ColorJFatlAcceleration.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано всего два графических построения
#property indicator_plots   2

//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цветов индикатора использован серый цвет
#property indicator_color1  Gray
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "JFATL Acceleration"

//---- отрисовка индикатора в виде значка
#property indicator_type2   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы серый, сизый и красный цвета
#property indicator_color2  Gray,DarkOrchid,Red
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "JFATL Acceleration"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPLE_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  //PRICE_TRENDFOLLOW1_
  };
input int SmLength_=8; // Период JMA сглаживания Fatl                   
input int SmPhase_=100; // Параметр JMA сглаживания Fatl,
                      //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;

input int SpeedPeriod=1;//Период скорости
input int AccelerationPeriod=1;//Период ускорения

input int Smooth=2; // Глубина JMA сглаживания индикатора                  
input int SmPhase=100; // Параметр JMA сглаживания индикатора,
                       //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;

input Applied_price_ IPC=PRICE_CLOSE_;//Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input int FATLShift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление и инициализация переменной для хранения количества расчетных баров FATL
int FATLPeriod=39;

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorBuffer[];
double LineIndBuffer[];

int start,fstart,jfstart,mstart,spstart,FATLSize;
double dPriceShift;
//+------------------------------------------------------------------+
// Описание функции iPriceSeries()                                   |
// Описание классов CFATL, CJJMA и CMomentum                         |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных
   fstart=FATLPeriod;
   jfstart=fstart+30;
   mstart=jfstart+SpeedPeriod;
   spstart=mstart+30+1;
   start=spstart+AccelerationPeriod;

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,LineIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(1,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JFATL Speed(",SmLength_," ,",SmPhase_," ,",SpeedPeriod,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMALengthCheck("Length_", SmLength_);
   JMA.JJMAPhaseCheck("Phase_", SmPhase_);
   JMA.JJMALengthCheck("SpeedMomPeriod", SpeedPeriod);
   JMA.JJMALengthCheck("Smooth", Smooth);
   JMA.JJMAPhaseCheck("SmPhase", SmPhase);
//----
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
   if(rates_total<start)
      return(0);

//---- объявления локальных переменных 
   int first,bar;
   double price,jfatl,fatl,jmom1,jmom2,jfspeed;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- объявление переменных классов CFATL, CJJMA и CMomentum из файла JJMASeries_Cls.mqh
   static CJJMA JMA1,JMA2;
   static CFATL FATL;
   static CMomentum MOM1,MOM2;

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- получаем входную цену price
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- грузим входную цену price в FATLSeries() и получаем fatl
      fatl=FATL.FATLSeries(0,prev_calculated,rates_total,price,bar,false);

      //---- грузим fatl в JJMASeries() и получаем jfatl
      jfatl=JMA1.JJMASeries(fstart,prev_calculated,rates_total,0,SmPhase_,SmLength_,fatl,bar,false);

      //---- грузим jfatl в MomentumSeries() и получаем jmom
      jmom1=MOM1.MomentumSeries(jfstart,prev_calculated,rates_total,SpeedPeriod,jfatl,bar,false);

      //---- грузим jmom в JJMASeries() и получаем jfspeed
      jfspeed=JMA2.JJMASeries(mstart,prev_calculated,rates_total,0,SmPhase,Smooth,jmom1,bar,false);

      jmom2=MOM2.MomentumSeries(spstart,prev_calculated,rates_total,AccelerationPeriod,jfspeed,bar,false);

      //---- меняем размерность индикатора до целых значений
      jmom2/=_Point;

      //---- грузим jfspeed в индикаторный буфер
      IndBuffer[bar]=jmom2;
      LineIndBuffer[bar]=jmom2;
     }

//---- корректируем значение стартового номера для расчета всех баров
   if(prev_calculated>rates_total || prev_calculated<=0) first=start;

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total; bar++)
     {
      ColorBuffer[bar]=0;
      if(IndBuffer[bar]>IndBuffer[bar-1]) ColorBuffer[bar]=1;
      if(IndBuffer[bar]<IndBuffer[bar-1]) ColorBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
