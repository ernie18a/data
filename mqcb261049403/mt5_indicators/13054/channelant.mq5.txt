//+---------------------------------------------------------------------+
//|                                                      ChannelAnt.mq5 | 
//|                                          Copyright © 2013, Stajer59 | 
//|                                        http://www.stajer59.ucoz.ru/ | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "CCopyright © 2013, Stajer59"
#property link "http://www.stajer59.ucoz.ru"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего 9 графических построений
#property indicator_plots   11
//+-----------------------------------+
//| Параметры отрисовки индикатора   | 
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ChannelAnt"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора уровней    |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
#property indicator_type10   DRAW_LINE
#property indicator_type11   DRAW_LINE
//---- выбор цветов уровней
#property indicator_color2  clrIndigo
#property indicator_color3  clrDarkSlateGray
#property indicator_color4  clrPurple
#property indicator_color5  clrRed
#property indicator_color6  clrBlue
#property indicator_color7  clrBlue
#property indicator_color8  clrRed
#property indicator_color9  clrPurple
#property indicator_color10 clrDarkSlateGray
#property indicator_color11 clrIndigo
//---- уровни - штрихпунктирные кривые
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_SOLID
#property indicator_style9 STYLE_DASHDOTDOT
#property indicator_style10 STYLE_SOLID
#property indicator_style11 STYLE_DASHDOTDOT
//---- толщина уровней равна 1
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  2
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  2
#property indicator_width9  1
#property indicator_width10 2
#property indicator_width11 1
//---- отображение меток уровней
#property indicator_label2  "+5 Level"
#property indicator_label3  "+4 Level"
#property indicator_label4  "+3 Level"
#property indicator_label5  "+2 Level"
#property indicator_label6  "+1 Level"
#property indicator_label7  "-1 Level"
#property indicator_label8  "-2 Level"
#property indicator_label9  "-3 Level"
#property indicator_label10 "-4 Level"
#property indicator_label11 "-5 Level"
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMAn из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
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
input Smooth_Method MA_Method1=MODE_SMA; // Метод первого усреднения
input uint Length1=40; // Глубина  первого сглаживания                    
input int Phase1=15;   // Параметр первого среднения
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; // Метод второго усреднения
input uint Length2=20; // Глубина  второго усреднения 
input int Phase2=100;  // Параметр второго сглаживания
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input double Deviation=1; // Коэффициент расширения
input Applied_price_ IPC=PRICE_CLOSE;// Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double X2MA[];
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов уровней
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
double ExtLineBuffer9[],ExtLineBuffer10[];
//---- объявление переменной значения вертикального сдвига скользящей средней
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| X2MA Channel indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1)+1;
   StartBars2=StartBars1+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer9,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer10,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(10,PLOT_DRAW_BEGIN,StartBars);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"ChannelAnt(",
                     ", ",Smooth1,", ",Smooth2,Length1,", ",Length2,", ",DoubleToString(Deviation,4),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| X2MA Channel iteration function                                  | 
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
   if(rates_total<StartBars) return(0);
//---- объявление переменных с плавающей точкой  
   double price_,x1xma,x2xma,Dev1,Dev2,Dev3,Dev4,Dev5,Dev6,Dev7,Dev8,Dev9,Dev10;
//---- объявление целых переменных и получение уже посчитанных баров
   int first1,first2,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first1=0; // стартовый номер для расчета всех баров для мувинга
      first2=StartBars; // стартовый номер для расчета всех баров для канала
     }
   else
     {
      first1=prev_calculated-1; // стартовый номер для расчета новых баров для мувинга
      first2=first1; // стартовый номер для расчета новых баров для канала
     }
//---- основной цикл расчета индикатора
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //---- два вызова функции XMASeries. 
      //---- во втором вызове параметр begin увеличен на StartBars1 т. к. это повторное XMA сглаживание  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //----       
      X2MA[bar]=x2xma+dPriceShift;
     }
//---- основной цикл расчета уровней
   for(bar=first2; bar<rates_total && !IsStopped(); bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //---- расчет половины ширины канала для каждой пары уровней
      Dev1=1+Deviation*0.736/100;
      Dev2=1+Deviation*0.618/100;
      Dev3=1+Deviation*0.500/100;
      Dev4=1+Deviation*0.382/100;
      Dev5=1+Deviation*0.191/100;
      //---- расчет половины ширины канала для каждой пары уровней
      Dev6=1-Deviation*0.191/100;
      Dev7=1-Deviation*0.382/100;
      Dev8=1-Deviation*0.500/100;
      Dev9=1-Deviation*0.618/100;
      Dev10=1-Deviation*0.736/100;
      //---- расчет уровней и инициализация индикаторных буферов
      ExtLineBuffer1[bar]=X2MA[bar]*Dev1;
      ExtLineBuffer2[bar]=X2MA[bar]*Dev2;
      ExtLineBuffer3[bar]=X2MA[bar]*Dev3;
      ExtLineBuffer4[bar]=X2MA[bar]*Dev4;
      ExtLineBuffer5[bar]=X2MA[bar]*Dev5;
      //---- расчет уровней и инициализация индикаторных буферов
      ExtLineBuffer6[bar]=X2MA[bar]*Dev6;
      ExtLineBuffer7[bar]=X2MA[bar]*Dev7;
      ExtLineBuffer8[bar]=X2MA[bar]*Dev8;
      ExtLineBuffer9[bar]=X2MA[bar]*Dev9;
      ExtLineBuffer10[bar]=X2MA[bar]*Dev10;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
