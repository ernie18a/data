//+---------------------------------------------------------------------+
//|                                                   KI_signals_v2.mq5 |
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
//---- для расчета и отрисовки индикатора использовано 6 буферов
#property indicator_buffers 6
//---- использовано 6 графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде значка
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета линии индикатора использован SeaGreen цвет
#property indicator_color1  clrSeaGreen
//---- линия индикатора 1 - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки линии индикатора
#property indicator_label1  "Upper fraclal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета линии индикатора использован цвет MediumVioletRed
#property indicator_color2  clrMediumVioletRed
//---- линия индикатора 2 - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки линии индикатора
#property indicator_label2  "Lower fraclal"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет SpringGreen
#property indicator_color3  clrSpringGreen
//---- толщина индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Red
#property indicator_color4  clrRed
//---- толщина индикатора 4 равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет SpringGreen
#property indicator_color5  clrSpringGreen
//---- толщина индикатора 5 равна 2
#property indicator_width5  2
//---- отображение метки индикатора
#property indicator_label5  "Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Red
#property indicator_color6  clrRed
//---- толщина индикатора 6 равна 2
#property indicator_width6  2
//---- отображение метки индикатора
#property indicator_label6  "Sell"
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
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
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double HHBuffer[];
double LLBuffer[];
double BuyBuffer[];
double SellBuffer[];
double cBuyBuffer[];
double cSellBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
int ATR_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_total=min_rates_1+GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;
   int ATR_Period=15;
   min_rates_total=MathMax(min_rates_total,ATR_Period);
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,HHBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,217);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,LLBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,218);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,233);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,234);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,cBuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,159);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,cSellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,159);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"KI_signals( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int first,bar;
//---- Объявление переменных с плавающей точкой  
   double price,fast_xma,slow_xma,xmacd,sign_xma,ATR[1];
   static double xmacd_prev,xmacd_prev2,sign_xma_prev;

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров первого цикла
      xmacd_prev=xmacd_prev2=sign_xma_prev=NULL;
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      HHBuffer[bar]=NULL;
      LLBuffer[bar]=NULL;
      BuyBuffer[bar]=NULL;
      SellBuffer[bar]=NULL;
      cBuyBuffer[bar]=NULL;
      cSellBuffer[bar]=NULL;
      //----
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);;
      fast_xma = XMA1.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, price, bar, false);
      slow_xma = XMA2.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, price, bar, false);
      xmacd=fast_xma-slow_xma;
      sign_xma=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);
      //----
      if(xmacd_prev<=0 && xmacd>0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*1/4.0;
        }

      if(xmacd_prev>=0 && xmacd<0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*1/4.0;
        }

      if(xmacd<=0 && xmacd_prev2<=xmacd_prev && xmacd_prev>xmacd)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);
         HHBuffer[bar]=high[bar]+ATR[0]*2/4.0;
        }

      if(xmacd>=0 && xmacd_prev2>=xmacd_prev && xmacd_prev<xmacd)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);
         LLBuffer[bar]=low[bar]-ATR[0]*2/4.0;
        }

      if(xmacd_prev<=sign_xma_prev && xmacd>sign_xma)
        {
         cBuyBuffer[bar]=open[bar];
        }

      if(xmacd_prev>=sign_xma_prev && xmacd<sign_xma)
        {
         cSellBuffer[bar]=open[bar];
        }

      if(bar<rates_total-1)
        {
         xmacd_prev2=xmacd_prev;
         xmacd_prev=xmacd;
         sign_xma_prev=sign_xma;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
