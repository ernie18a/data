//+------------------------------------------------------------------+
//|                                                   XAng_Zad_C.mq5 | 
//|                                        Copyright © 2018, ANG3110 | 
//|                                             ANG3110@latchess.com | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, ANG3110"
//---- авторство индикатора
#property link      "ANG3110@latchess.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора Ang_Zad_C     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrLime,clrOrange
//---- отображение метки линии индикатора
#property indicator_label1  "Ang_Zad_C"
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double ki=4.000001;                        // Коэффициент усреднения индикатора 
input Smooth_Method MA_SMethod=MODE_JJMA;        // Метод усреднения
input uint MA_Length=7;                          // Глубина сглаживания                    
input int MA_Phase=15;                           // параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;           // ценовая константа
input int PriceShift=0;                          // cдвиг индикатора по вертикали в пунктах
input int Shift=0;                               // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_1,min_rates_total;
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=2;
   min_rates_total=min_rates_1+GetStartBars(MA_SMethod,MA_Length,MA_Phase);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- превращение динамического массива UpIndBuffer[] в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива DnIndBuffer[] в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XAng_Zad_C(",DoubleToString(ki,4),", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar;
   double price,price_prev,z,z2;
   static double z_prev,z2_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_1;                   // стартовый номер для расчета всех баров        
      UpIndBuffer[first-1]=DnIndBuffer[first-1]=PriceSeries(IPC,first-1,open,low,high,close)+dPriceShift;   
      z_prev=z2_prev=PriceSeries(IPC,first,open,low,high,close);
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
   
   z=z_prev;
   z2=z2_prev;

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      price_prev=PriceSeries(IPC,bar-1,open,low,high,close);
      //----
      if(price>z && price>price_prev) z=z_prev+(price-z_prev)/ki;
      if(price<z && price<price_prev) z=z_prev+(price-z_prev)/ki;
      if(price>z2 && price<price_prev) z2=z2_prev+(price-z2_prev)/ki;
      if(price<z2 && price>price_prev) z2=z2_prev+(price-z2_prev)/ki;
      //----
      UpIndBuffer[bar]=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,z,bar,false);
      DnIndBuffer[bar]=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,z2,bar,false);
      //----
      UpIndBuffer[bar]+=dPriceShift;
      DnIndBuffer[bar]+=dPriceShift;
      //----
      if(bar<rates_total-1)
        {
         z_prev=z;
         z2_prev=z2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
