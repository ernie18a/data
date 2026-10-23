//+---------------------------------------------------------------------+
//|                                Differential_Average_By_Sultonov.mq5 | 
//|                                           Copyright © 2011, Sevan62 | 
//|                                             http://advancetools.net | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Sevan62"
#property link "http://advancetools.net"
#property description "English: Sultonovs Differential Indicator"
#property description "Russian: Дифференциальный индикатор Султонова"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrBlue,clrRed
//---- отображение метки линии индикатора
#property indicator_label1  "Differential_Average_By_Sultonov"

//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
input uint i_nPeriod=1000;  // Calculate period / Период расчета
input Smooth_Method XMethod=MODE_SMA_; //метод усреднения сглаживания 
input uint XLength=12; //глубина сглаживания                    
input int XPhase=15; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
//----
double g_fPoint;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(i_nPeriod);
   min_rates_total=min_rates_1+GetStartBars(XMethod,XLength,XPhase);
   g_fPoint=_Point/10.0;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- запрет на отображения значения индикатора в левом углу
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMethod);
   StringConcatenate(shortname,"Differential_Average_By_Sultonov(",i_nPeriod,", ",Smooth,", ",XLength,", ",XPhase,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
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

//---- Объявление целых переменных и получение уже посчитанных баров
   int first;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {

      double fBullsSumm=0.0,fBearsSumm=0.0;
      int nBullsCnt=0,nBearsCnt=0;
      
      for(int index=0; index<int(i_nPeriod); index++)
        {
         double fCloseCur=PriceSeries(IPC,bar-index,open,low,high,close);
         double fClosePrev=PriceSeries(IPC,bar-index-1,open,low,high,close);
         double fPower=fCloseCur-fClosePrev;
         if(fPower>2*DBL_EPSILON)
           {
            fBullsSumm+=fPower;
            nBullsCnt++;
           }
         if(fPower<-2*DBL_EPSILON)
           {
            fBearsSumm-=fPower;
            nBearsCnt++;
           }
        }

      double farrBulls=(nBullsCnt==0)?0.0:fBullsSumm/nBullsCnt/g_fPoint;
      double farrBears=(nBearsCnt==0)?0.0:fBearsSumm/nBearsCnt/g_fPoint;
      //---- Два вызова функции XMASeries. 
      UpIndBuffer[bar]=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMethod,XPhase,XLength,farrBulls,bar,false);
      DnIndBuffer[bar]=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,XMethod,XPhase,XLength,farrBears,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
