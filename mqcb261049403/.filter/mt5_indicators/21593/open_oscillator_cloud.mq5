//+------------------------------------------------------------------+
//|                                        Open_Oscillator_Cloud.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.10"
#property description "Open oscillator"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Параметры отрисовки индикатора уровней      |
//+----------------------------------------------+
//---- отрисовка канала в виде облака
#property indicator_type1   DRAW_FILLING
//---- выбор цвета облака
#property indicator_color1  clrTurquoise,clrGold
//---- отображение метки индикатора
#property indicator_label1  "Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора FAMA         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Signal High"
//+----------------------------------------------+
//|  Параметры отрисовки  индикатора             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color3  clrMagenta
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Signal Low"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint     InpPeriod=20;                      // Period
input Smooth_Method XMethod=MODE_SMA_;            // метод усреднения сглаживания 
input uint XLength=10;                            // глубина сглаживания                    
input int XPhase=15;                              // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                                // сдвиг канала по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[],UpClIndBuffer[],DnClIndBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_1,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_1=int(InpPeriod);
   min_rates_total=min_rates_1+GetStartBars(XMethod,XLength,XPhase);     
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpClIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnClIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DnIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(UpClIndBuffer,true);
   ArraySetAsSeries(DnClIndBuffer,true);
   ArraySetAsSeries(UpIndBuffer,true);
   ArraySetAsSeries(DnIndBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- запрет на отображения значения индикатора в левом углу
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- запрет на отображения значения индикатора в левом углу
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- запрет на отображения значения индикатора в левом углу
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//---- имя для окон данных и метка для подокон 
   string short_name="Open_Oscillator_Cloud";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int limit,bar,maxbar=rates_total-min_rates_1;

//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int bh=ArrayMaximum(high,bar,InpPeriod);
      int bl=ArrayMinimum(low,bar,InpPeriod);     
      //---- Два вызова функции XMASeries. 
      UpIndBuffer[bar]=UpClIndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMethod,XPhase,XLength,open[bar]-open[bh],bar,true);
      DnIndBuffer[bar]=DnClIndBuffer[bar]=XMA2.XMASeries(maxbar,prev_calculated,rates_total,XMethod,XPhase,XLength,open[bl]-open[bar],bar,true);
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+