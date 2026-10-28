//+------------------------------------------------------------------+
//|                                    Chande_Kroll_Stop_v1_Sign.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Gold цвет
#property indicator_color1  clrGold
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычьей метки индикатора
#property indicator_label1  "Chande_Kroll_Stop_v1 Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Chande_Kroll_Stop_v1 Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint   Length=20;
input uint   ATRPeriod=10;
input double Kv=3;
input int    Shift=0; // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---- объявление целых переменных для хендлов индикаторов
int ATR_Handle,ATR1_Handle;
//---- объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве кольцевых буферов
int Count[];
double smin[],smax[];
//+------------------------------------------------------------------+
//| Пересчёт позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
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
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+    
int OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   int ATRPeriod1=15;
   min_rates_total=int(ATRPeriod+Length)+3;
   MathMax(min_rates_total,ATRPeriod1);
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR1
   ATR1_Handle=iATR(NULL,0,ATRPeriod1);
   if(ATR1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR1");
      return(INIT_FAILED);
     }
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,Length);
   ArrayResize(smin,Length);
   ArrayResize(smax,Length);
   ArrayInitialize(smin,-999999);
   ArrayInitialize(smax,+999999);
   ArraySetAsSeries(smin,true);
   ArraySetAsSeries(smax,true);
   ArraySetAsSeries(Count,0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(SellBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(BuyBuffer,true);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Chande_Kroll_Stop_v1_Sign(",Length,", ",ATRPeriod,", ",Kv,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(ATR1_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int limit,to_copy,bar;
   double ATR[],ATR1[],UpTrend0,DnTrend0;
   static double UpTrend1,DnTrend1;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(ATR1,true);
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-int(ATRPeriod); // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(ATR1_Handle,0,0,to_copy,ATR1)<=0) return(RESET);
//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      smin[Count[0]]=high[ArrayMaximum(high,bar,ATRPeriod)]-Kv*ATR[bar];
      smax[Count[0]]=low[ArrayMinimum(low,bar,ATRPeriod)]+Kv*ATR[bar];
      UpTrend0=smin[ArrayMaximum(smin,0,WHOLE_ARRAY)];
      DnTrend0=smax[ArrayMinimum(smax,0,WHOLE_ARRAY)];
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      if(UpTrend1<=DnTrend1 && UpTrend0>DnTrend0) BuyBuffer[bar]=low[bar]-ATR1[bar]*3/8;
      if(UpTrend1>=DnTrend1 && UpTrend0<DnTrend0) SellBuffer[bar]=high[bar]+ATR1[bar]*3/8;
      //---
      if(bar)
        {
         UpTrend1=UpTrend0;
         DnTrend1=DnTrend0;
         Recount_ArrayZeroPos(Count,Length);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
