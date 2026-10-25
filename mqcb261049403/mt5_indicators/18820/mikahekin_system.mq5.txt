//+------------------------------------------------------------------+ 
//|                                             Mikahekin_System.mq5 | 
//|                                                                  | 
//|                              Modified by: Ronald Verwer/ROVERCOM |
//+------------------------------------------------------------------+ 
#property copyright ""
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 12
#property indicator_buffers 12 
//---- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "Mikahekin_System Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type2   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы
#property indicator_color2 clrGray,clrRed,clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width2  5
//---- отображение метки индикатора
#property indicator_label2  "Signal"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 3            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета индикатора использован синий цвет
#property indicator_color3 clrBlue
//---- толщина индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Buy StopLoss"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 4            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color4 clrMagenta
//---- толщина индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "Sell StopLoss"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 5            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветных свеч
#property indicator_type5 DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color5 clrYellow,clrPeachPuff,clrGray,clrPowderBlue,clrDeepSkyBlue
//---- линия индикатора - сплошная
#property indicator_style5 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width5 2
//---- отображение метки индикатора
#property indicator_label5 "Mikahekin_System_BARS"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input int KPeriod=3;
input int JPeriod=7;
input int Shift=1;                        // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double UpperBuffer[],LowerBuffer[],OpMiddleBuffer[];
double ClMiddleBuffer[],ColorMiddleBuffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
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
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,OpMiddleBuffer,INDICATOR_CALCULATIONS);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   //---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(OpMiddleBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ClMiddleBuffer,INDICATOR_CALCULATIONS);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ClMiddleBuffer,true);
   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ColorMiddleBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorMiddleBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(7,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,ExtCloseBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(11,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   //---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtColorBuffer,true);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Mikahekin( ",KPeriod,", ",JPeriod,", ",Shift," )");
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
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
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
      
      
      UpperBuffer[bar]=UpBuffer[bar]=sumhigh/JPeriod;
      LowerBuffer[bar]=DnBuffer[bar]=sumlow /JPeriod;

      if(bar) Recount_ArrayZeroPos(Count);
     }
     
//---- корректировка значения переменной  limit
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
       limit-=int(Shift); // стартовый номер для расчета всех баров     
//---- Основной цикл раскраски баров индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      ExtOpenBuffer[bar]=NULL;
      ExtCloseBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;

      if(close[bar]>UpBuffer[bar+Shift])
        {
         if(open[bar]<=close[bar]) clr=4;
         else clr=3;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      if(close[bar]<DnBuffer[bar+Shift])
        {
         if(open[bar]>close[bar]) clr=0;
         else clr=1;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      ExtColorBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
