//+------------------------------------------------------------------+
//|                                        RJTX_Matches_Smoothed.mq5 |
//|                            Copyright 2015, Rafael Jimenez Tocino |
//|               http://www.tradingrafa.com/indicadores/rjt_matches |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright 2015, Rafael Jimenez Tocino"
//--- ссылка на сайт автора
#property link      "http://www.tradingrafa.com/indicadores/rjt_matches"
#property description "We recommend adjust the body and head size of the matches for better visualization."
//--- номер версии индикатора
#property version   "4.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 5
//--- использовано всего два графических построения
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color1  clrDarkViolet
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "match 1"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color2  clrDarkViolet
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "match 2"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color3  clrDarkViolet
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "match 3"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color4  clrDeepPink
//--- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//--- отображение медвежьей метки индикатора
#property indicator_label4  "RJTX_Matches_Smoothed Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован голубой цвет
#property indicator_color5  clrDodgerBlue
//--- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//--- отображение бычьей метки индикатора
#property indicator_label5 "RJTX_Matches_Smoothed Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAC;
//+----------------------------------------------+
//| Объявление перечислений                      |
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
   MODE_AMA    //AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=10;  // Период индикатора свечек
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input uint XLength=12;                   // Глубина сглаживания
input int XPhase=15;                     // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double LineBuffer0[];
double LineBuffer1[];
double LineBuffer2[];
double SellBuffer[];
double BuyBuffer[];
//---
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double xOpen[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
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
//---- инициализация переменных начала отсчета данных
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total=int(MathMax(iPeriod,min_rates_total));
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,iPeriod+1);
   ArrayResize(xOpen,iPeriod+1);
//---- инициализация индикаторного буферов
   IndInit(0,LineBuffer0,0,min_rates_total,0);
   IndInit(1,LineBuffer1,0,min_rates_total,0);
   IndInit(2,LineBuffer2,0,min_rates_total,0);
   IndInit(3,SellBuffer,0,min_rates_total,0);
   IndInit(4,BuyBuffer,0,min_rates_total,0);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,174);
   PlotIndexSetInteger(4,PLOT_ARROW,174);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="RJTX_Matches_Smoothed";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//--- объявление локальных переменных 
   int first,bar;
   static uint p=0;
   double xclose;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(xOpen,open[first]);
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      xOpen[Count[0]]=XMAO.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,open[bar],bar,false);
      xclose=XMAC.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,close[bar],bar,false);
      //--- the color of matchstick heads
      if(xclose>xOpen[Count[iPeriod]])
        {
         SellBuffer[bar]=0.0;
         BuyBuffer[bar]=xclose;
        }
      else
        {
         SellBuffer[bar]=xclose;
         BuyBuffer[bar]=0.0;
        }
      //---
      switch(p)
        {
         case 0:
           {
            LineBuffer0[bar]=xOpen[Count[iPeriod-1]];
            LineBuffer1[bar]=0.0;
            LineBuffer2[bar]=xclose;
            break;
           }
         case 1:
           {
            LineBuffer0[bar]=xclose;
            LineBuffer1[bar]=xOpen[Count[iPeriod-1]];
            LineBuffer2[bar]=0.0;
            break;
           }
         case 2:
           {
            LineBuffer0[bar]=0.0;
            LineBuffer1[bar]=xclose;
            LineBuffer2[bar]=xOpen[Count[iPeriod-1]];
           }
        }
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos(Count,iPeriod+1);
         p++;
        }
      if(p>2) p=0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
