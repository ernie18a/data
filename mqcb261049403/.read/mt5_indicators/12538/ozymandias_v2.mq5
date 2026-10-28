//+------------------------------------------------------------------+
//|                                                Ozymandias_v2.mq4 |
//|                                     Copyright © 2014, GoldnMoney |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, GoldnMoney"
#property link "https://forge.mql5.io"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- количество индикаторных буферов 4
#property indicator_buffers 4 
//--- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цветов двухцветной линии использованы
#property indicator_color1  clrOrange,clrChartreuse
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width1  3
//--- отображение метки индикатора
#property indicator_label1  "Line"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//--- в качестве цветов двухцветной линии использованы
#property indicator_color2  clrOrange,clrLimeGreen
//--- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_DASHDOT
//--- толщина линии индикатора равна 1
#property indicator_width2  1
//--- отображение метки индикатора
#property indicator_label2  "Signal"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Length=2;
input  ENUM_MA_METHOD MAType=MODE_SMA;
input int Shift=0;   // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double SigBuffer[],ColorSigBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
int ATR_Handle,HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(Length);
//--- инициализация глобальных переменных 
   int ATR_Period=100;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA
   HMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA
   LMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SigBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SigBuffer,true);
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(3,ColorSigBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorSigBuffer,true);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname="Ozymandias_v2";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- объявление переменных
   int to_copy,limit;
   double highprice,lowprice,maxlo,zone,minhi,map0,lowma,highma,ATR[],HMA[],LMA[];
   static double map1,maxlo1,minhi1;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      map1=0;
      minhi1=99999999;
      maxlo1=1;
     }
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);
//---
   maxlo=maxlo1;
   minhi=minhi1;
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      highprice=high[ArrayMaximum(high,bar,Length)];
      lowprice=low[ArrayMinimum(low,bar,Length)];
      lowma=LMA[bar];
      highma=HMA[bar];
      zone=ATR[bar]/2;
      maxlo=MathMax(lowprice,maxlo);
      minhi=MathMin(highprice,minhi);
      map0=map1;
      //---
      if(highma<maxlo && close[bar]<low[bar+1])
        {
         map0=-1;
         maxlo=lowprice;
        }
      //---
      if(lowma>minhi && close[bar]>high[bar+1])
        {
         map0=1;
         minhi=highprice;
        }
      //---
      if(map0>0 && map1<0)
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=1;
         SigBuffer[bar]=SigBuffer[bar+1];
         ColorSigBuffer[bar]=1;
        }
      //---
      if(map0>0 && map1>0)
        {
         IndBuffer[bar]=MathMax(maxlo,IndBuffer[bar+1]);
         ColorIndBuffer[bar]=1;
         SigBuffer[bar]=IndBuffer[bar]-zone;
         ColorSigBuffer[bar]=1;
        }
      //---
      if(map0<0 && map1>0)
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=0;
         SigBuffer[bar]=SigBuffer[bar+1];
         ColorSigBuffer[bar]=0;
        }
      //---
      if(map0<0 && map1<0)
        {
         IndBuffer[bar]=MathMin(minhi,IndBuffer[bar+1]);
         ColorIndBuffer[bar]=0;
         SigBuffer[bar]=IndBuffer[bar]+zone;
         ColorSigBuffer[bar]=0;
        }
      //---
      if(bar)
        {
         map1=map0;
         maxlo1=maxlo;
         minhi1=minhi;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
