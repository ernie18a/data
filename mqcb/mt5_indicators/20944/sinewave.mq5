//+------------------------------------------------------------------+
//|                                                     Sinewave.mq5 |
//|                                                                  |
//| Sinewave                                                         |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Coded by Witold Wozniak"
//---- авторство индикатора
#property link      "www.mqlsoft.com"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора Sinewave     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  Red
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "Sinewave"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора LeadSinewave |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  Blue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2  "LeadSinewave"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Параметры окна индикатора                    |
//+----------------------------------------------+
//#property indicator_minimum -1
//#property indicator_maximum 1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
#define MAXPERIOD 100 // константа для ограничения маскимального периода
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;// коэффициент индикатора 
input int Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SineBuffer[];
double LeadSineBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int CP_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве кольцевых буферов
int Count[];
double Smooth[],Price[],Cycle[];
//---- Объявление глобальных переменных
double K0,K1,K2,K3;
double rad2Deg,deg2Rad;
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
 int Size
 )
// Recount_ArrayZeroPos(count, DcPeriod)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
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
//|  получение разницы значений ценовых таймсерий                    |
//+------------------------------------------------------------------+   
double Get_Price(const double  &High[],const double  &Low[],int bar)
// Get_Price(high, low, bar)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   return((High[bar]+Low[bar])/2.0);
  }
//+------------------------------------------------------------------+
//|  Расчёт средней цены финансового актива                          |
//+------------------------------------------------------------------+   
double Get_SmoothVelue
(
 const double &PriceArray[],
 int &CountArray[],
 int bar
 )
// GetSmoothVelue(price, bar)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   return((PriceArray[CountArray[0]]+2*PriceArray[CountArray[1]]
          +2*PriceArray[CountArray[2]]+PriceArray[CountArray[3]])/6);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=7;

//---- получение хендла индикатора CyclePeriod
   CP_Handle=iCustom(NULL,0,"CyclePeriod",Alpha);
   if(CP_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора CyclePeriod");

//---- Инициализация переменных
   K0=MathPow((1.0 - 0.5*Alpha),2);
   K1=2.0;
   K2=K1 *(1.0 - Alpha);
   K3=MathPow((1.0 - Alpha),2);
   rad2Deg = 45.0 / MathArctan(1.0);
   deg2Rad = 1.0 / rad2Deg;

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,MAXPERIOD);
   ArrayResize(Price,MAXPERIOD);
   ArrayResize(Smooth,MAXPERIOD);
   ArrayResize(Cycle,MAXPERIOD);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,LeadSineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Sinewave(",DoubleToString(Alpha,4),", ",Shift,")");
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
   if(BarsCalculated(CP_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar,DcPeriod;
   int bar0,bar1,bar2,bar3;
   double RealPart,ImagPart,DCPhase,Arg,period[1];

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=3; // стартовый номер для расчёта всех баров
      //---- Инициализация массивов переменных
      ArrayInitialize(Count,0.0);
      ArrayInitialize(Price,0.0);
      ArrayInitialize(Smooth,0.0);
      ArrayInitialize(Cycle,0.0);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      bar0=Count[0];
      bar1=Count[1];
      bar2=Count[2];
      bar3=Count[3];

      Price[bar0]=Get_Price(high,low,bar);
      Smooth[bar0]=Get_SmoothVelue(Price,Count,0);

      if(bar>min_rates_total) Cycle[bar0]=K0*(Smooth[bar0]-K1*Smooth[bar1]+Smooth[bar2])+K2*Cycle[bar1]-K3*Cycle[bar2];
      else Cycle[bar0]=(Price[bar0]-2.0*Price[bar1]+Price[bar2])/4.0;

      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(CP_Handle,0,rates_total-1-bar,1,period)<=0) return(RESET);

      DcPeriod=int(MathFloor(period[0]));
      DcPeriod=MathMin(DcPeriod,bar); // урезание усреднения до действительного числа баров

      RealPart=0.0;
      ImagPart=0.0;

      for(int iii=0; iii<DcPeriod; iii++)
        {
         Arg=deg2Rad*360.0*iii/DcPeriod;
         RealPart+=MathSin(Arg)*Cycle[Count[iii]];;
         ImagPart+=MathCos(Arg)*Cycle[Count[iii]];
        }

      DCPhase=0.0;

      if(MathAbs(ImagPart)>0.001) DCPhase=rad2Deg*MathArctan(RealPart/ImagPart);
      else
        {
         if(RealPart >= 0.0) DCPhase = 90.0;
         else DCPhase = -90.0;
        }

      DCPhase+=90.0;
      if(ImagPart<0) DCPhase+=180.0;
      if(DCPhase>315.0) DCPhase-=360.0;

      SineBuffer[bar]=MathSin(DCPhase*deg2Rad);
      LeadSineBuffer[bar]=MathSin((DCPhase+45.0)*deg2Rad);

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,MAXPERIOD);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
