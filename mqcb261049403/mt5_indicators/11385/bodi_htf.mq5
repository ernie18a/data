//+------------------------------------------------------------------+ 
//|                                                     BoDi_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- номер версии индикатора
#property version   "1.60"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//--- отрисовка индикатора в виде трёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов трёхцветной гистограммы использованы
#property indicator_color1 clrDeepPink,clrGray,clrDodgerBlue
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 5
#property indicator_width1 5
//--- отображение метки индикатора
#property indicator_label1 "BoDi HTF"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input ENUM_TIMEFRAMES     TimeFrame=PERIOD_H4;         // Период графика
input uint                BBPeriod=20;                 // Период для расчета средней линии
input double              StdDeviation=2;              // Кол-во отклонений
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE;   // Тип цены
input bool                ReDraw=true;                 // Повтор отображения инфомации на пустых барах
//+-----------------------------------+
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int BoDi_Handle;
//--- объявление динамических массивов, которые будут в 
//--- дальнейшем использованы в качестве индикаторных буферов
double BoDiBuffer[],ColorBoDiBuffer[];
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| BoDi indicator initialization function                           | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=3;
//--- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора BoDi не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора BoDi
   BoDi_Handle=iCustom(Symbol(),TimeFrame,"BoDi",BBPeriod,StdDeviation,applied_price);
   if(BoDi_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора BoDi");
      return(INIT_FAILED);
     }
//--- превращение динамического массива BoDiBuffer в индикаторный буфер
   SetIndexBuffer(0,BoDiBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BoDiBuffer,true);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorBoDiBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBoDiBuffer,true);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"BoDi HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| BoDi iteration function                                          | 
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(BoDi_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- объявление целочисленных переменных
   int limit,bar;
//--- объявление переменных с плавающей точкой  
   double BoDi[1],Col[1];
   datetime BoDiTime[1];
   static uint LastCountBar;
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
//--- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(time,true);
//--- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- обнулим содержимое индикаторных буферов до расчёта
      BoDiBuffer[bar]=EMPTY_VALUE;
      ColorBoDiBuffer[bar]=1;
      //--- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,BoDiTime)<=0) return(RESET);
      //---
      if(time[bar]>=BoDiTime[0] && time[bar+1]<BoDiTime[0])
        {
         LastCountBar=bar;
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(BoDi_Handle,0,time[bar],1,BoDi)<=0) return(RESET);
         if(CopyBuffer(BoDi_Handle,1,time[bar],1,Col)<=0) return(RESET);
         //--- загрузка полученных значений в индикаторные буферы
         BoDiBuffer[bar]=BoDi[0];
         ColorBoDiBuffer[bar]=Col[0];
        }
      //---
      if(ReDraw)
        {
         if(BoDiBuffer[bar+1]!=EMPTY_VALUE && BoDiBuffer[bar]==EMPTY_VALUE)
           {
            BoDiBuffer[bar]=BoDiBuffer[bar+1];
            ColorBoDiBuffer[bar]=ColorBoDiBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
