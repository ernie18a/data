//+---------------------------------------------------------------------+
//|                                                 ColorJFatlSpeed.mq5 | 
//|                                 иCopyright © 2010, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цветов индикатора использован серый цвет
#property indicator_color1  clrGray
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "JFATL SPEED"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы серый, синий и розовый цвета
#property indicator_color2  clrMagenta,clrGray,clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "JFATL SPEED"
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int JLength=8;   // Период JMA сглаживания Fatl                   
input int JPhase=100;  // Параметр JMA сглаживания Fatl
                       // изменяющийся в пределах -100 ... +100,
                       // влияет на качество переходного процесса
input int MomPeriod=1; // Период индикатора Momentum для измерения скорости

input int Smooth=2;    // Глубина JMA сглаживания индикатора                  
input int SmPhase=100; // Параметр JMA сглаживания индикатора
                       // изменяющийся в пределах -100 ... +100,
                       // влияет на качество переходного процесса
input Applied_price_ IPC=PRICE_CLOSE_; // Ценовая константа
input int FATLShift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление и инициализация переменной для хранения количества расчетных баров FATL
int FATLPeriod=39;
//---- объявление динамического массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorBuffer[];
double LineIndBuffer[];
//----
int start,fstart,jfstart,mstart,FATLSize;
double dPriceShift;
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries()                                  |
//| Описание классов CFATL, CJJMA и CMomentum                        |
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
   mstart=jfstart+MomPeriod;
   start=mstart+30+1;
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,LineIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(1,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JFATL Speed(",JLength," ,",JPhase," ,",MomPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMALengthCheck("JLength", JLength);
   JMA.JJMAPhaseCheck("JPhase", JPhase);
   JMA.JJMALengthCheck("MomPeriod", MomPeriod);
   JMA.JJMALengthCheck("Smooth", Smooth);
   JMA.JJMAPhaseCheck("SmPhase", SmPhase);
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
   if(rates_total<start) return(0);
//---- объявления локальных переменных 
   int first,bar,clr;
   double price,jfatl,fatl,jmom,jfspeed;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных классов CFATL, CJJMA и CMomentum из файла JJMASeries_Cls.mqh
   static CJJMA JMA1,JMA2;
   static CFATL FATL;
   static CMomentum MOM;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- получаем входную цену price
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---- грузим входную цену price в FATLSeries() и получаем fatl
      fatl=FATL.FATLSeries(0,prev_calculated,rates_total,price,bar,false);
      //---- грузим fatl в JJMASeries() и получаем jfatl
      jfatl=JMA1.JJMASeries(fstart,prev_calculated,rates_total,0,JPhase,JLength,fatl,bar,false);
      //---- грузим jfatl в MomentumSeries() и получаем jmom
      jmom=MOM.MomentumSeries(jfstart,prev_calculated,rates_total,MomPeriod,jfatl,bar,false);
      //---- грузим jmom в JJMASeries() и получаем jfspeed
      jfspeed=JMA2.JJMASeries(mstart,prev_calculated,rates_total,0,SmPhase,Smooth,jmom,bar,false);
      //---- меняем размерность индикатора до целых значений
      jfspeed/=_Point;
      //---- грузим jfspeed в индикаторный буфер
      IndBuffer[bar]=jfspeed;
      LineIndBuffer[bar]=jfspeed;
     }
//---- корректируем значение стартового номера для расчета всех баров
   if(prev_calculated>rates_total || prev_calculated<=0) first=start;
//---- основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total; bar++)
     {
      clr=1;
      if(IndBuffer[bar]>IndBuffer[bar-1]) clr=2;
      if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
