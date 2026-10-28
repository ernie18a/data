//+------------------------------------------------------------------+ 
//|                                                     MACD^MFI.mq5 | 
//|                     Copyright © 2018, Лукашук Виктор Геннадьевич | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Лукашук Виктор Геннадьевич"
#property link "" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего три графических построения
#property indicator_plots   3
//+--------------------------------------------+
//|  Параметры отрисовки MACD                  |
//+--------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1 DRAW_HISTOGRAM
//---- в качестве цвета диаграммы MACD индикатора использован серый цвет
#property indicator_color1 clrGray
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "MACD"
//+--------------------------------------------+
//|  Параметры отрисовки сигнальной линии MACD |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве цвета сигнальной линии использован красный цвет
#property indicator_color2 clrRed
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2 1
//---- отображение метки сигнальной линии
#property indicator_label2  "Signal Line"
//+--------------------------------------------+
//|  Параметры отрисовки MFI                   |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цвета линии MFI использованы
#property indicator_color3 clrGray,clrDodgerBlue,clrMagenta
//---- линия индикатора - сплошная кривая
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3 3
//---- отображение метки сигнальной линии
#property indicator_label3  "MFI"
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int Fast_MA = 12; //период быстрого мувинга MACD
input int Slow_MA = 26; //глубина  медленного мувинга MACD
input ENUM_MA_METHOD MA_Method_=MODE_EMA; //метод усреднения индикатора
input int Signal_SMA=9; //период сигнальной линии 
input ENUM_APPLIED_PRICE_ AppliedPrice_=PRICE_CLOSE_;//ценовая константа
input uint MFIPeriod=12;  // период MFI
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;  // объём MFI  
input double caliber=4.0; //масштабирование
//+-----------------------------------+
//---- индикаторныe буферы
double MACDBuffer[],SignBuffer[],MFIBuffer[],ColorMFIBuffer[];
double positive_,negative_;
int macd_start,sig_start,mfi_start;
//+------------------------------------------------------------------+
// Описание функции iPriceSeries                                     |
// Описание класса Moving_Average                                    | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных  
   if(MA_Method_!=MODE_EMA)
      macd_start=MathMax(Fast_MA,Slow_MA);
   else macd_start=0;
   sig_start=macd_start+Signal_SMA;
   mfi_start=sig_start+int(MFIPeriod)+2;
//---- превращение динамического массива MACDBuffer в индикаторный буфер
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,macd_start);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,sig_start);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- превращение динамического массива MFIBuffer в индикаторный буфер
   SetIndexBuffer(2,MFIBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,mfi_start+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorMFIBuffer,INDICATOR_COLOR_INDEX);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"MACD_MFI(",Fast_MA,",",Slow_MA,",",Signal_SMA,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
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
//---- Проверка количества баров на достаточность для расчёта
   if(rates_total<mfi_start) return(0);

//---- Объявление целых переменных
   int first,bar;
//---- Объявление переменных с плавающей точкой  
   double price_,fast_ma,slow_ma;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      positive_=negative_=NULL;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- объявление переменных класса CMoving_Average из файла MASeries_Cls.mqh
   static CMoving_Average MA1,MA2,MA3;

//---- Основной цикл расчёта индикатора MACD
   for(bar=first; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice_,bar,open,low,high,close);
      fast_ma = MA1.MASeries(0, prev_calculated, rates_total, Fast_MA, MA_Method_, price_, bar, false);
      slow_ma = MA2.MASeries(0, prev_calculated, rates_total, Slow_MA, MA_Method_, price_, bar, false);
      MACDBuffer[bar] = fast_ma - slow_ma;
      SignBuffer[bar] = MA3.SMASeries(macd_start, prev_calculated, rates_total, Signal_SMA, MACDBuffer[bar], bar, false);
     }

//---- расчёт стартового номера first для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0) first=mfi_start+1;
//---- Основной цикл расчёта индикатора MFI
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(MFIVolumeType==VOLUME_TICK) CalculateMFI(bar,MACDBuffer,tick_volume,MFIBuffer);
      else CalculateMFI(bar,MACDBuffer,volume,MFIBuffer);
      ColorMFIBuffer[bar]=0;
      if(MFIBuffer[bar]>SignBuffer[bar]) ColorMFIBuffer[bar]=1;
      if(MFIBuffer[bar]<SignBuffer[bar]) ColorMFIBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate MFI by volume from argument                            |
//+------------------------------------------------------------------+
void CalculateMFI(const int index,
                  const double &InBuffer[],
                  const long &VolBuffer[],
                  double &OutBuffer[])
  {
//----
   double dPositiveMF=0.0;
   double dNegativeMF=0.0;
   double dCurrentTP=double(VolBuffer[index]);
   for(int kkk=1; kkk<=int(MFIPeriod); kkk++)
     {
      int iii=index-kkk;
      double dPreviousTP=double(VolBuffer[iii]);
      if(dCurrentTP>dPreviousTP) dPositiveMF+=VolBuffer[iii-1]*dCurrentTP;
      if(dCurrentTP<dPreviousTP) dNegativeMF+=VolBuffer[iii-1]*dCurrentTP;
      dCurrentTP=dPreviousTP;
     }
   if(dNegativeMF) OutBuffer[index]=caliber*_Point*(50.0-100.0/(1+dPositiveMF/dNegativeMF));
   else OutBuffer[index]=caliber*_Point*100.0;
//----
  }
//+------------------------------------------------------------------+ 
