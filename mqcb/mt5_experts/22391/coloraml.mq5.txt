//+------------------------------------------------------------------+
//|                                                     ColorAML.mq5 |
//|                                                         andreybs |
//|                                               andreybs@yandex.ru |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Adaptive Market Level"
//---- авторство индикатора
#property link      "andreybs@yandex.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrRed,clrGray,clrMediumSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
//---- отображение бычей метки индикатора
#property indicator_label1  "AML"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Fractal=6;
input int Lag=7;
input int Shift=0; //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double AMLBuffer[];
double ColorAMLBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,size;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
int Count[];
double Smooth[];
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
//| расчёт максимального диапозона движения цены                     |
//+------------------------------------------------------------------+
double Range(int period,int start,const double &High[],const double &Low[])
  {
//----
   double max = High[ArrayMaximum(High,start,period)];
   double min = Low[ArrayMinimum(Low,start,period)];
//----
   return(max-min);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=Fractal+Lag;

//---- Инициализация переменных
   size=Lag+1;

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,size);
   ArrayResize(Smooth,size);

//---- Инициализация массивов переменных
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(Count,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,AMLBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(AMLBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorAMLBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorAMLBuffer,true);

//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AML(",Fractal,", ",Lag,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   int MaxBar,limit,bar;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      ColorAMLBuffer[limit]=1;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

   MaxBar=rates_total-min_rates_total-3;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double R1 = Range(Fractal,bar,high,low)/Fractal;
      double R2 = Range(Fractal,bar+Fractal,high,low)/Fractal;
      double R3 = Range(2*Fractal,bar,high,low)/(2*Fractal);

      double dim=0;
      if(R1+R2>0 && R3>0) dim=(MathLog(R1+R2)-MathLog(R3))*1.44269504088896;

      double alpha=MathExp(-Lag*(dim-1.0));
      alpha=MathMin(alpha,1.0);
      alpha=MathMax(alpha,0.01);

      double price=(high[bar]+low[bar]+2*open[bar]+2*close[bar])/6;
      Smooth[Count[0]]=alpha*price+(1.0-alpha)*Smooth[Count[1]];

      if(MathAbs(Smooth[Count[0]]-Smooth[Count[Lag]])>=Lag*Lag*_Point) AMLBuffer[bar]=Smooth[Count[0]];
      else AMLBuffer[bar]=AMLBuffer[bar+1];
      
      ColorAMLBuffer[bar]=ColorAMLBuffer[bar+1];
      
      if(AMLBuffer[bar]>AMLBuffer[bar+1]) ColorAMLBuffer[bar]=2;
      if(AMLBuffer[bar]<AMLBuffer[bar+1]) ColorAMLBuffer[bar]=0;
      
      if(bar) Recount_ArrayZeroPos(Count,Lag+1);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
