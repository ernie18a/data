//+---------------------------------------------------------------------+
//|                                                         XCCX_BB.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strength Index"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 9 
//---- использовано всего одно графическое построение
#property indicator_plots   7
//+------------------------------------------+
//|  Параметры отрисовки индикатора 1        |
//+------------------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrGray,clrGreen,clrBlue,clrRed,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "XCCX"

//+------------------------------------------+
//|  Параметры отрисовки индикатора 2        |
//+------------------------------------------+
//---- отрисовка индикатора в виде трёхцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color2 clrGray,clrAqua,clrDarkOrange
//---- линия индикатора - штрих
#property indicator_style2  STYLE_DASH
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "Signal line"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора BB уровней |
//+--------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color3  clrBlueViolet
#property indicator_color4  clrDeepPink
#property indicator_color5  clrGray
#property indicator_color6  clrDeepPink
#property indicator_color7  clrBlueViolet
//---- уровни Боллинджера - штрихпунктирные кривые
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
//---- толщина уровней Боллинджера равна 1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
//---- отображение меток уровней Боллинджера
#property indicator_label3  "+2Sigma"
#property indicator_label4  "+Sigma"
#property indicator_label5  "Middle"
#property indicator_label6  "-Sigma"
#property indicator_label7  "-2Sigma"
//+------------------------------------------+
// Описание классов усреднения и индикаторов |
//+------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+------------------------------------------+
//---- объявление переменных класса CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMAD,UPXCCX,DNXCCX,XSIGN,XMA;
CStdDeviation STD;
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
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
//+------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА            |
//+------------------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA; //метод усреднения цены
input uint DPeriod=15;  //период мувинга
input int DPhase=15;   //параметр усреднения мувинга,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MSmoothMethod=MODE_T3; //метод усреднения отклонения
input uint MPeriod=15; //период среднего отклонения
input int MPhase=15;   //среднего отклонения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method SSmoothMethod=MODE_T3; //метод усреднения сигнальной линии
input uint SPeriod=7;  //период сигнальной линии
input int SPhase=15;   //параметр сигнальной линии,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_; //ценовая константа
input int Shift=0; //сдвиг индикатора по горизонтали в барах
input IndStyle Style=COLOR_HISTOGRAM; //стиль отображения XCCX
input int BBPeriod=100; //период для уровней Боллинджера
input double BBDeviation1 = 1.0; //малая девиация
input double BBDeviation2 = 1.6; //большая девиация
//+------------------------------------------+

//---- объявление динамического массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double XCCX[],XXCCX[];
double ColorXCCX[],ColorXXCCX[];
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];

//---- Объявление переменной пропорции уровней Боллинджера
double quotient;

//---- Объявление целых переменных начала отсчёта данных
int StartBars,StartBarsD,StartBarsS,StartBarsM,StartBarsB;
//+------------------------------------------------------------------+   
//| XCCX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBarsD=XMA.GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   StartBarsM=StartBarsD+XMA.GetStartBars(MSmoothMethod,MPeriod,MPhase);
   StartBarsS=StartBarsM+XMA.GetStartBars(SSmoothMethod,SPeriod,SPhase);
   StartBarsB=StartBarsM+BBPeriod;
   StartBars=MathMax(StartBarsS,StartBarsB);

//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("DPeriod", DPeriod);
   XMA.XMALengthCheck("MPeriod", MPeriod);
   XMA.XMALengthCheck("BBPeriod", BBPeriod);
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);

//---- Инициализация переменной пропорции уровней Боллинджера
   quotient=BBDeviation2/BBDeviation1;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XCCX,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBarsM+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- изменение стиля отображения индикатора   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Style);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXCCX,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBarsM+1);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,XXCCX,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBarsS+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorXXCCX,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBarsS+1);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(4,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer5,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBars);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname,SmoothD,SmoothM;
   SmoothD=XMA.GetString_MA_Method(DSmoothMethod);
   SmoothM=XMA.GetString_MA_Method(MSmoothMethod);
   StringConcatenate(shortname,"Commodity Chanel Index(",
                     string(DPeriod),",",string(MPeriod),",",SmoothD,",",SmoothM,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XCCX iteration function                                          | 
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
   double price_,xma,upccx,dnccx,xupccx,xdnccx,xxccx,stdev1,stdev2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first1,first2,first3,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first1=0; // стартовый номер для расчёта всех баров
      first2=StartBarsD+1;
      first3=StartBarsS+1;
     }
   else
     {
      first1=prev_calculated-1; // стартовый номер для расчёта новых баров
      first2=first1;
      first3=first1;
     }

//---- Основной цикл расчёта индикатора
   for(bar=first1; bar<rates_total; bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- предварительная инициализация индикаторного буфера пустым значением
      XCCX[bar]=EMPTY_VALUE;

      //---- Один вызов функции XMASeries 
      xma=XMAD.XMASeries(0,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,price_,bar,false);

      //---- не делаем дальнейших расчётов на участке истории, где недостаточно данных
      if(bar<StartBarsD) continue;

      upccx=price_-xma;
      dnccx=MathAbs(upccx);
      
      //---- Два вызова функции XMASeries 
      xupccx=UPXCCX.XMASeries(StartBarsD,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,upccx,bar,false);
      xdnccx=DNXCCX.XMASeries(StartBarsD,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,dnccx,bar,false);

      //---- инициализация индикаторного буфера
      if(xupccx!=0.0) // запрет деления на ноль!
        XCCX[bar]=100*xupccx/xdnccx;
      
      //---- расчёт сигнальной линии
      xxccx=XSIGN.XMASeries(StartBarsM,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,XCCX[bar],bar,false);

      //---- Загрузка полученного значения в индикаторный буфер
      XXCCX[bar]=xxccx;
      
      //---- расчёт полос Боллинджера
      
      xma=XMA.XMASeries(StartBarsD+1,prev_calculated,rates_total,MODE_SMA_,0,BBPeriod,XCCX[bar],bar,false);
      stdev1=STD.StdDevSeries(StartBarsB,prev_calculated,rates_total,BBPeriod,BBDeviation1,XCCX[bar],xma,bar,false);
      stdev2=stdev1*quotient;
      //---- 
      if(bar<=StartBarsB+BBPeriod)
       {
        xma=EMPTY_VALUE;
        stdev1=0.0;
        stdev2=0.0;
       }

      ExtLineBuffer1[bar]=xma+stdev2;
      ExtLineBuffer2[bar]=xma+stdev1;
      ExtLineBuffer3[bar]=xma;
      ExtLineBuffer4[bar]=xma-stdev1;
      ExtLineBuffer5[bar]=xma-stdev2;
     }

//---- Основной цикл раскраски индикатора MACD
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorXCCX[bar]=0;

      if(XCCX[bar]>0)
        {
         if(XCCX[bar]>XCCX[bar-1]) ColorXCCX[bar]=1;
         if(XCCX[bar]<XCCX[bar-1]) ColorXCCX[bar]=2;
        }

      if(XCCX[bar]<0)
        {
         if(XCCX[bar]<XCCX[bar-1]) ColorXCCX[bar]=3;
         if(XCCX[bar]>XCCX[bar-1]) ColorXCCX[bar]=4;
        }
     }

//---- Основной цикл раскраски сигнальной линии
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorXXCCX[bar]=0;
      if(XCCX[bar]>XXCCX[bar-1]) ColorXXCCX[bar]=1;
      if(XCCX[bar]<XXCCX[bar-1]) ColorXXCCX[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
