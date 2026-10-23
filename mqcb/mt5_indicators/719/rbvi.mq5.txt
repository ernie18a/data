//+------------------------------------------------------------------+
//|                                                         RBVI.mq5 | 
//|                                        Copyright © 2004, BECEMAL | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2004, BECEMAL"
#property link ""
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "RBVI"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 60
#property indicator_level2 40
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input int RBVIPeriod=10; //период индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //объём
input int Shift=0; //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double RbviBuffer[];
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
   SetIndexBuffer(0,RbviBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(RbviBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"RBVI(",string(RBVIPeriod),",",EnumToString(VolumeType),",",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,1);
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);

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
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(0);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else                        ArraySetAsSeries(volume,true);

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

      if(negative==0.0) RbviBuffer[bar]=0.0;
      else RbviBuffer[bar]=100.0*(1.0-1.0/(1.0+positive/negative));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
