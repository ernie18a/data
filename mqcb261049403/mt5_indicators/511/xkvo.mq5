//+---------------------------------------------------------------------+ 
//|                                                            XKVO.mq5 | 
//|                                  Copyright © 2011, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrGray,clrLimeGreen,clrGreen,clrRed,clrPaleVioletRed
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "XKVO"
//+-----------------------------------+
//---- отрисовка индикатора в виде трёхцветной линии
#property indicator_type2 DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color2 clrGray,clrAqua,clrMagenta
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 3
#property indicator_width2 3
//---- отображение метки сигнальной линии
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
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
input Smooth_Method XMA_Method=MODE_EMA_; //метод усреднения гистограммы
input int Fast_XMA = 34; //период быстрого мувинга
input int Slow_XMA = 55; //период медленного мувинга
input int XPhase= 100;  //параметр усреднения мувингов,
                       //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_EMA_; //метод усреднения сигнальной линии
input int Signal_XMA=13; //период сигнальной линии 
input int Signal_XPhase=100; // параметр сигнальной линии,
                            //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//ценовая константа
/* , по которой производится расчёт индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //объём
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int start,xkvo_start;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double XKVOBuffer[],SignBuffer[],ColorXKVOBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
// Описание функции iPriceSeries                                     |
// Описание класса Moving_Average                                    | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| XKVO indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   xkvo_start=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase))+1;
   start=xkvo_start+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_XPhase)+1;

//---- превращение динамического массива XKVOBuffer в индикаторный буфер
   SetIndexBuffer(0,XKVOBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,xkvo_start);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXKVOBuffer,INDICATOR_COLOR_INDEX);

//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start+1);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_XPhase", Signal_XPhase, Signal_Method);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"XKVO( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| XKVO iteration function                                          | 
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
//---- Проверка количества баров на достаточность для расчёта
   if(rates_total<start) return(0);

//---- Объявление целых переменных
   int first1,first2,first3,bar;
//---- Объявление переменных с плавающей точкой  
   double tpc,tpp,var=0.0,vol,fast_xma,slow_xma,xkvo,sign_xkvo;

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first1=1; // стартовый номер для расчёта всех баров первого цикла
      first2=xkvo_start+2; // стартовый номер для расчёта всех баров второго цикла
      first3=start+2; // стартовый номер для расчёта всех баров третьего цикла
     }
   else // стартовый номер для расчёта новых баров
     {
      first1=prev_calculated-1;
      first2=first1;
      first3=first1;
     }

//---- Основной цикл расчёта индикатора
   for(bar=first1; bar<rates_total; bar++)
     {      
      tpc = (low[bar] + close[bar] + close[bar])/3;
      tpp = (high[bar-1] + low[bar-1] + close[bar-1])/3;
      if(VolumeType==VOLUME_TICK) vol=double(tick_volume[bar]);
      else                        vol=double(volume[bar]);
      
      if (tpc > tpp) var = vol;     
      if (tpc < tpp) var = -vol;
      if (tpc == tpp) var = 0.0;

      fast_xma = XMA1.XMASeries(1, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, var, bar, false);
      slow_xma = XMA2.XMASeries(1, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, var, bar, false);

      xkvo=fast_xma-slow_xma;
      sign_xkvo=XMA3.XMASeries(xkvo_start,prev_calculated,rates_total,Signal_Method,Signal_XPhase,Signal_XMA,xkvo,bar,false);

      //---- Загрузка полученных значений в индикаторные буферы      
      XKVOBuffer[bar]= xkvo;
      SignBuffer[bar] = sign_xkvo;
     }

//---- Основной цикл раскраски индикатора XKVO
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorXKVOBuffer[bar]=0;

      if(XKVOBuffer[bar]>0)
        {
         if(XKVOBuffer[bar]>XKVOBuffer[bar-1]) ColorXKVOBuffer[bar]=1;
         if(XKVOBuffer[bar]<XKVOBuffer[bar-1]) ColorXKVOBuffer[bar]=2;
        }

      if(XKVOBuffer[bar]<0)
        {
         if(XKVOBuffer[bar]<XKVOBuffer[bar-1]) ColorXKVOBuffer[bar]=3;
         if(XKVOBuffer[bar]>XKVOBuffer[bar-1]) ColorXKVOBuffer[bar]=4;
        }
     }

//---- Основной цикл раскраски сигнальной линии
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorSignBuffer[bar]=0;
      if(XKVOBuffer[bar]>SignBuffer[bar-1]) ColorSignBuffer[bar]=1;
      if(XKVOBuffer[bar]<SignBuffer[bar-1]) ColorSignBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
