//+------------------------------------------------------------------+ 
//|                                        i4_GoldenLionTrend_v3.mq5 | 
//|                             Copyright © 2006, goldenlion@ukr.net |
//|                                      http://GlobeInvestFund.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, goldenlion@ukr.net"
#property link      "http://GlobeInvestFund.com/"
#property description "Индикатор силы тренда с использованием значений двух каналов Боллинджера"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы
#property indicator_color1 clrLime,clrTeal,clrPurple,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "i4_GoldenLionTrend_v3"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint BBPeriod=20;                              //период для расчета средней линии
input double StdDeviation1=1.0001;                   //девиация 1
input double StdDeviation2=2.0001;                   //девиация 2
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; //тип цены
input int Shift=0;                                   //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle1,Ind_Handle2;
//---- индикаторный буфер
double UpIndBuffer[],DnIndBuffer[],ColorIndBuffer[];
//---- Объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(BBPeriod);

   if(StdDeviation1>=StdDeviation2)
     {
      Print("Девиация 1 должна быть больше, чем Девиация 2!");
      Print("Откорректируйте значения входных параметров!");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iBands1
   Ind_Handle1=iBands(NULL,0,BBPeriod,0,StdDeviation1,applied_price);
   if(Ind_Handle1==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iBands1");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора iBands2
   Ind_Handle2=iBands(NULL,0,BBPeriod,0,StdDeviation2,applied_price);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iBands2");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ColorIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"i4_GoldenLionTrend_v3",BBPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(Ind_Handle1)<rates_total || BarsCalculated(Ind_Handle2)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double UpBB1[],DnBB1[];
   double UpBB2[],DnBB2[];

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle1,UPPER_BAND,0,to_copy,UpBB1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle1,LOWER_BAND,0,to_copy,DnBB1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle2,UPPER_BAND,0,to_copy,UpBB2)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle2,LOWER_BAND,0,to_copy,DnBB2)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(UpBB1,true);
   ArraySetAsSeries(DnBB1,true);
   ArraySetAsSeries(UpBB2,true);
   ArraySetAsSeries(DnBB2,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(close[bar]<UpBB1[bar] && close[bar]>DnBB1[bar])
        {
         UpIndBuffer[bar]=NULL;
         DnIndBuffer[bar]=NULL;
         continue;
        }

      UpIndBuffer[bar]=high[bar];
      DnIndBuffer[bar]=low[bar];

      if(close[bar]>=UpBB2[bar]) ColorIndBuffer[bar]=0;
      else if(close[bar]>=UpBB1[bar]) ColorIndBuffer[bar]=1;
      else if(close[bar]<=DnBB2[bar]) ColorIndBuffer[bar]=3;
      else if(close[bar]<=DnBB1[bar]) ColorIndBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
