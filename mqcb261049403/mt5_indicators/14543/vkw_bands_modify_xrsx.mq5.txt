//+---------------------------------------------------------------------+
//|                                           VKW_Bands_Modify_XRSX.mq5 | 
//|                                     Copyright © 2008, Alksnis Gatis | 
//|                                                   2xpoint@gmail.com | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): terminal_data_folder\MQL5\Include             |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, Alksnis Gatis"
#property link "2xpoint@gmail.com"
#property description "Индикатор показывает, где выставлять отложенные ордера"
#property description "Когда сизая линия пересекает салатовую или розовую и отходит обратно, тогда следует выставлять отложенный ордер"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован SlateGray цвет
#property indicator_color1 clrSlateGray
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "METRO_XRSX"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color2 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "VKW_Bands Upper"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkOrange цвет
#property indicator_color3 clrDarkOrange
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "VKW_Bands Lower"
//+-----------------------------------+
//| Параметры уровней                 |
//+-----------------------------------+
#property indicator_level1 60
#property indicator_level2 40
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0                      // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
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
input Smooth_Method DSmoothMethod=MODE_JJMA; // Метод усреднения цены
input int DPeriod=15;  // Период скользящей средней
input int DPhase=100;  // Параметр усреднения скользящей средней
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int StepSizeFast=5;                             // Быстрый шаг
input int StepSizeSlow=15;                            // Медленный шаг
input int IShift=0;                                   // Сдвиг индикатора по горизонтали в барах 
input Applied_price_ IPC=PRICE_CLOSE;                 // Ценовая константа
input uint RPeriod=25;                                // Период поиска для экстремумов
input Smooth_Method SmMA_Method=MODE_SMA;             // Метод сглаживания
input uint SLength=3;                                 // Глубина сглаживания
input int SPhase=100;                                 // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int SShift=0;                                   // Сдвиг индикатора канала по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],UpIndBuffer[],DnIndBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   min_rates_1+=int(RPeriod);
   min_rates_total=min_rates_1+GetStartBars(SmMA_Method,SLength,SPhase);
//---- получение хендла индикатора ColorMETRO_XRSX
   Ind_Handle=iCustom(NULL,0,"ColorMETRO_XRSX",DSmoothMethod,DPeriod,DPhase,StepSizeFast,StepSizeSlow,IPC,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorMETRO_XRSX");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,IShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,SShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpIndBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,SShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(DnIndBuffer,true);

//---- инициализация переменной для короткого имени индикатора
   string shortname="VKW_Bands_METRO_XRSX";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<int(min_rates_total)) return(RESET);
//---- объявление переменных с плавающей точкой  
   double d_max,d_min;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,to_copy,bar,maxbar;
   maxbar=rates_total-1-min_rates_1;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1+int(RPeriod);
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(Ind_Handle,0,0,to_copy,IndBuffer)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      d_max=IndBuffer[ArrayMaximum(IndBuffer,bar,RPeriod)];
      d_min=IndBuffer[ArrayMinimum(IndBuffer,bar,RPeriod)];
      UpIndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,SmMA_Method,SPhase,SLength,d_max,bar,true);
      DnIndBuffer[bar]=XMA2.XMASeries(maxbar,prev_calculated,rates_total,SmMA_Method,SPhase,SLength,d_min,bar,true);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
