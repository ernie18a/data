//+------------------------------------------------------------------+
//|                                                     Beginner.mq5 |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, EarnForex"
#property link      "http://www.earnforex.com"
#property version   "2.00"
#property description "Beginner - basic indicator for marking chart's highs and lows."
#property description "Repaints."
#property description "Исправленая версия индикатора!"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение медвежьей метки индикатора
#property indicator_label1  "Beginner Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычьей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычьей метки индикатора
#property indicator_label2 "Beginner Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define  RESET     0 // константа для возврата терминалу команды на пересчёт индикатора
#define  UP       +1
#define  DOWN     -1
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Otstup = 30; //Shift
input uint Per=9;       //Period
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---- объявление целочисленных переменных начала отсчёта данных
int min_rates_total,ATRPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных
   ATRPeriod=10;
   min_rates_total=int(MathMax(Per,ATRPeriod));
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Beginner Sell");
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Beginner Buy");
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для подокон 
   string short_name="Beginner";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
  }
//+------------------------------------------------------------------+
//| GetRange()                                                       |
//+------------------------------------------------------------------+
double GetRange(uint Len,const double &H[],const double &L[],int index)
  {
   double AvgRange,Range;
//---
   AvgRange=0.0;
   for(int count=index; count<int(index+Len); count++) AvgRange+=MathAbs(H[count]-L[count]);
   Range=AvgRange/Len;
//----
   return(Range);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int limit,bar;
   double Range,SHMax,SHMin,diff;
   static int trend;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      trend=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Range=GetRange(ATRPeriod,High,Low,bar)/3;
      SellBuffer[bar]=0;
      BuyBuffer[bar]=0;
//---
      SHMax=High[ArrayMaximum(High,bar,Per)];
      SHMin=Low[ArrayMinimum(Low,bar,Per)];
      diff=(SHMax-SHMin)*Otstup/100.0;
//---
      if(Close[bar]<SHMin+diff && trend!=DOWN)
        {
         SellBuffer[bar]=High[bar]+Range;
         if(bar) trend=DOWN;
        }
      else if(Close[bar]>SHMax-diff && trend!=UP)
        {
         BuyBuffer[bar]=Low[bar]-Range;
         if(bar) trend=UP;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
