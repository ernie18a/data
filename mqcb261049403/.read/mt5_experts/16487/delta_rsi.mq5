//+------------------------------------------------------------------+
//|                                                    Delta_RSI.mq5 |
//|                                              Copyright 2016, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright 2016, Tor"
//---- ссылка на сайт автора
#property link      "http://einvestor.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                // Константа для возврата терминалу команды на пересчет индикатора
#define Up    0                // Константа для растущего тренда
#define Pass  1                // Константа для флета
#define Down  2                // Константа для падающего тренда
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrLime,clrGray,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1 4
//---- отображение метки линии индикатора
#property indicator_label1  "Delta_RSI"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum TypeGraph
  {
   Histogram=0,// Full Histogram
   Cute=1,     // Cute Histogram
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input TypeGraph            TypeGr=Histogram; // Type graph
//---
input uint                 RSIPeriod1=14;    // Fast RSI Period
input ENUM_APPLIED_PRICE   RSIPrice1=PRICE_CLOSE;
//---
input uint                 RSIPeriod2=50;    // Slow RSI Period
input ENUM_APPLIED_PRICE   RSIPrice2=PRICE_CLOSE;
//---
input uint                 Level=50;         // Signal Level
//---
input int                  Shift=0;          // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double rsi1[],rsi2[],delta[],IndBuffer[],ColorIndBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind1_Handle,Ind2_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,maxLevel,minLevel;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора RSI 1
   Ind1_Handle=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod1,RSIPrice1);
   if(Ind1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора RSI 1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора RSI 2
   Ind2_Handle=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod2,RSIPrice2);
   if(Ind2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора RSI 2");
      return(INIT_FAILED);
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(RSIPeriod1,RSIPeriod2));
   maxLevel=int(100-(100-Level));
   minLevel=int(100-Level);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в буфер для хранения данных
   SetIndexBuffer(2,rsi1,INDICATOR_CALCULATIONS);
//---- превращение динамического массива в буфер для хранения данных
   SetIndexBuffer(3,rsi2,INDICATOR_CALCULATIONS);
//---- превращение динамического массива в буфер для хранения данных
   SetIndexBuffer(4,delta,INDICATOR_CALCULATIONS);
   
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
   ArraySetAsSeries(ColorIndBuffer,true);
   ArraySetAsSeries(rsi1,true);
   ArraySetAsSeries(rsi2,true);
   ArraySetAsSeries(delta,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Delta_RSI(",RSIPeriod1,",",RSIPeriod2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(BarsCalculated(Ind1_Handle)<rates_total 
       || BarsCalculated(Ind2_Handle)<rates_total 
       || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,to_copy,bar,clr;
   double ;


//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind1_Handle,0,0,to_copy,rsi1)<=0) return(RESET);
   if(CopyBuffer(Ind2_Handle,0,0,to_copy,rsi2)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      delta[bar] = rsi1[bar]-rsi2[bar];
      if(TypeGr==Cute) IndBuffer[bar]=1;
      else IndBuffer[bar]=delta[bar];
      //---- 
      clr=Pass;
      if(rsi2[bar]>maxLevel && rsi1[bar]>rsi2[bar]) clr=Up;
      if(rsi2[bar]<minLevel && rsi1[bar]<rsi2[bar]) clr=Down;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
