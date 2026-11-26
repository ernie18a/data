//+---------------------------------------------------------------------+
//|                                                        XROC2_VG.mq5 |
//|                            Copyright © 2006, Vladislav Goshkov (VG) |
//|                                                         4vg@mail.ru |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Vladislav Goshkov (VG)"
#property link      "4vg@mail.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака
#property indicator_color1  clrLightSeaGreen,clrMediumOrchid
//---- отображение метки индикатора
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
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_TYPE
  {
   MOM=1,  //MOM
   ROC,    //ROC
   ROCP,   //ROCP
   ROCR,   //ROC
   ROCR100 //ROCR100
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
   MODE_AMA    //AMA
  }; */
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint ROCPeriod1=8;
input Smooth_Method MA_Method1=MODE_JJMA;          //метод усреднения первого индикатора 
input uint Length1=5;                              //глубина  первого сглаживания                    
input int Phase1=15;                               //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ROCPeriod2=14;
input Smooth_Method MA_Method2=MODE_JJMA;          //метод усреднения второго индикатора 
input uint Length2 = 5;                            //глубина  второго сглаживания 
input int Phase2=15;                               //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input ENUM_TYPE ROCType=MOM;
input int Shift=0;                                 //сдвиг индикатора по горизонтали в барах
input double Level1=+0.005;
input double Level2=+0.002;
input double Level3=0.00;
input double Level4=-0.002;
input double Level5=-0.005;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer1[];
double IndBuffer2[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=GetStartBars(MA_Method1,Length1,Phase1);
   int min_rates_2=GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=int(MathMax(min_rates_1+ROCPeriod1,min_rates_2+ROCPeriod2));
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- инициализации переменной для короткого имени индикатора
   string short_name="ROC2_VG( "+EnumToString(ROCType)+", "+string(ROCPeriod1)+", "+string(ROCPeriod2)+")";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Level2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,Level3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,Level4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,Level5);
//---- в качестве цветов линий горизонтальных уровней использованы цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrDodgerBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASHDOTDOT);
//---- завершение инициализации
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
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double price,prevPrice,res1=NULL,res2=NULL;
//---- Объявление целых переменных
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=close[bar];
      prevPrice=close[MathMax(0,bar-int(ROCPeriod1))];
      switch(ROCType)
        {
         case MOM : res1=(price-prevPrice);               break; //"MOM"
         case ROC : res1=((price/prevPrice)-1)*100;       break; //"ROC"
         case ROCP : res1=(price-prevPrice)/prevPrice;    break; //"ROCP"
         case ROCR : res1=(price/prevPrice);              break; //"ROCR"
         case ROCR100 : res1=(price/prevPrice)*100;       break; //"ROCR100"
         default: res1=(price-prevPrice)/prevPrice;       break;
        }
      IndBuffer1[bar]=XMA1.XMASeries(ROCPeriod1+1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,res1,bar,false);
      //----
      prevPrice=close[MathMax(0,bar-int(ROCPeriod2))];
      switch(ROCType)
        {
         case MOM : res2=(price-prevPrice);               break; //"MOM"
         case ROC : res2=((price/prevPrice)-1)*100;       break; //"ROC"
         case ROCP : res2=(price-prevPrice)/prevPrice;    break; //"ROCP"
         case ROCR : res2=(price/prevPrice);              break; //"ROCR"
         case ROCR100 : res2=(price/prevPrice)*100;       break; //"ROCR100"
         default: res2=(price-prevPrice)/prevPrice;       break;
        }
      IndBuffer2[bar]=XMA2.XMASeries(ROCPeriod2+1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,res2,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
