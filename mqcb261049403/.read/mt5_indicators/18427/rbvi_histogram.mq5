//+------------------------------------------------------------------+
//|                                               RBVI_Histogram.mq5 | 
//|                                        Copyright © 2004, BECEMAL | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2004, BECEMAL"
#property link ""
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrGold,clrBlue,clrGray
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "RBVI_Histogram"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                    // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input int RBVIPeriod=10;                           // период индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём
input uint   HighLevel=60;                         // уровень перезакупа
input uint   LowLevel=40;                          // уровень перепроданности
input int    Shift=0;                              // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- Объявление целых переменных для хранения хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| RBVI indicator initialization function                           | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2+RBVIPeriod;

//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,RBVIPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали на InpKijun
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"RBVI_Histogram(",string(RBVIPeriod),",",EnumToString(VolumeType),",",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,1);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы зелёный, серый и тёмно-розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrTeal);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| RBVI iteration function                                          | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int to_copy,limit,bar;
//---- Объявление переменных с плавающей точкой  
   double Range[],vol0=0,vol1=0,sumn,sump,rel,positive,negative;
   static double positive_,negative_,sumn_,sump_;

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      sumn_=0.0;
      sump_=0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

   to_copy=limit+2;
//---- копируем вновь появившиеся данные в массив Range[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else                         ArraySetAsSeries(volume,true);

//---- восстанавливаем значения переменных
   positive=positive_;
   negative=negative_;
   sumn=sumn_;
   sump=sump_;

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         positive_=positive;
         negative_=negative;
         sumn_=sumn;
         sump_=sump;
        }

      if(VolumeType==VOLUME_TICK)
        {
         vol0=double(tick_volume[bar]);
         vol1=double(tick_volume[bar+1]);
        }
      else
        {
         vol0=double(volume[bar]);
         vol1=double(volume[bar+1]);
        }

      rel=Range[bar]*vol0-Range[bar+1]*vol1;

      if(rel>0) sump= rel;
      else      sumn=-rel;

      positive=(positive*(RBVIPeriod-1)+sump)/RBVIPeriod;
      negative=(negative*(RBVIPeriod-1)+sumn)/RBVIPeriod;

      if(!negative) IndBuffer[bar]=100.0;
      else IndBuffer[bar]=100.0*(1.0-1.0/(1.0+positive/negative));
      
      int clr=1.0;
      if(IndBuffer[bar]>HighLevel) clr=0.0;
      else if(IndBuffer[bar]<LowLevel) clr=2.0;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
