//+---------------------------------------------------------------------+
//|                                      Waddah_Attar_Trend_Candles.mq5 |
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
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDodgerBlue,clrDeepPink
//---- отображение метки индикатора
#property indicator_label1  "Waddah_Attar_Trend_Open;Waddah_Attar_Trend_High;Waddah_Attar_Trend_Low;Waddah_Attar_Trend_Close"
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1[4],XMA2[4],XMA3[4];
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
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method XXMethod=MODE_JJMA; //метод усреднения MA
input int XXMA=9; //период MA
input int XXPhase=100; // параметр MA,
//--- XPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input uint GapMinimum=10; //минимальный гэп в пунктах
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   int min_rates_2=GetStartBars(XXMethod,XXMA,XXPhase);
   min_rates_total=MathMax(min_rates_1,min_rates_2);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Waddah_Attar_Trend_Candles");
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
   int first;
//---- Объявление переменных с плавающей точкой  
   double price[4],fast_xma,slow_xma,xmacd,xma,watrend[4];

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=1; // стартовый номер для расчёта всех баров первого цикла
      ArrayInitialize(watrend,NULL);
      ExtCloseBuffer[first-1]=0;
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price[0]=open[bar];
      price[1]=high[bar];
      price[2]=low[bar];
      price[3]=close[bar];
      ArrayInitialize(watrend,NULL);

      for(int count=0; count<4; count++)
        {
         fast_xma=XMA1[count].XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price[count],bar,false);
         slow_xma=XMA2[count].XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,price[count],bar,false);
         xmacd=(fast_xma-slow_xma)/_Point;
         xma=XMA3[count].XMASeries(1,prev_calculated,rates_total,XXMethod,XXPhase,XXMA,price[count],bar,false)/_Point;
         watrend[count]=xmacd*xma;
        }
      
      if(MathAbs(open[bar]-close[bar-1])<GapMinimum) watrend[0]=ExtCloseBuffer[bar-1];
      ExtHighBuffer[bar]=watrend[3-ArrayMaximum(watrend)];
      ExtLowBuffer[bar]=watrend[3-ArrayMinimum(watrend)];      
      ExtOpenBuffer[bar]=watrend[0];
      ExtCloseBuffer[bar]=watrend[3];      
      
      if(ExtCloseBuffer[bar]>=ExtOpenBuffer[bar]) ExtColorBuffer[bar]=0;
      else ExtColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
