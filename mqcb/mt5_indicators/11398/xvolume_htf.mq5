//+------------------------------------------------------------------+ 
//|                                                  XVolume_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrGray,clrDeepSkyBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение лэйбы индикатора
#property indicator_label1 "Volume HTF"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color2 clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "XVolume HTF"

//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Smooth_Method
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
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_TIMEFRAMES     TimeFrame=PERIOD_H4;     // Период графика
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём
input Smooth_Method XMA_Method=MODE_SMA;           // метод усреднения
input int XLength=12;                              // глубина сглаживания                    
input int XPhase=15;                               // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input bool                ReDraw=true;             // Повтор отображения инфомации на пустых барах
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int XVolume_Handle;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[],IndBuffer1[];
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| XVolume indicator initialization function                        | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;

//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора XVolume не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора XVolume
   XVolume_Handle=iCustom(Symbol(),TimeFrame,"XVolume",VolumeType,XMA_Method,XLength,XPhase,0);
   if(XVolume_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XVolume");
      return(INIT_FAILED);
     }

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(2,IndBuffer1,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XVolume HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| XVolume iteration function                                       | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(XVolume_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double Volume[1],XVolume[1],Col[1];
   datetime XVolumeTime[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=1;
      IndBuffer1[bar]=EMPTY_VALUE;

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,XVolumeTime)<=0) return(RESET);

      if(time[bar]>=XVolumeTime[0] && time[bar+1]<XVolumeTime[0])
        {
         LastCountBar=bar;
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(XVolume_Handle,0,time[bar],1,Volume)<=0) return(RESET);
         if(CopyBuffer(XVolume_Handle,1,time[bar],1,Col)<=0) return(RESET);
         if(CopyBuffer(XVolume_Handle,2,time[bar],1,XVolume)<=0) return(RESET);


         //---- Загрузка полученных значений в индикаторные буферы
         IndBuffer[bar]=Volume[0];
         ColorIndBuffer[bar]=Col[0];
         IndBuffer1[bar]=XVolume[0];
        }

      if(ReDraw)
        {
         if(IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
            IndBuffer1[bar]=IndBuffer1[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
