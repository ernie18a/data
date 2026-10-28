//+---------------------------------------------------------------------+
//|                                                        ICHI_OSC.mq5 | 
//|                                            Copyright © 2010, МИХАИЛ | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, МИХАИЛ"
#property link ""
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrDodgerBlue,clrSlateBlue,clrGray,clrPurple,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "ColorXWPR_Histogram"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint a_ichi=22;                     //период Ишимоку                 
input Smooth_Method XMA_Method=MODE_JJMA; //метод сглаживания
input uint XLength=5;                     //глубина сглаживания                    
input int XPhase=15;                      //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtIndBuffer[],ColorExtIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total,ks;
int Ichi_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//----
   int ts=int(a_ichi*0.5);
   ks=int(a_ichi*1.5);
   int sb=int(a_ichi*3.0);

//---- Инициализация переменных начала отсчёта данных
   min_rates_1=ks+sb+1;
   min_rates_total=min_rates_1+GetStartBars(XMA_Method,XLength,XPhase);

//--- получение хендла индикатора iIchimoku
   Ichi_Handle=iIchimoku(NULL,0,ts,ks,sb);
   if(Ichi_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iIchimoku");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtIndBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtIndBuffer,true);
   ArraySetAsSeries(ColorExtIndBuffer,true);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname="ICHI_OSC("+string(sb)+")";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
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
   if(BarsCalculated(Ichi_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double ICHI_OSC,ICHI_OSC_prev;
   double TS[],KS[],SA[],CS[];
//---- Объявление целых переменных
   int to_copy,limit,bar;
   int MaxBar=rates_total-min_rates_1-1;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=MaxBar; // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ichi_Handle,TENKANSEN_LINE,0,to_copy,TS)<=0) return(RESET);
   if(CopyBuffer(Ichi_Handle,KIJUNSEN_LINE,0,to_copy,KS)<=0) return(RESET);
   if(CopyBuffer(Ichi_Handle,SENKOUSPANA_LINE,ks,to_copy,SA)<=0) return(RESET);
   if(CopyBuffer(Ichi_Handle,CHIKOUSPAN_LINE,ks,to_copy,CS)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(TS,true);
   ArraySetAsSeries(KS,true);
   ArraySetAsSeries(SA,true);
   ArraySetAsSeries(CS,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double markt=CS[bar]-SA[bar];
      double trend=TS[bar]-KS[bar];
      ICHI_OSC=-(trend-markt)/_Point;
      ExtIndBuffer[bar]=XMA1.XMASeries(MaxBar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,ICHI_OSC,bar,true);
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit=rates_total-min_rates_total;
//---- Основной цикл раскраски гистограммы
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      ICHI_OSC=ExtIndBuffer[bar];
      ICHI_OSC_prev=ExtIndBuffer[bar+1];
      if(ICHI_OSC>0)
        {
         if(ICHI_OSC_prev<ICHI_OSC) clr=0;
         if(ICHI_OSC_prev>ICHI_OSC) clr=1;
        }
      else if(ICHI_OSC<0)
        {
         if(ICHI_OSC_prev<ICHI_OSC) clr=4;
         if(ICHI_OSC_prev>ICHI_OSC) clr=3;
        }
      ColorExtIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
