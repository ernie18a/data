//+---------------------------------------------------------------------+
//|                                                      X2MACandle.mq5 |
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор X2MA в свечном виде"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
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
#property indicator_color1   clrRed,clrGray,clrLightSeaGreen
//---- отображение метки индикатора
#property indicator_label1  "X2MACandle Open;X2MACandle High;X2MACandle Low;X2MACandle Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAo1,XMAh1,XMAl1,XMAc1;
CXMA XMAo2,XMAh2,XMAl2,XMAc2;
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_;              //метод усреднения первого сглаживания 
input int Length1=12;                                  //глубина  первого сглаживания                    
input int Phase1=15;                                   //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA;              //метод усреднения второго сглаживания 
input int Length2 = 5;                                 //глубина  второго сглаживания 
input int Phase2=15;                                   //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_total=min_rates_1+GetStartBars(MA_Method2, Length2, Phase2);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMAo1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMAo1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MACandle(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double O,H,L,C;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first;
   
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- считаем свечи
      O=XMAo1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      O=XMAo2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,O,bar,false);
      //----     
      H=XMAh1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar],bar,false);
      H=XMAh2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,H,bar,false);
      //----
      L=XMAl1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,low[bar],bar,false);
      L=XMAl2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,L,bar,false);
      //----
      C=XMAc1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
      C=XMAc2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,C,bar,false);
      //---- 
      if(bar<min_rates_total) continue;    
      //---- исправляем значения полученных свечек
      double Max=MathMax(O,C);
      Max=MathMax(Max,L);
      Max=MathMax(Max,H);
      double Min=MathMin(O,C);
      Min=MathMin(Min,L);
      Min=MathMin(Min,H);
      ExtOpenBuffer[bar]=O;
      ExtHighBuffer[bar]=Max;
      ExtLowBuffer[bar]=Min;
      ExtCloseBuffer[bar]=C;
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpenBuffer[bar]=ExtCloseBuffer[bar-1];
      //---- красим свечи
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
