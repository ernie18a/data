//+---------------------------------------------------------------------+
//|                                                       SVS_Trend.mq5 | 
//|                                               Copyright © 2009, SVS | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, SVS"
#property link ""
#property description "SVS_Trend"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 6 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикаторов виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_type6   DRAW_HISTOGRAM
//---- выбор цветов гистограммы
#property indicator_color1 clrLightSteelBlue
#property indicator_color2 clrBlueViolet
#property indicator_color3 clrBlack
#property indicator_color4 clrMediumBlue
#property indicator_color5 clrRed
#property indicator_color6 clrLime
//---- толщина баров гистограммы равна 3
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  объявление перечислений          |
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
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  объявление перечислений          |
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_; //метод первого усреднения
input uint Length1=100;                   //глубина  первого сглаживания                    
input int Phase1=15;                      //параметр первого среднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_QUARTER_;  // цена
input int Shift=0;                        // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtMapBuffer1[],ExtMapBuffer2[],ExtMapBuffer3[];
double ExtMapBuffer4[],ExtMapBuffer5[],ExtMapBuffer6[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,StartBars1;
//+------------------------------------------------------------------+   
//| SVS_Trend indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBars1=XMA1.GetStartBars(MA_Method1,Length1,Phase1)+1;
   min_rates_total=StartBars1+XMA1.GetStartBars(MA_Method1,Length1,Phase1);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1",Length1);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMapBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtMapBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtMapBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtMapBuffer6,INDICATOR_DATA);

//---- установка позиции, с которой начинается отрисовка индикаторов
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);

//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"SVS_Trend(",Length1,", ",Phase1,", ",
                                    EnumToString(IPC),", ",Shift,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| SVS_Trend iteration function                                     | 
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
   double z,s1,v1,vv,sv,svz,vj,vk,vd,ff;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      z=PriceSeries(IPC,bar,open,low,high,close)/_Point;
      s1= XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,z,bar,false);
      v1=XMA2.XMASeries(StartBars1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,s1,bar,false);
      //---------------------------------               
      sv=(s1+v1)/2;
      svz=(sv+z)/2;
      ff=(svz-sv);
      vv=(s1-v1);
      vk=(vv+ff)/2;
      vd=(ff/2);
      vj=(vv-vd);
      //----------------------------
      ExtMapBuffer1[bar]=vv;
      ExtMapBuffer2[bar]=vk;
      ExtMapBuffer3[bar]=vd;
      ExtMapBuffer4[bar]=EMPTY_VALUE;
      ExtMapBuffer5[bar]=EMPTY_VALUE;
      ExtMapBuffer6[bar]=EMPTY_VALUE;

      if(vd>0) ExtMapBuffer4[bar]=vj;
      if(vd<0) ExtMapBuffer5[bar]=vj;

      if(vd>0 && vk<vj) ExtMapBuffer6[bar]=vj;
      if(vd<0 && vk>vj) ExtMapBuffer6[bar]=vj;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
