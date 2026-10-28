//+------------------------------------------------------------------+ 
//|                                                         QEMA.mq5 | 
//|                                      Copyright © 2010, Bruno Pio |
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Bruno Pio"
#property link "" 
#property description "Pentuple Exponential Moving Average"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1 clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "QEMA"
//+-----------------------------------+
//|  Описание класса CMoving_Average  |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh
CMoving_Average EMA[5];
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double EmaLength=50.01;             // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;    // ценовая константа
input int Shift=0;                        // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // cдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//---- индикаторный буфер
double QEMABuffer[];
double dPriceShift;
//---- Объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| QEMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=6;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,QEMABuffer,INDICATOR_DATA);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(QEMABuffer,false);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"QEMA");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"QEMA( Length = ",EmaLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| QEMA iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление локальных переменных
   int first,bar;
   double res[6];

   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- индексация элементов в массивах не как в таймсериях  
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      res[0]=PriceSeries(IPC,bar,open,low,high,close);
      res[1]=EMA[0].EMASeries(0,prev_calculated,rates_total,EmaLength,res[0],bar,false); 
      res[2]=EMA[1].EMASeries(1,prev_calculated,rates_total,EmaLength,res[1],bar,false); 
      res[3]=EMA[2].EMASeries(2,prev_calculated,rates_total,EmaLength,res[2],bar,false); 
      res[4]=EMA[3].EMASeries(3,prev_calculated,rates_total,EmaLength,res[3],bar,false); 
      res[5]=EMA[4].EMASeries(4,prev_calculated,rates_total,EmaLength,res[4],bar,false); 
      QEMABuffer[bar]=5*res[1]-10*res[2]+10*res[3]-5*res[4]+res[5];
      QEMABuffer[bar]+=dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
