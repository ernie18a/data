//+---------------------------------------------------------------------+
//|                                                       VininI_BB.mq5 |
//|                        Copyright © 2011, Victor Niclolaev aka Vinin |
//|                                                       vinin@mail.ru |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Victor Niclolaev aka Vinin"
#property link      "vinin@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора 1  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован оливковый цвет
#property indicator_color1 clrOliveDrab
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "Upper VininI_BB"
//+-----------------------------------+
//| Параметры отрисовки индикатора 2  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован серый цвет
#property indicator_color2 clrGray
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "Middle VininI_BB"
//+-----------------------------------+
//| Параметры отрисовки индикатора 3  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован какао цвет
#property indicator_color3 clrPaleVioletRed
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "Lower VininI_BB"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1;
CStdDeviation STD;
//+-----------------------------------+
//| Объявление перечислений           |
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
//| Объявление перечислений           |
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method JMethod=MODE_SMA; // Метод первого усреднения
input uint JLength=100; // Глубина  первого сглаживания
input int JPhase=15; // Параметр первого среднения
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input double BandsDeviation=1.0; // Девиация
input Applied_price_ IPC=PRICE_CLOSE;// Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double UpperBuffer[];
double MiddleBuffer[];
double lowerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| VininI_BB Channel indicator initialization function              | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(JLength)+1;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,lowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"VininI_BB(JLength=",JLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| VininI_BB Channel iteration function                             | 
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
   double price,xma,stdev;
//---- объявление целочисленных переменных
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      UpperBuffer[first-1]=0.0;
      lowerBuffer[first-1]=99999999.99999999;
     }
   else
     {
      first=prev_calculated-1;// стартовый номер для расчета новых баров
     }
//---- основной цикл расчета канала
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      UpperBuffer[bar]=EMPTY_VALUE;
      lowerBuffer[bar]=EMPTY_VALUE;
      MiddleBuffer[bar]=EMPTY_VALUE;
      //----
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma=XMA1.XMASeries(1,prev_calculated,rates_total,JMethod,JPhase,JLength,price,bar,false);
      stdev=STD.StdDevSeries(1,prev_calculated,rates_total,JLength,BandsDeviation,price,xma,bar,false);
      stdev*=BandsDeviation;
      //----
      UpperBuffer[bar]=UpperBuffer[bar-1];
      lowerBuffer[bar]=lowerBuffer[bar-1];
      if(high[bar]>UpperBuffer[bar])
        {
         UpperBuffer[bar]=high[bar];
         lowerBuffer[bar]=high[bar]-2.0*stdev;
         if(lowerBuffer[bar]<lowerBuffer[bar-1]) lowerBuffer[bar]=lowerBuffer[bar-1];
        }
      if(low[bar]<lowerBuffer[bar])
        {
         lowerBuffer[bar]=low[bar];
         UpperBuffer[bar]=low[bar]+2.0*stdev;
         if(UpperBuffer[bar]>UpperBuffer[bar-1]) UpperBuffer[bar]=UpperBuffer[bar-1];
        }
      MiddleBuffer[bar]=(UpperBuffer[bar]+lowerBuffer[bar])*0.5;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
