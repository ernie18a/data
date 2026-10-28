//+---------------------------------------------------------------------+ 
//|                                                   2pbIdealXOSMA.mq5 | 
//|                                  Copyright © 2012, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- номер версии индикатора
#property version   "1.02"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrGray,clrOliveDrab,clrDodgerBlue,clrDeepPink,clrMagenta
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1 2
//--- отображение метки индикатора
#property indicator_label1 "2pbIdealXOSMA"
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//| объявление перечислений           |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int Period1 = 10;                     // Грубое усреднение
input int Period2 = 10;                     // Уточняющее усреднение
input int PeriodX1 = 10;                    // Первое грубое усреднение
input int PeriodX2 = 10;                    // Первое уточняющее усреднение
input int PeriodY1 = 10;                    // Второе грубое усреднение
input int PeriodY2 = 10;                    // Второе уточняющее усреднение
input int PeriodZ1 = 10;                    // Третье грубое усреднение
input int PeriodZ2 = 10;                    // Третье уточняющее усреднение
input Smooth_Method SmoothMethod=MODE_JJMA; // Метод сглаживания
input int Smooth_XMA=9;                     // Период сглаживания
input int Smooth_Phase=100;                 // Параметр усреднения
//--- Smooth_Phase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Smooth_Phase: для VIDIA это период CMO, для AMA это период медленной скользящей
//+-----------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//--- объявления переменных для сглаживающих констант
double w1,w2,wX1,wX2,wY1,wY2,wZ1,wZ2;
//--- объявления переменных для хранения результатов усреднения
double Moving0_,Moving01_,Moving11_,Moving21_;
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание класса Moving_Average                                   |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------------------------+
//| Усреднение от Neutron                                            |
//+------------------------------------------------------------------+
double GetIdealMASmooth(double W1_,     //первая сглаживающая константа
                        double W2_,     //вторая сглаживающая константа
                        double Series1, //значение тамсерии с текущего бара 
                        double Series0, //значение тамсерии с предыдущего бара 
                        double Result1) //значение мувинга с предыдущего бара
  {
//---
   double Result0,dSeries,dSeries2;
   dSeries=Series0-Series1;
   dSeries2=dSeries*dSeries-1.0;
//---
   Result0=(W1_ *(Series0-Result1)+
            Result1+W2_*Result1*dSeries2)
   /(1.0+W2_*dSeries2);
//---
   return(Result0);
  }
//+------------------------------------------------------------------+    
//| 2pbIdealXOSMA indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=2+XMA1.GetStartBars(SmoothMethod,Smooth_XMA,Smooth_Phase);
//--- инициализации переменных
   w1=1.0/Period1;
   w2=1.0/Period2;
   wX1=1.0/PeriodX1;
   wX2=1.0/PeriodX2;
   wY1=1.0/PeriodY1;
   wY2=1.0/PeriodY2;
   wZ1=1.0/PeriodZ1;
   wZ2=1.0/PeriodZ2;
//--- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Ind");
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Smooth_XMA",Smooth_XMA);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Smooth_Phase",Smooth_Phase,SmoothMethod);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"2pbIdealXOSMA");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| 2pbIdealXOSMA iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,     // количество истории в барах на текущем тике
                const int prev_calculated, // количество истории в барах на предыдущем тике
                const int begin,           // номер начала достоверного отсчета баров
                const double &price[])     // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
///--- объявления локальных переменных 
   int first,bar;
   double Moving0,SlowMA,FastMA,macd;
   double Moving00,Moving10,Moving20;
   double Moving01,Moving11,Moving21;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1+begin;  // стартовый номер для расчета всех баров
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      //--- стартовая инициализация  
      Moving0_=price[begin];
      Moving01_=price[begin];
      Moving11_=price[begin];
      Moving21_=price[begin];
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- восстанавливаем значения переменных
   Moving0=Moving0_;
   Moving01=Moving01_;
   Moving11=Moving11_;
   Moving21=Moving21_;
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      Moving0=GetIdealMASmooth(w1,w2,price[bar-1],price[bar],Moving0);
      Moving00=GetIdealMASmooth(wX1,wX2,price[bar-1],price[bar],Moving01);
      Moving10=GetIdealMASmooth(wY1,wY2,Moving01,    Moving00,  Moving11);
      Moving20=GetIdealMASmooth(wZ1,wZ2,Moving11,    Moving10,  Moving21);
      //---
      Moving01 = Moving00;
      Moving11 = Moving10;
      Moving21 = Moving20;
      //---
      SlowMA=Moving20;
      FastMA=Moving0;
      macd=FastMA-SlowMA;
      IndBuffer[bar]=XMA1.XMASeries(1+begin,prev_calculated,rates_total,SmoothMethod,Smooth_Phase,Smooth_XMA,macd,bar,false);
      //---
      if(bar==rates_total-2)
        {
         Moving0_=Moving0;
         Moving01_=Moving01;
         Moving11_=Moving11;
         Moving21_=Moving21;
        }
     }

   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//--- основной цикл раскраски индикатора Ind
   for(bar=first; bar<rates_total; bar++)
     {
      ColorIndBuffer[bar]=0;
      //---
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) ColorIndBuffer[bar]=1;
         if(IndBuffer[bar]<IndBuffer[bar-1]) ColorIndBuffer[bar]=2;
        }
      //---
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) ColorIndBuffer[bar]=3;
         if(IndBuffer[bar]>IndBuffer[bar-1]) ColorIndBuffer[bar]=4;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
