//+------------------------------------------------------------------+
//|                                              ColorFisher_m11.mq5 | 
//|                                  Copyright © 23.07.2006, MartinG |
//|                                http://home.arcor.de/cam06/fisher |
//+------------------------------------------------------------------+
#property copyright "Copyright © 23.07.2006, MartinG"
#property link      "http://home.arcor.de/cam06/fisher"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной гистограммы использованы
#property indicator_color1  clrDeepSkyBlue,clrBlue,clrGray,clrPurple,clrHotPink
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ColorFisher_m11"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint    RangePeriods=10;
input double  PriceSmoothing=0.3;
input double  IndexSmoothing=0.3;
input double  HighLevel=+1.01;         // уровень перезакупа
input double  LowLevel=-1.01;          // уровень перепроданности
input int     Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(RangePeriods)+1;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname="";
   StringConcatenate(shortname,"Fisher_m11(",RangePeriods,", ",DoubleToString(PriceSmoothing,2),", ",DoubleToString(IndexSmoothing,2),", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMediumSeaGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double  LowestLow,HighestHigh,GreatestRange,MidPrice,diff,res;
   double  PriceLocation,SmoothedLocation,FishIndex,Fish;
   static double Fish_prev;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,clr;
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      Fish_prev=0.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int barx=rates_total-1-bar;
      HighestHigh=high[ArrayMaximum(high,barx,RangePeriods)];
      LowestLow=low[ArrayMinimum(low,barx,RangePeriods)];
      
      res=0.1*_Point;
      if(HighestHigh-LowestLow<res) HighestHigh=LowestLow+res;
      GreatestRange=HighestHigh-LowestLow;
      MidPrice=(high[barx]+low[barx])/2.0;
      //---- PriceLocation in current Range 
      if(GreatestRange)
        {
         PriceLocation=(MidPrice-LowestLow)/GreatestRange;
         PriceLocation=2.0*PriceLocation-1.0;           // ->  -1 < PriceLocation < +1
        }
      else PriceLocation=+0.99;
      //---- Smoothing of PriceLocation     
      Fish=PriceSmoothing*Fish_prev+(1.0-PriceSmoothing)*PriceLocation;
      SmoothedLocation=Fish;
      SmoothedLocation=MathMin(SmoothedLocation,+0.99); // verhindert, dass MathLog unendlich wird
      SmoothedLocation=MathMax(SmoothedLocation,-0.99); // verhindert, dass MathLog minuns unendlich wird
      //---- FisherIndex
      diff=1.0-SmoothedLocation;
      if(diff) FishIndex=MathLog((1+SmoothedLocation)/diff);
      else FishIndex=NULL;
      //---- Smoothing of FisherIndex
      IndBuffer[bar]=IndexSmoothing*IndBuffer[bar-1]+(1.0-IndexSmoothing)*FishIndex;

      if(bar<rates_total-1)
        {
         Fish_prev=Fish;
        }
     }

//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=2;
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>HighLevel) clr=0;
         else clr=1;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<LowLevel) clr=4;
         else clr=3;
        }
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
