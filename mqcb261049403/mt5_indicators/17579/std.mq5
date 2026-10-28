//+------------------------------------------------------------------+
//|                                                          STD.mq5 |
//|                                        Copyright © 2010, BECEMAL | 
//|                                           http://www.becemal.ru/ | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2010, BECEMAL"
//---- ссылка на сайт автора
#property link "http://www.becemal.ru/"
#property description "The Simple Trend Detector. Based on code RSI"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 1
//---- использовано два графических построения
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован Violet цвет
#property indicator_color1  clrViolet
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение бычей метки индикатора
#property indicator_label1  "Simple Trend Detector"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80
#property indicator_level2 50
#property indicator_level3 20
#property indicator_levelcolor clrRoyalBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| ПарГраницы окна индикатора                   |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint STDPeriod=15;
input int Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double STDBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Pos[],Neg[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
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
//---- инициализация глобальных переменных 
   min_rates_total=int(STDPeriod);

//---- распределение памяти под массивы переменных  
   ArrayResize(Count,STDPeriod);
   ArrayResize(Pos,STDPeriod);
   ArrayResize(Neg,STDPeriod);

//---- превращение динамического массива STDBuffer в индикаторный буфер
   SetIndexBuffer(0,STDBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(STDBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Simple Trend Detector");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
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
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar;

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(Pos,0.0);
      ArrayInitialize(Neg,0.0);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- Основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double positive=NULL;
      double negative=NULL;
      double rel=close[bar]-open[bar];
      if(rel>0) positive=+rel;
      else      negative=-rel;
      Pos[Count[0]]=positive;
      Neg[Count[0]]=negative;
      
      for(int kkk=0; kkk<int(STDPeriod); kkk++) 
        {
         double Norm=int(STDPeriod)-kkk+1;
         positive+=Norm*Pos[Count[kkk]];
         negative+=Norm*Neg[Count[kkk]]; 
        }
        
      double Den=positive+negative;
      if(!Den) STDBuffer[bar]=100;
      else STDBuffer[bar]=100*positive/Den;
      
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,STDPeriod);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
