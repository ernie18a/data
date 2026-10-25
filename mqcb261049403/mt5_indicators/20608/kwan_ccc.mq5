//+---------------------------------------------------------------------+
//|                                                        KWAN_CCC.mq5 | 
//|                    Copyright © 1999-2017, MetaQuotes Software Corp. |
//|                                            http://www.metaquotes.ru |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 1999-2017, MetaQuotes Software Corp."
#property link "http://www.metaquotes.ru"
#property description "Metatrader4 Code by jjk2. Based on MBA Thesis from Simon Fraser University written by C.E. ALDEA."
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrDodgerBlue,clrGray,clrDeepPink
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "KWAN_CCC"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//---- параметры iChaikin
input uint                fast_ma_period=3;       // быстрый период 
input uint                slow_ma_period=10;      // медленный период
input ENUM_MA_METHOD       ma_method=MODE_LWMA;   // тип сглаживания
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // Объём 
//---- параметры iCCI
input uint                 CCIPeriod=14;         // период индикатора CCI
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;  // Цена CCI индикатора
//---- параметры iMomentum
input uint                 MomentumPeriod=7;         // Период индикатора Momentum
input ENUM_APPLIED_PRICE   MomentumPrice=PRICE_CLOSE; // Цена индикатора Momentum
//---- параметры усреднения индикатора
input Smooth_Method XMA_Method=MODE_JJMA; //метод усреднения
input uint XLength=7;                     //глубина сглаживания                    
input int XPhase=100;                      //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input int Shift=0; //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+

//---- объявление динамического массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Chaikin_Handle,CCI_Handle,Mom_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(MathMax(fast_ma_period,slow_ma_period)+1);
   min_rates_1=int(MathMax(min_rates_1,MathMax(CCIPeriod,MomentumPeriod)));
   min_rates_total=int(min_rates_1+GetStartBars(XMA_Method,XLength,XPhase));

//---- Получение хендлов индикаторов  
   Chaikin_Handle=iChaikin(NULL,0,fast_ma_period,slow_ma_period,ma_method,VolumeType);
   if(Chaikin_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iChaikinastic");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iCCI
   CCI_Handle=iCCI(NULL,0,CCIPeriod,CCIPrice);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMomentum
   Mom_Handle=iMomentum(Symbol(),PERIOD_CURRENT,MomentumPeriod,MomentumPrice);
   if(Mom_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMomentum");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"KWAN_CCC");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//--- завершение инициализации
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
   if(BarsCalculated(Chaikin_Handle)<rates_total
      || BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(Mom_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int limit,bar,to_copy,maxbar;
//---- Объявление переменных с плавающей точкой  
   double Chaikin[],CCI[],Mom[],kwan;
//----   
   maxbar=rates_total-min_rates_total-1;

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=maxbar; // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
   to_copy=limit+1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Chaikin,true);
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(Mom,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Chaikin_Handle,0,0,to_copy,Chaikin)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(Mom_Handle,0,0,to_copy,Mom)<=0) return(RESET);


//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Mom[bar]) kwan=Chaikin[bar]*CCI[bar]/Mom[bar];
      else kwan=100;
      IndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,kwan,bar,true);
     }

   if(!prev_calculated) limit--;
//---- Основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=1;
      if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=0;
      if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
