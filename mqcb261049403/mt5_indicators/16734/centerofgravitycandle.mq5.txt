//+---------------------------------------------------------------------+
//|                                           CenterOfGravityCandle.mq5 |
//|                         Copyright © 2007, MetaQuotes Software Corp. |
//|                                          https://www.metaquotes.net |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDeepPink,clrSlateBlue,clrAqua
//---- отображение метки индикатора
#property indicator_label1  "CenterOfGravityCandle Open; High; Low; Close"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint Period_=10; //период усреднения индикатора
input uint SmoothPeriod=3; //период сглаживания сигнальной линии
input ENUM_MA_METHOD MA_Method_=MODE_SMA; //метод усреднения сигнальной линии
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
// Описание функции iPriceSeries                                     |
// Описание класса Moving_Average                                    | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   min_rates_total=int(Period_+1+SmoothPeriod+2);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"CenterOfGravityCandle(",Period_,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double sma,lwma,resalt;
//---- Объявление целых переменных
   int first,bar;
   static int startbar;

//---- Инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров первого цикла
      startbar=int(Period_+1);
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- объявление переменных класса Moving_Average
   static CMoving_Average OpMA,OpLWMA,OpSIGN,HMA,HLWMA,HSIGN,LMA,LLWMA,LSIGN,ClMA,ClLWMA,ClSIGN;

//---- Основной цикл расчёта средней линии канала
   for(bar=first; bar<rates_total; bar++)
     {
      sma=OpMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,open[bar],bar,false);
      lwma=OpLWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,open[bar],bar,false);
      resalt=sma*lwma/_Point;
      ExtOpenBuffer[bar]=OpSIGN.MASeries(startbar,prev_calculated,rates_total,SmoothPeriod,MA_Method_,resalt,bar,false);
      
      sma=HMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,high[bar],bar,false);
      lwma=HLWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,high[bar],bar,false);
      resalt=sma*lwma/_Point;
      ExtHighBuffer[bar]=HSIGN.MASeries(startbar,prev_calculated,rates_total,SmoothPeriod,MA_Method_,resalt,bar,false);
      
      sma=LMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,low[bar],bar,false);
      lwma=LLWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,low[bar],bar,false);
      resalt=sma*lwma/_Point;
      ExtLowBuffer[bar]=LSIGN.MASeries(startbar,prev_calculated,rates_total,SmoothPeriod,MA_Method_,resalt,bar,false);
      
      sma=ClMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,close[bar],bar,false);
      lwma=ClLWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,close[bar],bar,false);
      resalt=sma*lwma/_Point;
      ExtCloseBuffer[bar]=ClSIGN.MASeries(startbar,prev_calculated,rates_total,SmoothPeriod,MA_Method_,resalt,bar,false);
     }

//---- Основной цикл исправления и окрашивания свечей
   for(bar=first; bar<rates_total; bar++)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
