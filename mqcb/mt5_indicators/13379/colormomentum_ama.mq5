//+---------------------------------------------------------------------+ 
//|                                               ColorMomentum_AMA.mq5 | 
//|                                Copyright © 2010,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 5 
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- использовано всего два графических построения
#property indicator_plots   2
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlue,clrGreen
#property indicator_color2  clrMagenta,clrRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_label1  "Momentum_AMA Upper"
#property indicator_label2  "Momentum_AMA Lower"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint ALength=8;    // Период Моментума
input uint ama_period=9; // Период AMA
input uint fast_ma_period=2;  // Период быстрой скользящей
input uint slow_ma_period=30; // Период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
input double G=2.0; // Степень, в которую возводится сглаживающая константа
input int Shift=0;  // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double IndMomentum[];
double UpColorsBuffer[];
double LoColorsBuffer[];
double UpperBuffer[];
double LowerBuffer[];
//----
int min_rates_total;
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание функции iPriceSeriesAlert                               |
//| Описание классов CMomentum и CAMA                                |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+    
//| Momentum indicator initialization function                       | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//----  
   min_rates_total=int(ALength+ama_period)+2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,IndMomentum,INDICATOR_CALCULATIONS);
//----   
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpColorsBuffer,INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,LoColorsBuffer,INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Momentum_AMA( ALength = ",ALength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- объявление переменной класса CJurX из файла SmoothAlgorithms.mqh
   CMomentum Mom;
//---- установка алертов на недопустимые значения внешних переменных
   Mom.MALengthCheck("Length", ALength);
   Mom.MALengthCheck("ama_period", ama_period);
   Mom.MALengthCheck("fast_ma_period", fast_ma_period);
   Mom.MALengthCheck("slow_ma_period", slow_ma_period);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Momentum iteration function                                      | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price,momentum,amomentum;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных класса CMomentum и CAMA из файла SmoothAlgorithms.mqh
   static CMomentum Mom;
   static CAMA AMA;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения приращения входной цены dprice_
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---- расчет индикатора  
      momentum=Mom.MomentumSeries(0,prev_calculated,rates_total,ALength,price,bar,false);
      amomentum=AMA.AMASeries(ALength+1,prev_calculated,rates_total,ama_period,fast_ma_period,slow_ma_period,G,momentum,bar,false);
      //---- загрузка полученного значения в индикаторный буфер
      amomentum/=_Point;
      IndMomentum[bar]=amomentum;
      //----
      UpperBuffer[bar]=0.0;
      UpColorsBuffer[bar]=0.0;
      LowerBuffer[bar]=0.0;
      LoColorsBuffer[bar]=0.0;
      //----
      if(bar<=min_rates_total) continue;
      //----
      if(amomentum>0)
        {
         UpperBuffer[bar]=amomentum;
         if(amomentum>IndMomentum[bar-1]) UpColorsBuffer[bar]=1;
        }
      else
        {
         LowerBuffer[bar]=amomentum;
         if(amomentum<IndMomentum[bar-1]) LoColorsBuffer[bar]=1;
        }

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
