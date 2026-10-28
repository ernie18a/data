//+------------------------------------------------------------------+
//|                                                          AML.mq5 |
//|                                                         andreybs |
//|                                               andreybs@yandex.ru |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Adaptive Market Level"
//--- авторство индикатора
#property link      "andreybs@yandex.ru"
//--- номер версии индикатора
#property version   "1.11"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора Cycle         |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован DarkOrchid цвет
#property indicator_color1  clrDarkOrchid
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//--- отображение бычей метки индикатора
#property indicator_label1  "AML"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Fractal=6;
input int Lag=7;
input int Shift=0;    // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double AMLBuffer[];
double LagLagPoint;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total,size;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве кольцевых буферов
int Count[];
double Smooth[];
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
//| Расчет максимального диапозона движения цены                     |
//+------------------------------------------------------------------+
double Range(int period,int start,const double &High[],const double &Low[])
  {
//---
   double max = High[ArrayMaximum(High,start,period)];
   double min = Low[ArrayMinimum(Low,start,period)];
//---
   return(max-min);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=(int)(Fractal+Lag);
//--- инициализация переменных
   LagLagPoint=Lag*Lag*_Point;
   size=Lag+1;
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,size);
   ArrayResize(Smooth,size);
//--- инициализация массивов переменных
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(Count,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,AMLBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(AMLBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AML(",Fractal,", ",Lag,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//--- объявления локальных переменных 
   int limit,bar;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double R1 = Range(Fractal,bar,high,low)/Fractal;
      double R2 = Range(Fractal,bar+Fractal,high,low)/Fractal;
      double R3 = Range(2*Fractal,bar,high,low)/(2*Fractal);
      //---      
      double dim=0;
      if(R1+R2>0 && R3>0) dim=(MathLog(R1+R2)-MathLog(R3))*1.44269504088896;
      //--- 
      double alpha=MathExp(-Lag*(dim-1.0));
      alpha=MathMin(alpha,1.0);
      alpha=MathMax(alpha,0.01);
      //---
      double price=(high[bar]+low[bar]+2*open[bar]+2*close[bar])/6;
      Smooth[Count[0]]=alpha*price+(1.0-alpha)*Smooth[Count[1]];
      //---
      if(MathAbs(Smooth[Count[0]]-Smooth[Count[Lag]])>=LagLagPoint) AMLBuffer[bar]=Smooth[Count[0]];
      else AMLBuffer[bar]=AMLBuffer[bar+1];
      if(bar) Recount_ArrayZeroPos(Count,size);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
