//+---------------------------------------------------------------------+
//|                                         Bear_Bulls_Power_Candle.mq5 | 
//|                                 Copyright © 2006, Eng. Waddah Attar | 
//|                                             waddahattar@hotmail.com | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eng. Waddah Attar"
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
#property indicator_color1  clrSeaGreen,clrYellowGreen,clrGray,clrLightPink,clrRed
//---- отображение метки индикатора
#property indicator_label1  "Bear_Bulls_Power_Open;Bear_Bulls_Power_High;Bear_Bulls_Power_Low;Bear_Bulls_Power_Close"
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA OXMA1,OXMA2,HXMA1,HXMA2,LXMA1,LXMA2,CXMA1,CXMA2;
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
input Smooth_Method MA_Method1=MODE_SMA_; //Метод усреднения индикатора 
input uint Length1=12; //Глубина усреднения индикатора                   
input int Phase1=15; //Параметр усреднения индикатора,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; //Метод сглаживания итогового индикатора
input uint Length2 = 5; //Глубина сглаживания итогового индикатора
input int Phase2=15;  //Параметр сглаживания итогового индикатора,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//----Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Range=10; //максимальный размер гепа между исходными свечками, не отображаемый на индикаторе
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Bear_Bulls_Power indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_1=GetStartBars(MA_Method1, Length1, Phase1)+1;
   min_rates_total=min_rates_1+GetStartBars(MA_Method2, Length2, Phase2);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);  
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);  
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=OXMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=OXMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"Bear_Bulls_Power_Candle(",Length1,", ",Smooth1,", ",Length2,", ",Smooth2,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Bear_Bulls_Power iteration function                              | 
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

//---- Объявление переменных с плавающей точкой  
   double xma,bulls_bears,xbulls_bears;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      xma=OXMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      bulls_bears=(high[bar]+low[bar]-2*xma)/2.0;      
      xbulls_bears=OXMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,bulls_bears,bar,false);
      ExtOpenBuffer[bar]=xbulls_bears/_Point;
      //----
      xma=HXMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar],bar,false);
      bulls_bears=(high[bar]+low[bar]-2*xma)/2.0;      
      xbulls_bears=HXMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,bulls_bears,bar,false);
      ExtHighBuffer[bar]=xbulls_bears/_Point;
      //----
      xma=LXMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,low[bar],bar,false);
      bulls_bears=(high[bar]+low[bar]-2*xma)/2.0;      
      xbulls_bears=LXMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,bulls_bears,bar,false);
      ExtLowBuffer[bar]=xbulls_bears/_Point;
      //----
      xma=CXMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
      bulls_bears=(high[bar]+low[bar]-2*xma)/2.0;      
      xbulls_bears=CXMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,bulls_bears,bar,false);
      ExtCloseBuffer[bar]=xbulls_bears/_Point;
      //---- корректировка свечек
      if(MathAbs(close[bar-1]-open[bar])<Range*_Point) ExtOpenBuffer[bar]=ExtCloseBuffer[bar-1];     
      //---- окрашивание свечей
      ExtColorBuffer[bar]=2;
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar-1]<=ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar-1]>=ExtCloseBuffer[bar]) ExtColorBuffer[bar]=4;
         else ExtColorBuffer[bar]=3;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
