//+------------------------------------------------------------------+ 
//|                                          OzFX_D1_IndAES_v1.0.mq5 | 
//|                                            Copyright © 2008, DGC |
//|                                          http://www.ozfx.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC"
#property link      "http://www.ozfx.com.au/" 
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 5
#property indicator_buffers 5 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде трёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трёхцветной гистограммы использованы
#property indicator_color1 clrMagenta,clrGray,clrTeal
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "OzFX Signals"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде трёхцветной гистограммы
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трёхцветной гистограммы использованы
#property indicator_color2 clrRed,clrGray,clrBlue
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки индикатора
#property indicator_label2 "AES Signals"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован Gold
#property indicator_color3 clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "SMA Filter"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint SMA_Filter_Period=200;
//+-----------------------------------+
//---- индикаторные буферы
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double ColorIndBuffer1[];
double ColorIndBuffer2[];
double ColorIndBuffer3[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,KPer,DPer,Slow,ACLim;
//---- Объявление целых переменных для хендлов индикаторов
int MA_Handle,AC_Handle,STO_Handle;
//+------------------------------------------------------------------+    
//| OzFX indicator initialization function                           | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   KPer=5;
   DPer=3;
   Slow=3;
   ACLim=37;
   min_rates_total=int(MathMax(MathMax(ACLim,KPer+DPer+Slow),SMA_Filter_Period));

//---- Получение хендлов индикаторов  
   STO_Handle=iStochastic(NULL,0,KPer,DPer,Slow,MODE_SMA,STO_LOWHIGH);
   if(STO_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,SMA_Filter_Period,0,MODE_SMA,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора  Accelerator Oscillator 
   AC_Handle=iAC(NULL,0);
   if(AC_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора  Accelerator Oscillator");
      return(INIT_FAILED);
     }

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer1,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer1,true);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer2,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer2,true);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(4,IndBuffer3,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer3,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"OzFX_D1_IndAES_v1.0");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| OzFX iteration function                                          | 
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
   if(BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(AC_Handle)<rates_total
      || BarsCalculated(MA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int limit,bar,to_copy;
//---- Объявление переменных с плавающей точкой  
   double Stoc[],Main[],AC[],MA[];

   static int trend1,trend2;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      trend1=0;
      trend2=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Stoc,true);
   ArraySetAsSeries(Main,true);
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(close,true);

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,Stoc)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,SIGNAL_LINE,0,to_copy,Main)<=0) return(RESET);
   if(CopyBuffer(AC_Handle,0,0,to_copy+1,AC)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      IndBuffer1[bar]=0;
      ColorIndBuffer1[bar]=1;

      if(AC[bar]>0 && AC[bar]>AC[bar+1] && Stoc[bar]>50)
        {
         if(trend1!=+1)
           {
            IndBuffer1[bar]=+2;
            ColorIndBuffer1[bar]=2;
           }

         if(bar) trend1=+1;
        }

      if(AC[bar]<0 && AC[bar]<AC[bar+1] && Stoc[bar]<50)
        {
         if(trend1!=-1)
           {
            IndBuffer1[bar]=-2;
            ColorIndBuffer1[bar]=0;
           }

         if(bar) trend1=-1;
        }

      IndBuffer2[bar]=0;
      ColorIndBuffer2[bar]=1;

      if(AC[bar]>AC[bar+1] && Stoc[bar]>Main[bar])
        {
         if(trend2!=+1)
           {
            IndBuffer2[bar]=+1;
            ColorIndBuffer2[bar]=2;
           }

         if(bar) trend2=+1;
        }

      if(AC[bar]<AC[bar+1] && Stoc[bar]<Main[bar])
        {
         if(trend2!=-1)
           {
            IndBuffer2[bar]=-1;
            ColorIndBuffer2[bar]=0;
           }

         if(bar) trend2=-1;
        }

      IndBuffer3[bar]=0;
      if(close[bar]>MA[bar]) IndBuffer3[bar]=+2;
      if(close[bar]<=MA[bar]) IndBuffer3[bar]=-2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
