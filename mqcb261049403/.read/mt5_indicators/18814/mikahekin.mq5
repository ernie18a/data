//+------------------------------------------------------------------+ 
//|                                                    Mikahekin.mq5 | 
//|                                                                  | 
//|                              Modified by: Ronald Verwer/ROVERCOM |
//+------------------------------------------------------------------+ 
#property copyright ""
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 5
#property indicator_buffers 5 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы
#property indicator_color1 Gray,Red,Lime
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1  5
//---- отображение метки индикатора
#property indicator_label1  "Signal"

//---- отрисовка индикатора в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color2 Magenta
//---- толщина индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Buy StopLoss"

//---- отрисовка индикатора в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color3 Blue
//---- толщина индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Sell StopLoss"

//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int KPeriod=3;
input int JPeriod=7;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double UpperBuffer[];
double LowerBuffer[];
double OpMiddleBuffer[];
double ClMiddleBuffer[];
double ColorMiddleBuffer[];
//---- Объявление глобальных переменных
int Count[];
double Highest[],Lowest[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[]// Возврат по ссылке номера текущего значения ценового ряда
 )
// Recount_ArrayZeroPos(count)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=MathMax(KPeriod,JPeriod);
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=KPeriod+JPeriod;

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,JPeriod);
   ArrayResize(Highest,JPeriod);
   ArrayResize(Lowest,JPeriod);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,OpMiddleBuffer,INDICATOR_CALCULATIONS);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(OpMiddleBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ClMiddleBuffer,INDICATOR_CALCULATIONS);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ClMiddleBuffer,true);
   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorMiddleBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorMiddleBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Mikahekin( ",KPeriod,", ",JPeriod," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double sumlow,sumhigh,sumopen,sumclose,Max,Min,Op,Cl;
//---- Объявление целых переменных
   int limit,bar;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
        limit=rates_total-KPeriod-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров
     
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- Основной цикл расчёта средней линии канала
   for(bar=limit; bar>=0; bar--)
     {
      Highest[Count[0]]=high[ArrayMaximum(high,bar,KPeriod)];
      Lowest [Count[0]]=low [ArrayMinimum(low, bar,KPeriod)];

      if(bar>rates_total-min_rates_total-1)
        {
         Recount_ArrayZeroPos(Count);
         continue;
        }

      sumlow=0.0;
      sumhigh=0.0;
      sumopen=0.0;
      sumclose=0.0;

      for(int kkk=0; kkk<JPeriod; kkk++)
        {
         sumopen+=open[bar+kkk];
         sumclose+=close[bar+kkk];
         
         sumlow +=Lowest [Count[kkk]];
         sumhigh+=Highest[Count[kkk]];
        }
      
      Op=sumopen /JPeriod;
      Cl=sumclose/JPeriod; 
      
      Max=MathMax(Op,Cl);
      Min=MathMin(Op,Cl);
      
      if(!(Max-Min)) Max+=_Point;
      

      ClMiddleBuffer[bar]=Max;
      OpMiddleBuffer[bar]=Min;
     
      ColorMiddleBuffer[bar]=0; 
      if(Cl>Op) ColorMiddleBuffer[bar]=2;
      if(Cl<Op) ColorMiddleBuffer[bar]=1;
      
      
      UpperBuffer[bar]=sumhigh/JPeriod;
      LowerBuffer[bar]=sumlow /JPeriod;

      if(bar>0) Recount_ArrayZeroPos(Count);
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
