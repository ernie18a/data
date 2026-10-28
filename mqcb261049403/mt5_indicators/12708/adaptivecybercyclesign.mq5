//+------------------------------------------------------------------+
//|                                       AdaptiveCyberCycleSign.mq5 |
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
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "AdaptiveCyberCycle Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован Blue цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "AdaptiveCyberCycle Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0       // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;    // Коэффициент индикатора 
input int Shift=0;          // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int CP_Handle,ATR_Handle;
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
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   int ATR_Period=10;
   min_rates_total=int(MathMax(7+6,ATR_Period));
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
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Adaptive Cyber Cycle Sign(",DoubleToString(Alpha,4),", ",Shift,")");
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
int OnCalculate(const int rates_total,    // Количество истории в барах на текущем тике
                const int prev_calculated,// Количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // Ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // Ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(CP_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int MaxBar,limit,bar;
   int bar0,bar1,bar2,bar3;
   double K0,K1,K2,K3,period[1],ATR[1],alpha1,Cycle0,Trigger0;
   static double Cycle2,Cycle1,Trigger1;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-2; // стартовый номер для расчета всех баров
      Cycle2=0;
      Cycle1=0;
      Trigger1=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---
   MaxBar=rates_total-min_rates_total-3;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar0=Count[0];
      bar1=Count[1];
      bar2=Count[2];
      bar3=Count[3];
      //---
      Price[bar0]=(high[bar]+low[bar])/2.0;
      Smooth[bar0]=(Price[bar0]+2.0*Price[bar1]+2.0*Price[bar2]+Price[bar3])/6.0;
      //---
      if(bar<=MaxBar)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(CP_Handle,0,bar,1,period)<=0) return(RESET);
         //--- инициализация переменных
         alpha1=2.0/(period[0]+1.0);
         K0=MathPow((1.0 - 0.5*alpha1),2);
         K1=2.0;
         K2=K1 *(1.0 - alpha1);
         K3=MathPow((1.0 - alpha1),2);
         //---
         Cycle0=K0*(Smooth[bar0]-K1*Smooth[bar1]+Smooth[bar2])+K2*Cycle1-K3*Cycle2;
        }
      else Cycle0=(Price[bar0]-2.0*Price[bar1]+Price[bar2])/4.0;
      //---
      Trigger0=Cycle1;
      //--- 
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(Cycle1<Trigger1 && Cycle0>Trigger0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(Cycle1>Trigger1 && Cycle0<Trigger0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar>0)
        {
         Cycle2=Cycle1;
         Cycle1=Cycle0;
         Trigger1=Trigger0;
         Recount_ArrayZeroPos(Count);
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+