//+---------------------------------------------------------------------+
//|                                                      ColorJJRSX.mq5 | 
//|                                Copyright © 2013,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strenght Index"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего 2 графических построения
#property indicator_plots   2

//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован
#property indicator_color1 clrGray
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение лэйбы индикатора
#property indicator_label1  "JJRSX"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type2   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color2 clrRed,clrDarkOrange,clrGray,clrTeal,clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение лэйбы индикатора
#property indicator_label2  "High Short;Short;Flat;Long;High Long"

//+------------------------------------------+
// Описание классов усреднения и индикаторов |
//+------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+------------------------------------------+
//---- объявление переменных классов CJMA и CJurX из файла SmoothAlgorithms.mqh
CJJMA JMA;
CJurX UpJurX,DnJurX;
//+------------------------------------------+
//|  объявление перечислений                 |
//+------------------------------------------+
enum Applied_price_ //Тип константы
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
//+------------------------------------------+
//|  объявление перечислений                 |
//+------------------------------------------+
enum IndStyle //Стиль отображения индикатора
  {
   COLOR_LINE = DRAW_COLOR_LINE,          //Цветная линия
   COLOR_HISTOGRAM=DRAW_COLOR_HISTOGRAM,  //Цветная гистограмма
   COLOR_ARROW=DRAW_COLOR_ARROW           //Цветные значки
  };
//+------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА            |
//+------------------------------------------+
input uint JurXPeriod=8; //период JurX
input uint JMAPeriod=3;  //период JMA
input int JMAPhase=100;   //параметр усреднения JMA,
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_; //ценовая константа
input int Shift=0; //сдвиг индикатора по горизонтали в барах
input IndStyle Style=COLOR_HISTOGRAM; //стиль отображения JJRSX
input int HighLevel=+20; //верхний уровень срабатывания
input int MiddleLevel=0; //середина диапазона
input int LowLevel=-20;  //нижний уровень срабатывания
//+------------------------------------------+
//---- объявление динамического массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double JJRSX[];
double JJRSX_[];
double ColorJJRSX[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| JJRSX indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_=2;
   min_rates_total=min_rates_+30;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,JJRSX_,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,JJRSX,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorJJRSX,INDICATOR_COLOR_INDEX);   
   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   

//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- изменение стиля отображения индикатора   
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,Style);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Relative Strenght Index(",
                     string(JurXPeriod),",",string(JMAPeriod),",",string(JMAPhase),",",EnumToString(IPC),",",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| JJRSX iteration function                                         | 
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
   double dPrice,AbsdPrice,jrsx,uprsx,dnrsx;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,clr;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1; // стартовый номер для расчёта всех баров
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчёта новых баров
     }

//---- Основной цикл расчёта индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      dPrice=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-1,open,low,high,close);     
      AbsdPrice=MathAbs(dPrice);
      
      //---- запрет деления на ноль!
      if(!AbsdPrice)  AbsdPrice=_Point;

      //---- предварительная инициализация индикаторного буфера пустым значением
      JJRSX[bar]=EMPTY_VALUE;

      //---- Два вызова функции JurXSeries 
      uprsx=UpJurX.JurXSeries(1,prev_calculated,rates_total,0,JurXPeriod,dPrice,bar,false);
      dnrsx=DnJurX.JurXSeries(1,prev_calculated,rates_total,0,JurXPeriod,AbsdPrice,bar,false);    
      jrsx=100*uprsx/dnrsx;
      
      //---- Один вызов функции JMASeries 
      JJRSX[bar]=JMA.JJMASeries(min_rates_,prev_calculated,rates_total,0,JMAPhase,JMAPeriod,jrsx,bar,false);         
      JJRSX_[bar]=JJRSX[bar];

      clr=2;
      if(JJRSX[bar]>JJRSX[bar-1]) {if(JJRSX[bar]>HighLevel) clr=4; else clr=3;}
      if(JJRSX[bar]<JJRSX[bar-1]) {if(JJRSX[bar]<LowLevel)  clr=0; else clr=1;}
      ColorJJRSX[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
