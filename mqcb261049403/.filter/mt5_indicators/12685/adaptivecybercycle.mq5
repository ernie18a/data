//+------------------------------------------------------------------+
//|                                           AdaptiveCyberCycle.mq5 |
//|                                                                  |
//| Adaptive Cyber Cycle                                             |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Coded by Witold Wozniak"
//--- авторство индикатора
#property link      "www.mqlsoft.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора Cycle        |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  Red
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Adaptive Cyber Cycle"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора Trigger      |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  Blue
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;  // Коэффициент индикатора 
input int Shift=0;        // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double CycleBuffer[];
double TriggerBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int CP_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве кольцевых буферов
int Count[];
double Smooth[],Price[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[]) // Возврат по ссылке номера текущего значения ценового ряда
  {
//---
   int numb,Max1,Max2;
   static int count=1;
//---
   Max2=7;
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
   min_rates_total=7+6;
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,7);
   ArrayResize(Smooth,7);
   ArrayResize(Price,7);
//--- инициализация массивов переменных
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(Price,0.0);
//--- получение хендла индикатора CyclePeriod
   CP_Handle=iCustom(NULL,0,"CyclePeriod",Alpha);
   if(CP_Handle==INVALID_HANDLE)
   {
    Print(" Не удалось получить хендл индикатора CyclePeriod");
    return(INIT_FAILED);
    }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,CycleBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3*min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(CycleBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,3*min_rates_total+1);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(TriggerBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Adaptive Cyber Cycle(",DoubleToString(Alpha,4),", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(CP_Handle)<rates_total || rates_total<min_rates_total) return(0);

//--- объявления локальных переменных 
   int MaxBar,limit,bar;
   int bar0,bar1,bar2,bar3;
   double K0,K1,K2,K3,period[1],alpha1;

//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-2; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

   MaxBar=rates_total-min_rates_total-3;

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar0=Count[0];
      bar1=Count[1];
      bar2=Count[2];
      bar3=Count[3];

      Price[bar0]=(high[bar]+low[bar])/2.0;
      Smooth[bar0]=(Price[bar0]+2.0*Price[bar1]+2.0*Price[bar2]+Price[bar3])/6.0;

      if(bar<=MaxBar)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(CP_Handle,0,bar,1,period)<=0) return(0);

         //--- инициализация переменных
         alpha1=2.0/(period[0]+1.0);
         K0=MathPow((1.0 - 0.5*alpha1),2);
         K1=2.0;
         K2=K1 *(1.0 - alpha1);
         K3=MathPow((1.0 - alpha1),2);

         CycleBuffer[bar]=K0*(Smooth[bar0]-K1*Smooth[bar1]+Smooth[bar2])+K2*CycleBuffer[bar+1]-K3*CycleBuffer[bar+2];
        }
      else CycleBuffer[bar]=(Price[bar0]-2.0*Price[bar1]+Price[bar2])/4.0;

      TriggerBuffer[bar]=CycleBuffer[bar+1];
      if(bar>0) Recount_ArrayZeroPos(Count);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
