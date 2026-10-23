//+---------------------------------------------------------------------+
//|                                                          RSIOMA.mq5 | 
//|                                           Copyright © 2006, Kalenzo | 
//|                bartlomiej.gorski@gmail.com, http://www.fxservice.eu | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Kalenzo"
#property link "http://www.fxservice.eu"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов пятицветной гистограммы использованы
#property indicator_color1 clrDeepPink,clrPurple,clrGray,clrForestGreen,clrLawnGreen
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "RSIOMA"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  clrDarkViolet
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Trigger"

//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
//---- объявление переменных класса CMomentum из файла SmoothAlgorithms.mqh
CMomentum Mom;
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
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input Smooth_Method RSIOMA_Method=MODE_EMA_;  // Метод усреднения RSIOMA
input uint RSIOMA=14;                         // Глубина усреднения RSIOMA
input int RSIOMAPhase=15;                     // Параметр усреднения RSIOMA
input Smooth_Method MARSIOMA_Method=MODE_EMA_;// Метод усреднения MARSIOMA
input uint MARSIOMA=21;                       // Глубина усреднения RSIOMA
input int MARSIOMAPhase=15;                   // Параметр усреднения RSIOMA
input uint MomPeriod=1;                       // Период Моментума
input Applied_price_ IPC=PRICE_CLOSE_;        // Ценовая константа
input int HighLevel=+20;                      // Верхний уровень срабатывания
input int MiddleLevel=0;                      // Середина диапазона
input int LowLevel=-20;                       // Нижний уровень срабатывания
input int Shift=0;                            // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[],TriggerBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_2,min_rates_3;
//+------------------------------------------------------------------+   
//| RSIOMA indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=GetStartBars(RSIOMA_Method,RSIOMA,RSIOMAPhase);
   min_rates_2=int(min_rates_1+MomPeriod);
   min_rates_3=int(min_rates_2+RSIOMA+1);
   min_rates_total=min_rates_3+GetStartBars(MARSIOMA_Method,MARSIOMA,RSIOMAPhase);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("RSIOMA",RSIOMA);
   XMA1.XMAPhaseCheck("RSIOMAPhase",RSIOMAPhase,RSIOMA_Method);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("MARSIOMA",MARSIOMA);
   XMA1.XMAPhaseCheck("RSIOMAPhase",RSIOMAPhase,MARSIOMA_Method);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- превращение динамического массива TriggerBuffer в индикаторный буфер
   SetIndexBuffer(2,TriggerBuffer,INDICATOR_DATA);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"RSIOMA");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| RSIOMA iteration function                                        | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double price,x1xma,rel,RSI,positive,negative,sump,sumn,res;
   static double prev_positive,prev_negative;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,clr;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      x1xma=XMA1.XMASeries(0,prev_calculated,rates_total,RSIOMA_Method,RSIOMAPhase,RSIOMA,price,bar,false);
      rel=Mom.MomentumSeries(min_rates_1,prev_calculated,rates_total,MomPeriod,x1xma,bar,false);

      sump=RSIOMA*XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,MODE_SMA_,0,RSIOMA,+MathMax(rel,0),bar,false);
      sumn=RSIOMA*XMA3.XMASeries(min_rates_2,prev_calculated,rates_total,MODE_SMA_,0,RSIOMA,-MathMin(rel,0),bar,false);

      if(bar==min_rates_3)
        {
         prev_positive=0.0;
         prev_negative=0.0;
        }

      positive=(prev_positive*(RSIOMA-1)+sump)/RSIOMA;
      negative=(prev_negative*(RSIOMA-1)+sumn)/RSIOMA;
      
      if(negative) res=1.0+positive/negative;
      else res=2.0;

      if(res) RSI=50-100/res;
      else RSI=0.0;
      IndBuffer[bar]=RSI;

      TriggerBuffer[bar]=XMA4.XMASeries(min_rates_3,prev_calculated,rates_total,MARSIOMA_Method,MARSIOMAPhase,MARSIOMA,RSI,bar,false);

      if(bar<rates_total-1)
        {
         prev_positive=positive;
         prev_negative=negative;
        }

      clr=2;
      if(RSI>MiddleLevel) {if(RSI>HighLevel) clr=4; else clr=3;}
      if(RSI<MiddleLevel) {if(RSI<LowLevel)  clr=0; else clr=1;}
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
