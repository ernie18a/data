//+---------------------------------------------------------------------+
//|                                        Fractal_WeightOscillator.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для успешной компиляции  индикатора  следует                        |
//| положить файл SmoothAlgorithms.mqh в папку (директорию):            |
//| каталог_данных_терминала\\MQL5\Include,                             |
//| положить откомпилированные файлы индикаторов Fractal_RSI.ex5,       |
//| Fractal_MFI.ex5, Fractal_WPR.ex5 и Fractal_DeMarker.ex5             |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Indicators     |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description  "Осциллятор, представляющий взвешенную сглаженную сумму четырёх индикаторов - Fractal_RSI, Fractal_MFI, Fractal_WPR и Fractal_DeMarker."
//---- Включение индикаторов в код эксперта как ресурсов
#resource "\\Indicators\\Fractal_RSI.ex5"
#resource "\\Indicators\\Fractal_MFI.ex5"
#resource "\\Indicators\\Fractal_WPR.ex5"
#resource "\\Indicators\\Fractal_DeMarker.ex5"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------------------+
//|  Параметры отрисовки индикатора               |
//+-----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrTeal,clrPaleTurquoise,clrGray,clrViolet,clrDeepPink
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "Fractal_WeightOscillator"
//+-----------------------------------------------+
//| Параметры отображения горизонтальных уровней  |
//+-----------------------------------------------+
#property indicator_level1  0
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//| Параметры ширины окна индикатора             |
//+----------------------------------------------+
#property indicator_maximum +100.0
#property indicator_minimum    0.0
//+-----------------------------------------------+
//|  объявление констант                          |
//+-----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------------+
//|  Описание класса CXMA                         |
//+-----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------------------+
//|  объявление перечислений                      |
//+-----------------------------------------------+
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
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
//+-----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                 |
//+-----------------------------------------------+
input uint e_period=30; //глубина  усреднения Fractal_WeightOscillator                  
input uint normal_speed=30;
//---- Параметры RSI
input double RSIWeight=1.0;
input ENUM_APPLIED_PRICE_  RSIPrice=PRICE_CLOSE_;
//---- Параметры MFI
input double MFIWeight=1.0;
input ENUM_APPLIED_PRICE_  MFIPrice=PRICE_TYPICAL_;
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;
//---- Параметры WPR
input double WPRWeight=1.0;
//---- Параметры DeMarker
input double DeMarkerWeight=1.0;
//---- Включение сглаживания волны
input Smooth_Method bMA_Method=MODE_JJMA; //метод усреднения
input uint bLength=7; //глубина сглаживания                    
input int bPhase=100; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint HighLevel=70;         // уровень перезакупа
input uint LowLevel=30;          // уровень перепроданности
//+-----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[],ColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_total_1;
//---- Объявление переменной для суммарного весового коэффициента
double SumWeight;
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle,MFI_Handle,WPR_Handle,DeMarker_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Проверка значения уровня перекупленности корректность
  if(HighLevel<50)
     {
      Print(" Значение уровня перекупленности должно быть не меньше 50");
      return(INIT_FAILED);
     }
//---- Проверка значения уровня перепроданности на корректность
  if(LowLevel>50)
     {
      Print(" Значение уровня перепроданности должно быть не больше 50");
      return(INIT_FAILED);
     }
     
//---- Инициализация переменных начала отсчёта данных
   min_rates_total_1=int(MathMax(e_period,normal_speed))+3;
   min_rates_total=min_rates_total_1+GetStartBars(bMA_Method,bLength,bPhase);
   SumWeight=RSIWeight+MFIWeight+WPRWeight+DeMarkerWeight;

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("bLength",bLength);
   XMA1.XMAPhaseCheck("bPhase",bPhase,bMA_Method);

//---- получение хендла индикатора Fractal_RSI
   RSI_Handle=iCustom(NULL,0,"::Indicators\\Fractal_RSI",e_period,normal_speed,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fractal_RSI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Fractal_MFI
   MFI_Handle=iCustom(NULL,0,"::Indicators\\Fractal_MFI",e_period,normal_speed,MFIPrice,MFIVolumeType);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fractal_MFI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Fractal_WPR
   WPR_Handle=iCustom(NULL,0,"::Indicators\\Fractal_WPR",e_period,normal_speed);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fractal_WPR");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Fractal_DeMarker
   DeMarker_Handle=iCustom(NULL,0,"::Indicators\\Fractal_DeMarker",e_period,normal_speed);
   if(DeMarker_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fractal_DeMarker");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(bMA_Method);
   StringConcatenate(shortname,"Fractal_WeightOscillator(",bLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы 
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(MFI_Handle)<rates_total
      || BarsCalculated(WPR_Handle)<rates_total
      || BarsCalculated(DeMarker_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,maxbar;
   double RSI[],MFI[],WPR[],DeMarker[],WeightOscillator;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   if(CopyBuffer(MFI_Handle,0,0,to_copy,MFI)<=0) return(RESET);
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);
   if(CopyBuffer(DeMarker_Handle,0,0,to_copy,DeMarker)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(MFI,true);
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(DeMarker,true);
//----   
   maxbar=rates_total-min_rates_total_1-1;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      WeightOscillator=(RSIWeight*RSI[bar]+MFIWeight*MFI[bar]+WPRWeight*(WPR[bar]+100)+DeMarkerWeight*100*DeMarker[bar])/SumWeight;      
      UpBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,bMA_Method,bPhase,bLength,WeightOscillator,bar,true);
      DnBuffer[bar]=50.0;
      int clr=2.0;
      if(UpBuffer[bar]>HighLevel) clr=0.0;
      else if(UpBuffer[bar]>50) clr=1.0;
      else if(UpBuffer[bar]<LowLevel) clr=4.0;     
      else if(UpBuffer[bar]<50) clr=3.0;
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
