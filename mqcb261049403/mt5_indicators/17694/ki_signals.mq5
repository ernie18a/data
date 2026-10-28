//+---------------------------------------------------------------------+
//|                                                      KI_signals.mq5 |
//|                                           Copyright © 2011, Kalenzo | 
//|                                         bartlomiej.gorski@gmail.com | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Kalenzo"
#property link "bartlomiej.gorski@gmail.com" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrMagenta,clrPlum,clrGray,clrDeepSkyBlue,clrBlue
//---- отображение метки индикатора
#property indicator_label1  "KI_signals Open;High;Low;Close"
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
//|  объявление перечислений          |
//+-----------------------------------+
enum ENUM_APPLIED_MODE_     //Тип константы
  {
   HISTOGRAM=0,      //изменение направления гистограммы
   SIGNAL,           //изменение направления сигнальной линии
   CROSS             //пересечение гистограммы и сигнальной линии
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_APPLIED_MODE_ Mode=CROSS;  //Вариант торговых сигналов
input Smooth_Method XMA_Method=MODE_T3; //метод усреднения гистограммы
input uint Fast_XMA = 12; //период быстрого мувинга
input uint Slow_XMA = 26; //период медленного мувинга
input int XPhase=100;  //параметр усреднения мувингов,
                       //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_JJMA; //метод усреднения сигнальной линии
input int Signal_XMA=9; //период сигнальной линии 
input int Signal_Phase=100; // параметр сигнальной линии,
                            //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//ценовая константа
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_total=min_rates_1+GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"KI_signals( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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
   double price_,fast_xma,slow_xma,xmacd,sign_xma;
   static double xmacd_prev,sign_xma_prev;

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
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;
      fast_xma = XMA1.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, price_, bar, false);
      slow_xma = XMA2.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, price_, bar, false);
      xmacd=fast_xma-slow_xma;
      sign_xma=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);
      //----
      ExtCloseBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;
      ExtOpenBuffer[bar]=NULL;
      ExtColorBuffer[bar]=2.0;

      //---- Загрузка полученных значений в индикаторные буферы      
      switch(Mode)
        {
         case HISTOGRAM:
           {
            if(xmacd_prev<=0 && xmacd>0)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=0.0;
               else ExtColorBuffer[bar]=1.0;
              }

            if(xmacd_prev>=0 && xmacd<0)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=3.0;
               else ExtColorBuffer[bar]=4.0;
              }
            break;
           }
         case SIGNAL:
           {
            if(sign_xma_prev>=0 && sign_xma<0)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=0.0;
               else ExtColorBuffer[bar]=1.0;
              }

            if(sign_xma_prev<=0 && sign_xma>0)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=3.0;
               else ExtColorBuffer[bar]=4.0;
              }
            break;
           }
         case CROSS:
           {
            if(xmacd_prev>=sign_xma_prev && xmacd<sign_xma)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=0.0;
               else ExtColorBuffer[bar]=1.0;
              }

            if(xmacd_prev<=sign_xma_prev && xmacd>sign_xma)
              {
               ExtCloseBuffer[bar]=close[bar];
               ExtHighBuffer[bar]=high[bar];
               ExtLowBuffer[bar]=low[bar];
               ExtOpenBuffer[bar]=open[bar];
               if(close[bar]<open[bar]) ExtColorBuffer[bar]=3.0;
               else ExtColorBuffer[bar]=4.0;
              }
           }
        }

      if(bar<rates_total-1)
        {
         xmacd_prev=xmacd;
         sign_xma_prev=sign_xma;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
