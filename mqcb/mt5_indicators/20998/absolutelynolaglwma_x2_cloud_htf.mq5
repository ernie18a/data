//+------------------------------------------------------------------+ 
//|                             AbsolutelyNoLagLwma_x2_cloud_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.62"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                       // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "AbsolutelyNoLagLwma_x2_cloud" // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrAqua,clrHotPink
//---- отображение бычей лэйбы индикатора
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H1;//Период графика
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H4;//Период графика
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint Length=7; // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг по горизонтали в барах
input int PriceShift=0; // cдвиг по вертикали в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle1,Ind_Handle2;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame1<Period() && TimeFrame1!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора AbsolutelyNoLagLwma не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- проверка периодов графиков на корректность
   if(TimeFrame2<Period() && TimeFrame2!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора AbsolutelyNoLagLwma не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;

//---- получение хендла индикатора AbsolutelyNoLagLwma 1
   Ind_Handle1=iCustom(Symbol(),TimeFrame1,"AbsolutelyNoLagLwma",Length,IPC,0,PriceShift);
   if(Ind_Handle1==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma 1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора AbsolutelyNoLagLwma 2
   Ind_Handle2=iCustom(Symbol(),TimeFrame2,"AbsolutelyNoLagLwma",Length,IPC,0,PriceShift);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma 2");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер 
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame1)+","+GetStringTimeframe(TimeFrame2)," ,",Length,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(BarsCalculated(Ind_Handle1)<Bars(Symbol(),TimeFrame1)
      || BarsCalculated(Ind_Handle2)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);

//---- объявления локальных переменных 
   double Ind[1],Col[1];
   int limit1,limit2,bar;
   datetime IndTime[1];
   static double LastInd=0.0;
   static uint LastCountBar1,LastCountBar2;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit1=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      limit2=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar1=rates_total;
      LastCountBar2=rates_total;
     }
   else
     {
      limit1=int(LastCountBar1)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
      limit2=int(LastCountBar2)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора
   for(bar=limit1; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      UpBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TimeFrame1,time[bar],1,IndTime)<=0) return(RESET);

      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar1=bar;
         //---- копируем вновь появившиеся данные в массив Ind
         if(CopyBuffer(Ind_Handle1,0,time[bar],1,Ind)<=0) return(RESET);
         UpBuffer[bar]=Ind[0];
        }
      else UpBuffer[bar]=UpBuffer[bar+1];
     }
//---- основной цикл расчёта индикатора
   for(bar=limit2; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      DnBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TimeFrame2,time[bar],1,IndTime)<=0) return(RESET);

      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar2=bar;
         //---- копируем вновь появившиеся данные в массив Ind
         if(CopyBuffer(Ind_Handle2,0,time[bar],1,Ind)<=0) return(RESET);
         DnBuffer[bar]=Ind[0];
        }
      else DnBuffer[bar]=DnBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
