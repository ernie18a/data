//+------------------------------------------------------------------+ 
//|                                         i-SpectrAnalysis_ADX.mq5 | 
//|                                           Copyright © 2006, klot | 
//|                                                     klot@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, klot" 
#property link      "klot@mail.ru" 
//--- номер версии индикатора 
#property version   "1.00" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки индикатора Di           |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrAqua,clrDeepPink
//---- отображение бычей метки индикатора
#property indicator_label1  "i-SpectrAnalysis_Di"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора ADX Line     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета  линии индикатора использован серый цвет
#property indicator_color2  clrGray
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2  "i-SpectrAnalysis_ADX Line"
//+----------------------------------------------+
//|  Параметры отрисовки ADX индикатора          |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_COLOR_ARROW
//---- в качестве цветов ADX линии индикатора использованы
#property indicator_color3  clrGray,clrBlue,clrMagenta,clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение медвежьей метки индикатора
#property indicator_label3  "i-SpectrAnalysis_ADX"
//+----------------------------------------------+ 
//| Параметры отображения горизонтальных уровней | 
//+----------------------------------------------+ 
#property indicator_level1 70.0 
#property indicator_level2 50.0 
#property indicator_level3 30.0 
#property indicator_levelcolor clrGray 
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_WIDTH //Тип константы
  {
   w_1=0,  //1
   w_2,    //2
   w_3,    //3
   w_4,    //4
   w_5     //5
  };
//+----------------------------------------------+ 
//| Объявление констант                          | 
//+----------------------------------------------+ 
#define RESET 0     // константа для возврата терминалу команды на пересчет индикатора 
//+----------------------------------------------+ 
//| Описание библиотеки dt_FFT.mqh               | 
//+----------------------------------------------+ 
#include <dt_FFT.mqh> 
//+----------------------------------------------+ 
//| Входные параметры индикатора                 | 
//+----------------------------------------------+ 
input uint ADXPeriod=14;                          // averaging period 
input uint N = 7;                                 // number Length 
input uint SS = 20;                               // smoothing factor 
input int Shift=0;                                // The shift indicator in the horizontal bars
input uint ExtraHighLevel=60;                     // уровень максимального тренда
input uint HighLevel=40;                          // уровень сильного тренда
input uint LowLevel=20;                           // уровень слабого тренда
input ENUM_LINE_STYLE LevelStyle=STYLE_DASHDOTDOT;// стиль линий уровней
input color LevelColor=clrBlue;                   // цвет уровней
input ENUM_WIDTH LevelWidth=w_1;                  // толщина уровней
//+----------------------------------------------+ 
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double DiPlusBuffer[];
double DiMinusBuffer[];
double ADXBuffer[];
double ADXLineBuffer[];
double ColorADXBuffer[];
//--- 
int M,tnn1,ss;
//--- 
double aa[];
//--- объявление целочисленных переменных начала отсчета данных 
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов 
int Ind_Handle;
//+------------------------------------------------------------------+   
//| i-SpectrAnalysis_ADX indicator initialization function           | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных 
   tnn1=int(MathPow(2,N));
   M=ArrayResize(aa,tnn1+1);
   ArraySetAsSeries(aa,true);
   ss=int(MathMin(SS,M));
   min_rates_total=int(M);
//--- получение хендла индикатора iADX 
   Ind_Handle=iADX(Symbol(),PERIOD_CURRENT,ADXPeriod);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX");
      return(INIT_FAILED);
     }
//---- превращение динамического массива DiPlusBuffer в индикаторный буфер
   SetIndexBuffer(0,DiPlusBuffer,INDICATOR_DATA);
//---- превращение динамического массива DiMinusBuffer в индикаторный буфер
   SetIndexBuffer(1,DiMinusBuffer,INDICATOR_DATA);
//---- превращение динамического массива ADXLineBuffer в индикаторный буфер
   SetIndexBuffer(2,ADXLineBuffer,INDICATOR_DATA);
//---- превращение динамического массива ADXBuffer в индикаторный буфер
   SetIndexBuffer(3,ADXBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ColorADXBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии 
   ArraySetAsSeries(DiPlusBuffer,true);
   ArraySetAsSeries(DiMinusBuffer,true);
   ArraySetAsSeries(ADXLineBuffer,true);
   ArraySetAsSeries(ADXBuffer,true);
   ArraySetAsSeries(ColorADXBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке 
   IndicatorSetString(INDICATOR_SHORTNAME,"i-SpectrAnalysis_ADX");
//--- определение точности отображения значений индикатора 
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- параметры отрисовки уровней индикатора
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtraHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,LevelWidth);
//--- завершение инициализации 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| i-SpectrAnalysis_ADX iteration function                          | 
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
   if(rates_total<min_rates_total || BarsCalculated(Ind_Handle)<rates_total) return(RESET);
   int end=M-1;
//---- осуществление сдвига начала отсчёта отрисовки индикаторов
   int drawbegin=rates_total-end;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,drawbegin);

//--- Делаем расчёт ADX
   if(CopyBuffer(Ind_Handle,0,0,M,aa)<=0) return(RESET);  
   fastcosinetransform(aa,tnn1,false);
   for(int kkk=0; kkk<=end && !IsStopped(); kkk++) if(kkk>=ss) aa[kkk]=0.0;
   fastcosinetransform(aa,tnn1,true);
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++) ADXLineBuffer[rrr]=ADXBuffer[rrr]=aa[rrr];
//---   

//--- Делаем расчёт DX+
   if(CopyBuffer(Ind_Handle,1,0,M,aa)<=0) return(RESET);
   fastcosinetransform(aa,tnn1,false);
   for(int kkk=0; kkk<=end && !IsStopped(); kkk++) if(kkk>=ss) aa[kkk]=0.0;
   fastcosinetransform(aa,tnn1,true);
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++) DiPlusBuffer[rrr]=aa[rrr];
   
//--- Делаем расчёт DX-
   if(CopyBuffer(Ind_Handle,2,0,M,aa)<=0) return(RESET);
   fastcosinetransform(aa,tnn1,false);
   for(int kkk=0; kkk<=end && !IsStopped(); kkk++) if(kkk>=ss) aa[kkk]=0.0;
   fastcosinetransform(aa,tnn1,true);
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++) DiMinusBuffer[rrr]=aa[rrr];
     
//---- Основной цикл раскраски сигнальной линии
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++)
     {
      int clr=1;
      if(ADXBuffer[rrr]>ExtraHighLevel) clr=3;
      else if(ADXBuffer[rrr]>HighLevel) clr=2;
      else if(ADXBuffer[rrr]<LowLevel)  clr=0;
      ColorADXBuffer[rrr]=clr;
     }
//---   


  
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
