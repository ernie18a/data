//+---------------------------------------------------------------------+
//|                                              Waddah_Attar_Trend.mq5 |
//|                                 Copyright © 2007, Eng. Waddah Attar | 
//|                                            waddahattar@hotmail.comu | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, Eng. Waddah Attar"
#property link "waddahattar@hotmail.com" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов двухцветной гистограммы использованы
#property indicator_color1 clrAqua,clrMediumOrchid
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "Waddah_Attar_Trend"
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price 
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
input Smooth_Method XMA_Method=MODE_T3; //метод усреднения гистограммы
input uint Fast_XMA = 12; //период быстрого мувинга MACD
input uint Slow_XMA = 26; //период медленного мувинга MACD
input int XPhase=100;  //параметр усреднения мувингов MACD,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//ценовая константа MACD
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method XXMethod=MODE_JJMA; //метод усреднения MA
input int XXMA=9; //период MA
input int XXPhase=100; // параметр MA,
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ XXAppliedPrice=PRICE_CLOSE_;//ценовая константа MA
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   int min_rates_2=GetStartBars(XXMethod,XXMA,XXPhase);
   min_rates_total=MathMax(min_rates_1,min_rates_2);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Waddah_Attar_Trend");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных
   int first,bar;
//---- Объявление переменных с плавающей точкой  
   double price,fast_xma,slow_xma,xmacd,xma;

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров первого цикла
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);
      fast_xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price,bar,false);
      slow_xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,price,bar,false);
      xmacd=(fast_xma-slow_xma)/_Point;
      price=PriceSeries(XXAppliedPrice,bar,open,low,high,close);
      xma=XMA3.XMASeries(0,prev_calculated,rates_total,XXMethod,XXPhase,XXMA,price,bar,false)/_Point;
      IndBuffer[bar]=xmacd*xma;
     }
//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- Основной цикл раскраски индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      if(IndBuffer[bar]>=IndBuffer[bar-1]) ColorIndBuffer[bar]=0;
      else ColorIndBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
