//+------------------------------------------------------------------+
//|                                                    FiboBands.mq5 | 
//|                                             Copyright © 2013,    | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright ""
#property link ""
#property description ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- количество индикаторных буферов
#property indicator_buffers 7 
//--- использовано всего семь графических построений
#property indicator_plots   7
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован Gray цвет
#property indicator_color1 clrGray
//--- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_DASHDOTDOT
//--- толщина линии индикатора равна 1
#property indicator_width1  1
//--- отображение метки индикатора
#property indicator_label1  "X2MA"
//+--------------------------------------------+
//| Параметры отрисовки индикатора BB уровней  |
//+--------------------------------------------+
//--- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//--- ввыбор цветов уровней Боллинджера
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrLime
#property indicator_color4  clrMagenta
#property indicator_color5  clrMagenta
#property indicator_color6  clrLime
#property indicator_color7  clrDodgerBlue
//--- уровни Боллинджера - штрихпунктирные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
//--- толщина уровней Боллинджера равна 2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
//--- отображение меток уровней Боллинджера
#property indicator_label2  "+4.236 level"
#property indicator_label3  "+2.618 level"
#property indicator_label4  "+1.618 level"
#property indicator_label5  "-1.618 level"
#property indicator_label6  "-2.618 level"
#property indicator_label7  "-4.236 level"
//+-----------------------------------+ 
//| объявление констант               |
//+-----------------------------------+
#define RESET  0   // Константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//--- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
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
input Smooth_Method MA_Method1=MODE_SMA;  // Метод первого усреднения
input uint Length1=100;                   // Глубина первого усреднения                    
input int Phase1=15;                      // Параметр первого усреднения
//--- Phase1: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Phase1: для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; // Метод второго усреднения
input uint Length2=20;                    // Глубина второго усреднения 
input int Phase2=100;                     // Параметр второго усреднения
//--- Phase2: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Phase2: для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ATRPeriod=100;                 // Период ATR
input double Deviation=1.0;               // Количество отклонений
input Applied_price_ IPC=PRICE_CLOSE;     // Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;                        // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // Сдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет использован в качестве индикаторного буфера
double X2MA[];
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[];
double ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];
//--- объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//--- объявление переменных для хранения хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_,min_rates_total;
//--- объявление переменных для хранения коэффициентов
double Deviation1,Deviation2,Deviation3;
//+------------------------------------------------------------------+   
//| X2MA FiboBands indicator initialization function                 | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_=XMA1.GetStartBars(MA_Method1,Length1,Phase1)+1;
   min_rates_total=min_rates_+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=int(MathMax(min_rates_total,ATRPeriod));
//---
   Deviation1=Deviation*1.618;
   Deviation2=Deviation*2.618;
   Deviation3=Deviation*4.236;
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//--- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
//--- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"FiboBands(",Smooth1,", ",Smooth2,", ",Length1,", ",Length2,", ",ATRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| X2MA FiboBands iteration function                                | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // Количество истории в барах на текущем тике
                const int prev_calculated,// Количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявление переменных с плавающей точкой  
   double price,x1xma,x2xma,dev1,dev2,dev3,ATR[1];
//--- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- вызов функции PriceSeries для получения входной цены price_
      price=PriceSeries(IPC,bar,open,low,high,close);
      //--- два вызова функции XMASeries. 
      //--- во втором вызове параметр begin увеличен на min_rates_ т. к. это повторное XMA сглаживание  
      x1xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      x2xma=XMA2.XMASeries(min_rates_,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,false);
      X2MA[bar]=x2xma+dPriceShift;
      //--- копируем вновь появившиеся данные в массив ATR[]
      if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);
      //--- расчет полос
      dev1=Deviation1*ATR[0];
      dev2=Deviation2*ATR[0];
      dev3=Deviation3*ATR[0];
      //---
      ExtLineBuffer1[bar]=X2MA[bar]+dev3;
      ExtLineBuffer2[bar]=X2MA[bar]+dev2;
      ExtLineBuffer3[bar]=X2MA[bar]+dev1;
      ExtLineBuffer4[bar]=X2MA[bar]-dev1;
      ExtLineBuffer5[bar]=X2MA[bar]-dev2;
      ExtLineBuffer6[bar]=X2MA[bar]-dev3;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
