//+------------------------------------------------------------------+ 
//|                                        ColorPEMA_Digit_r_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1 3
//---- отображение метки сигнальной линии
#property indicator_label1  "ColorPEMA_Digit_r"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                         // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "ColorPEMA_Digit_r_HTF"          // Константа для имени индикатора
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_RECOUNT_MODE      // Тип константы
  {
   ONLY_BARS_RECOUNT = 1,     // Обрезаем только пересчёт баров
   ONLY_TIME_RECOUNT,         // Обрезаем только пересчёт во времени
   FULL_RECOUNT               // Полная оптимизация пересчётов
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;     // период графика
input double EmaLength=50.01;                  // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;         // ценовая константа
input int Shift=0;                             // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                        // cдвиг индикатора по вертикали в пунктах
input uint Digit=2;                            // количество разрядов округления
input string  SirName="ColorPEMA_Digit_r";     // Первая часть имени графических объектов
input bool ShowPrice=true;                     // показывать ценовую метку
input ENUM_RECOUNT_MODE RecountMode=FULL_RECOUNT;    // Способ ограничения расчётов индикатора
input uint CountBars=500;                            // количество баров для расчёта индикатора
input uint ReCountTime=60;                           // время в секундах между расчётами индикатора
//+----------------------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,count_bars;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| ColorPEMA_Digit_r indicator initialization function               | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;
   count_bars=int(MathMax(CountBars,min_rates_total));
   int CountBars_htf=10+int(CountBars*PeriodSeconds(PERIOD_CURRENT)/PeriodSeconds(TimeFrame));
//---- получение хендла индикатора ColorPEMA_Digit_r
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ColorPEMA_Digit_r",EmaLength,IPC,0,PriceShift,Digit,SirName,ShowPrice,RecountMode,CountBars_htf,ReCountTime);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorPEMA_Digit_r");
      return(INIT_FAILED);
     }

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига скользящей средней по горизонтали на HMAShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorPEMA_Digit_r HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
  }
//+------------------------------------------------------------------+  
//| ColorPEMA_Digit_r iteration function                             | 
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//---
   static datetime recount_time;
   if(prev_calculated>rates_total || prev_calculated<=0 || prev_calculated!=rates_total) recount_time=NULL;
//--- 
   switch(RecountMode)
     {
      case ONLY_BARS_RECOUNT: break;
      default:
         if(TimeCurrent()-recount_time<int(ReCountTime)) return(rates_total);
         else recount_time=TimeCurrent();
     }
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double Ind[1],Col[1];
   datetime IndTime[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
   
//--- 
   switch(RecountMode)
     {
      case ONLY_TIME_RECOUNT: break;
      default:
        {
         int barx=count_bars;
         limit=int(MathMin(limit,barx));
         //--- осуществление сдвига начала отсчета отрисовки индикатора
         barx=rates_total-1-barx;
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,barx);
         break;
        }
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=1;

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);

      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Col)<=0) return(RESET);

         //---- Загрузка полученных значений в индикаторные буферы
         IndBuffer[bar]=Ind[0];
         ColorIndBuffer[bar]=Col[0];
        }
      if(IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Comment("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика! \n Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
