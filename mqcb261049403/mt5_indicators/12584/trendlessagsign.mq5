//+------------------------------------------------------------------+
//|                                              TrendlessAGSign.mq5 |
//|                                       Copyright © 2012, Barmaley | 
//|                                                                  | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2012, Barmaley"
//--- ссылка на сайт автора
#property link ""
#property description "Семафорный стрелочный сигнальный индикатор, фиксирующий пробой нулевой линии Осциллятора Бестрендовости"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "TrendlessAGSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован BlueViolet цвет
#property indicator_color2  clrBlueViolet
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "TrendlessAGSign Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint MAPeriod=7;                          // Период скользящей средней в формуле осциллятора
input  ENUM_MA_METHOD   MAType=MODE_EMA;        // Метод усреднения скользящей средней в формуле осциллятора
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE; // Входная цена скользящей средней в формуле осциллятора
input uint PointsCount=600;                     // Количество точек для расчета индикатора. Форекс-клуб рекомендует месяц для часовиков
input uint In100=90;                            // Сколько % точек индикатора должны входить в интервал +-100%
input int  Shift=0;                             // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление глобальных переменных
int Count[],Start;
double Value[],Sort[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
int ATR_Handle,MA_Handle;
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;
//---
   Max2=Size;
   Max1=Max2-1;
//---
   count--;
   if(count<0) count=Max1;
//---
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(PointsCount+MAPeriod);
   int ATR_Period=10;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
   Start=int(PointsCount*In100/100);
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,PointsCount);
   ArrayResize(Value,PointsCount);
   ArrayResize(Sort,PointsCount);
//---
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,171);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,171);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname="TrendlessAGSign";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- объявление переменных
   int to_copy,limit;
//--- объявление переменных с плавающей точкой  
   double TrendlessAG0,Res0,ATR[],Ma[];
   static double TrendlessAG1,Res1;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      TrendlessAG1=0.0;
      Res1=0.0;
     }
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,Ma)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(Ma,true);
//---
   TrendlessAG0=TrendlessAG1;
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      Res0=close[bar]-Ma[bar];
      Value[Count[0]]=MathAbs(Res0);
      if(bar>0) Recount_ArrayZeroPos(Count,PointsCount);
      if(bar>rates_total-min_rates_total-1) continue;
      ArrayCopy(Sort,Value,0,0,WHOLE_ARRAY);
      ArraySort(Sort);
      double level_100=Sort[Start];
      if(level_100) Res0*=100/(level_100);
      else Res0=EMPTY_VALUE;
      //---
      if(Res0>0.0 && Res1<=0.0) BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
      if(Res0<0.0 && Res1>=0.0) SellBuffer[bar]=high[bar]+ATR[0]*3/8;
      //---
      if(bar)
        {
         TrendlessAG1=TrendlessAG0;
         Res1=Res0;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
