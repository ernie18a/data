//+---------------------------------------------------------------------+
//|                                                         QQESign.mq5 |
//|                                         Copyright © 2010, EarnForex |
//|                                            http://www.earnforex.com |
//|                                Based on version by Tim Hyder (2008) |
//|                            Based on version by Roman Ignatov (2006) |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "www.EarnForex.com, 2010"
#property link      "http://www.earnforex.com"
#property version   "1.20"
#property description "QQE - Qualitative Quantitative Estimation."
#property description "Calculated as two indicators:"
#property description "1) MA on RSI"
#property description "2) Difference of MA on RSI and MA of MA of ATR of MA of RSI"
#property description "The signal for buy is when blue line crosses level 50 from below"
#property description "after crossing the yellow line from below."
#property description "The signal for sell is when blue line crosses level 50 from above"
#property description "after crossing the yellow line from above." 
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в основном окне
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
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "QQESign Sell"
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
#property indicator_label2 "QQESign Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+----------------------------------------------+
//| объявление перечислений                      |
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
input uint RSI_Period=123;
input uint SF=41;
input double DARFACTOR=4.236;
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения        
input int XPhase=15;                     // Параметр сглаживания
//--- XPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
input int Shift=0;                       // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//--- лбъявление целочисленных переменных для хендлов индикаторов
int RSI_Handle,ATR_Handle;
//--- лбъявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1,min_rates_2,min_rates_3,Wilders_Period;
//+------------------------------------------------------------------+   
//| QQEA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   Wilders_Period=int(RSI_Period*2-1);
   min_rates_1=int(RSI_Period+1);
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,SF,XPhase)+1;
   min_rates_3=min_rates_2+XMA1.GetStartBars(XMA_Method,Wilders_Period,XPhase);
   min_rates_total=min_rates_3+XMA1.GetStartBars(XMA_Method,Wilders_Period,XPhase);
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total))+1;
//--- получение хендла индикатора RSI
   RSI_Handle=iRSI(NULL,0,RSI_Period,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора RSI");
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
   PlotIndexSetInteger(0,PLOT_ARROW,93);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,93);
//--- инициализации переменной для короткого имени индикатора
   string shortname="Qualitative Quantitative Estimation Signal";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| QQESign iteration function                                       |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- объявление переменных с плавающей точкой  
   double RSI[1],ATR[1],xrsi,momxrsi,xmomxrsi,xxmomxrsi,dar,tr,dv;
//--- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
   static double prev_xrsi,prev_tr;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_1; // стартовый номер для расчета всех баров
      prev_xrsi=50;
      prev_tr=50;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(CopyBuffer(RSI_Handle,0,rates_total-1-bar,1,RSI)<=0) return(RESET);
      xrsi=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,SF,RSI[0],bar,false);
      momxrsi=MathAbs(prev_xrsi-xrsi);
      xmomxrsi=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method,XPhase,Wilders_Period,momxrsi,bar,false);
      xxmomxrsi=XMA3.XMASeries(min_rates_3,prev_calculated,rates_total,XMA_Method,XPhase,Wilders_Period,xmomxrsi,bar,false);
      dar=xxmomxrsi*DARFACTOR;
      //---       
      tr=prev_tr;
      dv=tr;
      //---
      if(xrsi<tr)
        {
         tr=xrsi+dar;
         if(prev_xrsi<dv && tr>dv) tr=dv;
        }
      else if(xrsi>tr)
        {
         tr=xrsi-dar;
         if(prev_xrsi>dv && tr<dv) tr=dv;
        }
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //--- 
      if(prev_xrsi<=prev_tr && xrsi>tr)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---        
      if(prev_xrsi>=prev_tr && xrsi<tr)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar<rates_total-1)
        {
         prev_xrsi=xrsi;
         prev_tr=tr;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
