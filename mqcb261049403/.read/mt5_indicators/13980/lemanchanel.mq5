//+------------------------------------------------------------------+ 
//|                                                  LeManChanel.mq5 | 
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, LeMan."
//---- ссылка на сайт автора
#property link      "b-market@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано три графических построения
#property indicator_plots   2
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Upper LeMan"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Magenta цвет
#property indicator_color2 clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Lower LeMan"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint period=12;
input int Shift=1; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpperBuffer[];
double LowerBuffer[];
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве кольцевых буферов
int Count[];
double HC[],CL[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)    // количество элементов в кольцевом буфере
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+    
//| Indicator initialization function                                |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   min_rates_total=int(period+1);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,period);
   ArrayResize(HC,period);
   ArrayResize(CL,period);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(HC,true);
   ArraySetAsSeries(CL,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"LeManChanel(",period,",",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Indicator iteration function                                     |
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-2; // расчетное количество всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HC[Count[0]]=high[bar]-close[bar+1];
      CL[Count[0]]=close[bar+1]-low[bar];
      //----
      UpperBuffer[bar]=close[bar]+HC[ArrayMaximum(HC,0,period)];
      LowerBuffer[bar]=close[bar]-CL[ArrayMaximum(CL,0,period)];
      //---- пересчет позиций элементов в кольцевых буферах
      if(bar>0) Recount_ArrayZeroPos(Count,period);
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
