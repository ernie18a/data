//+---------------------------------------------------------------------+ 
//|                                               ColorPEMA_Digit_r.mq5 | 
//|                                         Copyright © 2010, Bruno Pio |
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Bruno Pio"
#property link "" 
#property description "Pentuple Exponential Moving Average"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использован один буфер
#property indicator_buffers 2
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "PEMA"
//+-----------------------------------+
//|  Описание класса CMoving_Average  |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh
CMoving_Average EMA[8];
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
//|  объявление перечислений          |
//+-----------------------------------+
enum ENUM_RECOUNT_MODE      // Тип константы
  {
   ONLY_BARS_RECOUNT = 1,     // Обрезаем только пересчёт баров
   ONLY_TIME_RECOUNT,         // Обрезаем только пересчёт во времени
   FULL_RECOUNT               // Полная оптимизация пересчётов
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double EmaLength=50.01;                  // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;         // ценовая константа
input int Shift=0;                             // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                        // cдвиг индикатора по вертикали в пунктах
input uint Digit=2;                            // количество разрядов округления
input string  SirName="ColorPEMA_Digit";       // Первая часть имени графических объектов
input bool ShowPrice=true;                     // показывать ценовую метку
input ENUM_RECOUNT_MODE RecountMode=FULL_RECOUNT;    // Способ ограничения расчётов индикатора
input uint CountBars=500;                            // количество баров для расчёта индикатора
input uint ReCountTime=60;                           // время в секундах между расчётами индикатора
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ColorExtLineBuffer[];
//---- Объявление глобальных переменных
double dPriceShift,PointPow10;
int min_rates_total,count_bars;
//---- Объявление стрингов для текстовых меток
string Price_name;
//---- цвета ценовых меток
color  UpPrice_color;      // цвет ценовой метки для роста
color  DnPrice_color;      // цвет ценовой метки для падения
//+------------------------------------------------------------------+    
//| PEMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=9+1;
   count_bars=int(MathMax(CountBars,min_rates_total));
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(ExtLineBuffer,false);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(ColorExtLineBuffer,false);   
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorPEMA_Digit_r(",EmaLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- Инициализация округления
   PointPow10=_Point*MathPow(10,Digit);
//---- Инициализация стрингов
   Price_name=SirName+"Price";
   DnPrice_color=color(PlotIndexGetInteger(0,PLOT_LINE_COLOR,0));
   UpPrice_color=color(PlotIndexGetInteger(0,PLOT_LINE_COLOR,2));
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,Price_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| PEMA iteration function                                          | 
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
//---
   static datetime recount_time;
   if(prev_calculated>rates_total || prev_calculated<=0 || prev_calculated!=rates_total) recount_time=NULL;
//--- 
   switch(RecountMode)
     {
      case ONLY_BARS_RECOUNT: break;
      default:
         if(TimeCurrent()-recount_time<int(ReCountTime)) return(rates_total);
         else recount_time=TimeCurrent();
     }
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление локальных переменных
   int first,bar;
   double res[9],pema;

   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых 
//--- 
   switch(RecountMode)
     {
      case ONLY_TIME_RECOUNT: break;
      default:
        {
         int barx=rates_total-1-count_bars;
         first=int(MathMax(first,barx));
         //--- осуществление сдвига начала отсчета отрисовки индикатора
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,barx+7);
         break;
        }
     }
   
//---- индексация элементов в массивах не как в таймсериях  
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      res[0]=PriceSeries(IPC,bar,open,low,high,close);
      int start=rates_total-1-count_bars;
      
      res[1]=EMA[0].EMASeries(MathMax(start+0,0),prev_calculated,rates_total,EmaLength,res[0],bar,false); 
      res[2]=EMA[1].EMASeries(MathMax(start+1,1),prev_calculated,rates_total,EmaLength,res[1],bar,false); 
      res[3]=EMA[2].EMASeries(MathMax(start+2,2),prev_calculated,rates_total,EmaLength,res[2],bar,false); 
      res[4]=EMA[3].EMASeries(MathMax(start+3,3),prev_calculated,rates_total,EmaLength,res[3],bar,false); 
      res[5]=EMA[4].EMASeries(MathMax(start+4,4),prev_calculated,rates_total,EmaLength,res[4],bar,false); 
      res[6]=EMA[5].EMASeries(MathMax(start+5,5),prev_calculated,rates_total,EmaLength,res[5],bar,false); 
      res[7]=EMA[6].EMASeries(MathMax(start+6,6),prev_calculated,rates_total,EmaLength,res[6],bar,false); 
      res[8]=EMA[7].EMASeries(MathMax(start+7,7),prev_calculated,rates_total,EmaLength,res[7],bar,false);    
      pema=8*res[1]-28*res[2]+56*res[3]-70*res[4]+56*res[5]-28*res[6]+8*res[7]-res[8];  
      pema+=dPriceShift;
      ExtLineBuffer[bar]=PointPow10*MathRound(pema/PointPow10);
     }
     
//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first++; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=1;
      double trend=ExtLineBuffer[bar]-ExtLineBuffer[bar-1];
      if(!trend) clr=int(ColorExtLineBuffer[bar-1]);
      else
        {
         if(trend>0) clr=2;
         if(trend<0) clr=0;
        }
      ColorExtLineBuffer[bar]=clr;
     }
//---- отображение ценовой метки
   if(ShowPrice)
     {
      color clr=DnPrice_color;
      int bar0=rates_total-1;
      if(ColorExtLineBuffer[bar0]!=0) clr=UpPrice_color;
      datetime time0=time[bar0]+1*PeriodSeconds();
      SetRightPrice(0,Price_name,0,time0,ExtLineBuffer[bar0],clr);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
