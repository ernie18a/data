//+---------------------------------------------------------------------+
//|                                                  ColorBBCandles.mq5 |
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ColorBBCandles"
//---- номер версии индикатора
#property version   "1.01"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
//---- в качестве цветов свечей использованы
#property indicator_color1 clrMagenta,clrRed,clrOrangeRed,clrCrimson,clrBrown,CLR_NONE,clrSeaGreen,clrMediumSeaGreen,clrYellowGreen,clrLime,clrAqua
//---- отображение метки индикатора
#property indicator_label1  "ColorBBCandles Десять цветов"

//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CStdDeviation и CMoving_Average из файла SmoothAlgorithms.mqh
CStdDeviation STD;
CMoving_Average MA;
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

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int BandsPeriod=100; //период усреднения BB

input double BandsDeviation1 = 1.0; //девиация первого уровня
input double BandsDeviation2 = 1.5; //девиация второго уровня
input double BandsDeviation3 = 2.0; //девиация третьего уровня
input double BandsDeviation4 = 2.5; //девиация четвёртого уровня
input double BandsDeviation5 = 3.0; //девиация пятого уровня

input ENUM_MA_METHOD MA_Method_=MODE_EMA; //метод усреднения индикатора
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBars=BandsPeriod+1;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//--- установка количества цветов 11 для цветового буфера
  // PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,11);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="ColorBBCandles";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<StartBars) return(0);

//---- Объявление переменных с плавающей точкой  
   double price_,stdev,ma;
   double UpBB1,UpBB2,UpBB3,UpBB4,UpBB5;
   double DnBB1,DnBB2,DnBB3,DnBB4,DnBB5;
//---- Объявление целых переменных
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта полос Боллинджера
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Вызов функции MASeries для получения значения мувмнга
      ma=MA.MASeries(0,prev_calculated,rates_total,BandsPeriod,MA_Method_,price_,bar,false);
      
      //---- Вызов функции StdDevSeries для получения значения половины ширины канала с Deviation = 1.0 
      stdev=STD.StdDevSeries(StartBars,prev_calculated,rates_total,BandsPeriod,1.0,price_,ma,bar,false);

      //---- Получение значений уровней
      UpBB1=ma+stdev*BandsDeviation1;
      UpBB2=ma+stdev*BandsDeviation2;
      UpBB3=ma+stdev*BandsDeviation3;
      UpBB4=ma+stdev*BandsDeviation4;
      UpBB5=ma+stdev*BandsDeviation5;
      DnBB1=ma-stdev*BandsDeviation1;
      DnBB2=ma-stdev*BandsDeviation2;
      DnBB3=ma-stdev*BandsDeviation3;
      DnBB4=ma-stdev*BandsDeviation4;
      DnBB5=ma-stdev*BandsDeviation5;

      if((price_>UpBB1||price_<DnBB1)&&bar>StartBars) //есть сигналы для окраски свечей
        {
              if(price_>UpBB5) ExtColorsBuffer[bar]=10;
         else if(price_>UpBB4) ExtColorsBuffer[bar]=9;
         else if(price_>UpBB3) ExtColorsBuffer[bar]=8;
         else if(price_>UpBB2) ExtColorsBuffer[bar]=7;
         else if(price_>UpBB1) ExtColorsBuffer[bar]=6;

         else if(price_<DnBB5) ExtColorsBuffer[bar]=0;
         else if(price_<DnBB4) ExtColorsBuffer[bar]=1;
         else if(price_<DnBB3) ExtColorsBuffer[bar]=2;
         else if(price_<DnBB2) ExtColorsBuffer[bar]=3;
         else if(price_<DnBB1) ExtColorsBuffer[bar]=4;
         
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
        }
      else // сигналы для окраски свечей отсутствуют
        {
         ExtOpenBuffer[bar]=0.0;
         ExtHighBuffer[bar]=0.0;
         ExtLowBuffer[bar]=0.0;
         ExtCloseBuffer[bar]=0.0;
         ExtColorsBuffer[bar]=5;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
