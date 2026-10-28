//+------------------------------------------------------------------+
//|                                                          CMO.mq5 | 
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property description "CMO"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки индикатора CMO           |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrLightSeaGreen,clrDarkOrange
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "CMO"
//+----------------------------------------------+
//| Параметры горизонтальных уровней индикатора  |
//+----------------------------------------------+
#property indicator_level1  +50
#property indicator_level2    0
#property indicator_level3  -50
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Length=14;                        // Период индикатора
input ENUM_MA_METHOD Method=MODE_SMA;        // Тип усреднения
input ENUM_APPLIED_PRICE Price=PRICE_CLOSE;  // Цена
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double Line1Buffer[];
double Line2Buffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle;
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве кольцевых буферов
int Count[];
double Bulls[],Bears[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CountArray[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
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
      CountArray[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(Length);
//---- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,Length,0,Method,Price);
   if(MA_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMA");
//---- распределение памяти под массивы переменных
   int size=int(Length);
   if(ArrayResize(Count,size)<size) Print("Не удалось распределить память под массив Count[]");
   if(ArrayResize(Bulls,size)<size) Print("Не удалось распределить память под массив Bulls[]");
   if(ArrayResize(Bears,size)<size) Print("Не удалось распределить память под массив Bears[]");
//---
   ArrayInitialize(Count,0);
   ArrayInitialize(Bulls,0);
   ArrayInitialize(Bears,0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Line1Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Line2Buffer,true);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"CMO(",Length,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int limit,to_copy,bar;
   double MA[],dPrice,Sum;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-2-min_rates_total; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+2;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MA,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      dPrice=MA[bar]-MA[bar+1];
      Bulls[Count[0]]=0.5*(MathAbs(dPrice)+dPrice);
      Bears[Count[0]]=0.5*(MathAbs(dPrice)-dPrice);
//---
      double SumBulls=0,SumBears=0;
      for(int iii=0; iii<int(Length); iii++)
        {
         SumBulls+=Bulls[Count[iii]];
         SumBears+=Bears[Count[iii]];
        }
//---
      Sum=SumBulls+SumBears;
      if(Sum) Line1Buffer[bar]=(SumBulls-SumBears)/(SumBulls+SumBears)*100;
      else Line1Buffer[bar]=0.0;
      Line2Buffer[bar]=0.0;
      if(bar) Recount_ArrayZeroPos(Count,Length);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
