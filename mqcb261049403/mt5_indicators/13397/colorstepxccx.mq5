//+------------------------------------------------------------------+
//|                                                ColorStepXCCX.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Для работы  индикатора файл SmoothAlgorithms.mqh                 |
//| следует положить в папку: каталог_данных_терминала\\MQL5\Include |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора StepXCCX      |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы цвета Teal,Magenta
#property indicator_color1  clrTeal,clrMagenta
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки линии индикатора
#property indicator_label1  "Step XCCX"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1       -50.0
#property indicator_level2        50.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAD,XMAH,XMAL;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_      // тип константы
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
//---
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA;  // Метод усреднения цены
input uint DPeriod=30;                        // Период средней
input int DPhase=100;                         // Параметр усреднения
input Smooth_Method MSmoothMethod=MODE_T3;    // Метод усреднения отклонения
input uint MPeriod=7;                         // Период среднего отклонения
input int MPhase=15;                          // Параметр усреднения отклонения
input Applied_price_ IPC=PRICE_TYPICAL;       // Ценовая константа
input uint StepSizeFast=5;                    // Быстрый шаг
input uint StepSizeSlow=30;                   // Медленный шаг
input int Shift=0;                            // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые в дальнейшем 
//---- будут использованы в качестве индикаторных буферов
double Line2Buffer[];
double Line3Buffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int RSI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_total_D,min_rates_total_M;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total_D=XMAD.GetStartBars(DSmoothMethod,DPeriod,DPhase);
   min_rates_total_M=XMAD.GetStartBars(MSmoothMethod,MPeriod,MPhase);
   min_rates_total=min_rates_total_D+min_rates_total_M;
//---- установка алертов на недопустимые значения внешних переменных
   XMAD.XMALengthCheck("DPeriod", DPeriod);
   XMAD.XMALengthCheck("MPeriod", MPeriod);
//---- установка алертов на недопустимые значения внешних переменных
   XMAD.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);
//---- превращение динамического массива Line2Buffer[] в индикаторный буфер
   SetIndexBuffer(0,Line2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Line3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- инициализация переменной для короткого имени индикатора
   string shortname,SmoothD,SmoothM;
   SmoothD=XMAD.GetString_MA_Method(DSmoothMethod);
   SmoothM=XMAD.GetString_MA_Method(MSmoothMethod);
   StringConcatenate(shortname,"StepXCCX(",
                     string(DPeriod),",",string(MPeriod),",",SmoothD,",",SmoothM,
                     StepSizeFast,", ",StepSizeSlow,", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // количество истории в барах на текущем тике
                const int prev_calculated, // количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],      // ценовой массив максимумов цены для расчета индикатора
                const double& low[],       // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявления локальных переменных 
   int first,bar,ftrend,strend,recbar;
   double fmin0,fmax0,smin0,smax0;
   double price_,xma,upccx,dnccx,xupccx,xdnccx,xccx;
   static double fmax1,fmin1,smin1,smax1;
   static int ftrend_,strend_;
//---- восстанавливаем значения переменных
   ftrend = ftrend_;
   strend = strend_;
//---- расчет стартового номера first для цикла пересчета баров и инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
      //----
      fmin1=+999999;
      fmax1=-999999;
      smin1=+999999;
      smax1=-999999;
      ftrend_=0;
      strend_=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//----
   recbar=rates_total-1;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==recbar)
        {
         ftrend_=ftrend;
         strend_=strend;
        }
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //---- один вызов функции XMASeries 
      xma=XMAD.XMASeries(0,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,price_,bar,false);
      //---- не делаем дальнейших расчетов на участке истории, где недостаточно данных
      if(bar<min_rates_total_D) continue;
      //----
      upccx=price_-xma;
      dnccx=MathAbs(upccx);
      //---- два вызова функции XMASeries  
      xupccx=XMAH.XMASeries(min_rates_total_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,upccx,bar,false);
      xdnccx=XMAL.XMASeries(min_rates_total_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,dnccx,bar,false);
      //---- инициализация индикаторного буфера
      if(xupccx!=0.0) // запрет деления на ноль!
         xccx=100*xupccx/xdnccx;
      else xccx=0.0;
      //----
      fmax0=xccx+2*StepSizeFast;
      fmin0=xccx-2*StepSizeFast;
      //----
      if(xccx>fmax1)  ftrend=+1;
      if(xccx<fmin1)  ftrend=-1;
      //----
      if(ftrend>0 && fmin0<fmin1) fmin0=fmin1;
      if(ftrend<0 && fmax0>fmax1) fmax0=fmax1;
      //----
      smax0=xccx+2*StepSizeSlow;
      smin0=xccx-2*StepSizeSlow;
      //----
      if(xccx>smax1)  strend=+1;
      if(xccx<smin1)  strend=-1;
      //----
      if(strend>0 && smin0<smin1) smin0=smin1;
      if(strend<0 && smax0>smax1) smax0=smax1;
      //----
      if(ftrend>0) Line2Buffer[bar]=fmin0+StepSizeFast;
      if(ftrend<0) Line2Buffer[bar]=fmax0-StepSizeFast;
      if(strend>0) Line3Buffer[bar]=smin0+StepSizeSlow;
      if(strend<0) Line3Buffer[bar]=smax0-StepSizeSlow;
      //----
      if(bar<recbar)
        {
         fmin1=fmin0;
         fmax1=fmax0;
         smin1=smin0;
         smax1=smax0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
