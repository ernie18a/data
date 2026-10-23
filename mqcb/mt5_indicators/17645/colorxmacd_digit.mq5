//+---------------------------------------------------------------------+ 
//|                                                ColorXMACD_Digit.mq5 | 
//|                                         Copyright © 2009, BACKSPACE | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, BACKSPACE"
#property link "" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrTeal,clrBlueViolet,clrGray,clrIndianRed,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "XMACD"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде трёхцветной линии
#property indicator_type2 DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color2 clrLime,clrMediumSlateBlue,clrRed
//---- линия индикатора - сплошная кривая
#property indicator_style2 STYLE_SOLID
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
input int Fast_XMA = 12; //период быстрого мувинга
input int Slow_XMA = 26; //период медленного мувинга
input int XPhase= 100;  //параметр усреднения мувингов,
                       //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_JJMA; //метод усреднения сигнальной линии
input int Signal_XMA=9; //период сигнальной линии 
input int Signal_XPhase=100; // параметр сигнальной линии,
                            //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//ценовая константа
input uint Digit=50;                       //количество пунктов округления
input uint AlertCount=0;//количество подаваемых алертов
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int start,macd_start;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double XMACDBuffer[],SignBuffer[],ColorXMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
// Описание функции iPriceSeries                                     |
// Описание класса Moving_Average                                    | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   macd_start=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   start=macd_start+GetStartBars(Signal_Method,Signal_XMA,Signal_XPhase);

//---- превращение динамического массива XMACDBuffer в индикаторный буфер
   SetIndexBuffer(0,XMACDBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,macd_start);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XMACD");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,macd_start+1);

//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Signal XMA");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

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
   StringConcatenate(shortname,
                     "XMACD( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(rates_total<start) return(0);

//---- Объявление целых переменных
   int first1,first2,first3,bar,bar1,bar2;
   static uint UpCount,DnCount;
//---- Объявление переменных с плавающей точкой  
   double price_,fast_xma,slow_xma,xmacd,sign_xma;

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first1=0; // стартовый номер для расчёта всех баров первого цикла
      first2=macd_start+1; // стартовый номер для расчёта всех баров второго цикла
      first3=start+1; // стартовый номер для расчёта всех баров третьего цикла
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
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;

      fast_xma = XMA1.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, price_, bar, false);
      slow_xma = XMA2.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, price_, bar, false);

      xmacd=(fast_xma-slow_xma)/_Point;
      sign_xma=XMA3.XMASeries(macd_start,prev_calculated,rates_total,Signal_Method,Signal_XPhase,Signal_XMA,xmacd,bar,false);

      //---- Загрузка полученных значений в индикаторные буферы   
      XMACDBuffer[bar]=Digit*MathRound(xmacd/Digit);
      SignBuffer[bar]=Digit*MathRound(sign_xma/Digit);
     }

//---- Основной цикл раскраски индикатора XMACD
   for(bar=first2; bar<rates_total; bar++)
     {
      int clr=2;

      if(XMACDBuffer[bar]>0)
        {
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) clr=0;
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) clr=1;
        }

      if(XMACDBuffer[bar]<0)
        {
         if(XMACDBuffer[bar]<XMACDBuffer[bar-1]) clr=3;
         if(XMACDBuffer[bar]>XMACDBuffer[bar-1]) clr=4;
        }
      ColorXMACDBuffer[bar]=clr;
     }

//---- Основной цикл раскраски сигнальной линии
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorSignBuffer[bar]=1;
      if(XMACDBuffer[bar]>SignBuffer[bar-1]) ColorSignBuffer[bar]=0;
      if(XMACDBuffer[bar]<SignBuffer[bar-1]) ColorSignBuffer[bar]=2;
     }
   
//---- сброс счётчиков алертов в нули
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }

   bar1=rates_total-2;
   bar2=rates_total-3;
   
   //---- подача алерта для покупки
   if(UpCount<AlertCount&&ColorSignBuffer[bar1]==2&&ColorSignBuffer[bar2]==1)
     {
      UpCount++;
      Alert("XMACD индикатор "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Сигнал на покупку "+Symbol());
     }
    
   //---- подача алерта для продажи
   if(DnCount<AlertCount&&ColorSignBuffer[bar1]==1&&ColorSignBuffer[bar2]==2)
     {
      DnCount++;
      Alert("XMACD индикатор "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Сигнал на продажу "+Symbol());
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
