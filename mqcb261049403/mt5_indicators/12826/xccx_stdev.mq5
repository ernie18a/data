//+---------------------------------------------------------------------+
//|                                                      XCCX_StDev.mq5 | 
//|                                Copyright © 2013,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Commodity Chanel Index"
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 4
#property indicator_buffers 4 
//--- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цветов двухцветной линии использованы
#property indicator_color1  clrGray,clrDodgerBlue,clrOrange
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width1  3
//--- отображение метки индикатора
#property indicator_label1  "XCCX"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color2  clrRed
//--- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован зеленый цвет
#property indicator_color3  clrMediumSpringGreen
//--- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//--- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1       -50.0
#property indicator_level2        50.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAD,XMAH,XMAL;
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price       //Тип константы
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
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA; // Метод усреднения цены
input uint DPeriod=15;                       // Период средней
input int DPhase=15;                         // Параметр усреднения
//--- DPhase: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//--- DPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MSmoothMethod=MODE_T3;   // Метод усреднения отклонения
input uint MPeriod=15;                       // Период среднего отклонения
input int MPhase=15;                         // Параметр среднего отклонения
//--- MPhase: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//--- MPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price IPC=PRICE_TYPICAL;       // Ценовая константа
input double dK=2.0;                         // Коэффициент для квадратичного фильтра
input uint std_period=9;                     // Период квадратичного фильтра
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторного буфера
double XCCXBuffer[],ColorXCCXBuffer[];
double BearsBuffer[];
double BullsBuffer[];
double dXCCX[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_D,min_rates_M;
//+------------------------------------------------------------------+   
//| XCCX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_D=XMAD.GetStartBars(DSmoothMethod,DPeriod,DPhase);
   min_rates_M=XMAD.GetStartBars(MSmoothMethod,MPeriod,MPhase);
   min_rates_total=min_rates_D+min_rates_M+1+int(std_period);
//--- установка алертов на недопустимые значения внешних переменных
   XMAD.XMALengthCheck("DPeriod", DPeriod);
   XMAD.XMALengthCheck("MPeriod", MPeriod);
//--- установка алертов на недопустимые значения внешних переменных
   XMAD.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);
//--- распределение памяти под массивы переменных  
   ArrayResize(dXCCX,std_period);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XCCXBuffer,INDICATOR_DATA);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXCCXBuffer,INDICATOR_COLOR_INDEX);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname,SmoothD,SmoothM;
   SmoothD=XMAD.GetString_MA_Method(DSmoothMethod);
   SmoothM=XMAD.GetString_MA_Method(MSmoothMethod);
   StringConcatenate(shortname,"Commodity Chanel Index(",string(DPeriod),",",string(MPeriod),",",SmoothD,",",SmoothM,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XCCX iteration function                                          | 
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//--- объявление переменных с плавающей точкой  
   double price,xma,upccx,dnccx,xupccx,xdnccx;
   double SMAdif,Sum,StDev,dstd,BEARS,BULLS,Filter;
//--- объявление целочисленных переменных
   int first,bar;
//--- расчет стартового номера first для цикла пересчета баров и инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- вызов функции PriceSeries для получения входной цены price
      price=PriceSeries(IPC,bar,open,low,high,close);
      //--- один вызов функции XMASeries 
      xma=XMAD.XMASeries(0,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,price,bar,false);
      upccx=price-xma;
      dnccx=MathAbs(upccx);
      //--- два вызова функции XMASeries  
      xupccx=XMAH.XMASeries(min_rates_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,upccx,bar,false);
      xdnccx=XMAL.XMASeries(min_rates_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,dnccx,bar,false);
      //--- инициализация индикаторного буфера
      if(xupccx) // запрет деления на ноль!
         XCCXBuffer[bar]=100*xupccx/xdnccx;
      else XCCXBuffer[bar]=EMPTY_VALUE;
     }
//--- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total; // стартовый номер для расчета всех баров
//--- основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ColorXCCXBuffer[bar]=0;
      if(XCCXBuffer[bar-1]<XCCXBuffer[bar]) ColorXCCXBuffer[bar]=1;
      if(XCCXBuffer[bar-1]>XCCXBuffer[bar]) ColorXCCXBuffer[bar]=2;
     }
//--- основной цикл расчета индикатора стандартных отклонений
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dXCCX[iii]=XCCXBuffer[bar-iii]-XCCXBuffer[bar-iii-1];
      //--- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dXCCX[iii];
      SMAdif=Sum/std_period;
      //--- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dXCCX[iii]-SMAdif,2);
      //--- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);
      //--- инициализация переменных
      dstd=NormalizeDouble(dXCCX[0],_Digits+2);
      Filter=NormalizeDouble(dK*StDev,_Digits+2);
      BEARS=0;
      BULLS=0;
      //--- вычисление индикаторных значений
      if(dstd<-Filter) BEARS=XCCXBuffer[bar]; //есть нисходящий тренд
      if(dstd>+Filter) BULLS=XCCXBuffer[bar]; //есть восходящий тренд
      //--- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer[bar]=BULLS;
      BearsBuffer[bar]=BEARS;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
