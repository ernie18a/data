//+------------------------------------------------------------------+
//|                                               EMAPredictive3.mq5 |
//|                      Copyright © 2007, Matthew (Dr Chaos) Kennel |
//|                            ftp://lyapunov.ucsd.edu/pub/nonlinear |
//+------------------------------------------------------------------+
/*
 Goal of this indicator:

    Given three EMA's of varying lengths, use their values
    for a estimator of "where we are now" or will be in the near future.
    This is a very simplistic method, better ones are probably found
    in the signal processing and target tracking literature.
    A Kalman filter has been known since the 1950's 1960's and there
    is better still.   Nevertheless this is easily programmable in the
    typical environments of a retail trading application like Metatrader4.

 Method:

     An an exponential moving average (EMA) or a simple moving average (SMA), for that
     matter, have a bandwidth parameter 'L', the effective length of the window.  This
     is in units of time or, really, inverse of frequency.  Higher L means a lower
     frequency effect. 
     With a parameter L, the weighted time index of the EMA and SMA is (L-1)/2.  Example:
     take an SMA of the previous 5 values:  -5 -4 -3 -2 -1 now.   The average "amount of time"
     back in the past of the data which go in to the SMA is hence -3, or (L-1)/2.  Same applies
     for an EMA.  The standard parameterization makes this correspondence between EMA
     and SMA.
     Therefore the idea here is to take two different EMA's, a longer, and
     a shorter of lengths L1 and L2  (L2 <L1).     Now take the pairs:
           [ -(L1-1)/2, EMA(L1) ]  [ -(L2-1)/2, EMA(L2) ]  which defines a line.
     Extrapolate to [ExtraTimeForward, y], solve for y and that is the predictive EMA estimate.  

 Application:
 
     Traditional moving averages, as simple-minded linear filters, have significant group delay.
     In engineering that isn't so important as nobody cares if your sound from your iPod is delayed
     a few milliseconds after it is first processed.  But in markets, you can't
     trade on the smoothed price, only the actual noisy, market price now.   Hence you 
     ought to estimate better.
     This statistic (what math/science people call what technical analysts call an 'indicator')
     may be useful as the "fast" moving average in a moving average crossover trading system.
     It could also be useful for the slow moving average as well.
     For instance, on a 5 minute chart:
     try for the fast: (will be very wiggly, note)

                           LongPeriod 25.0
                           ShortPeriod 8.0 
                           ExtraTimeForward 1.0

       and for the slow:

                           LongPeriod 500.0
                           ShortPeriod 50.0 to 200.0 
                           ExtraTimeForward 0.0
     
  But often a regular MA for the slow can work as well or better, it appears from visual inspection. 
  Enjoy.   
  In chaos there is order, and in that order there is chaos and order inside again. 
  Then, surrounding everything, pointy haired bosses.  
*/
//---- авторство индикатора
#property copyright "Copyright © 2007, Matthew (Dr Chaos) Kennel"
#property link      "ftp://lyapunov.ucsd.edu/pub/nonlinear"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован FireBrick цвет
#property indicator_color1  clrFireBrick
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "EMAPredictive3"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double ShortPeriod=8.0;
input double LongPeriod=25.0;
input double ExtraTimeForward=1.0;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
double p1,p3,t,t1,t3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(LongPeriod,ShortPeriod));
//----
   p1=2.0/(LongPeriod+1.0);
   p3=2.0/(ShortPeriod+1.0);
   t1=(LongPeriod-1.0)/2.0;
   t3=(ShortPeriod-1.0)/2.0;
   t=ShortPeriod+ExtraTimeForward;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"EMAPredictive3");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//---- объявления локальных переменных 
   int limit;
   double ma1,ma3,val,slope1;
   static double ma1_,ma3_;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1-begin; // стартовый номер для расчета всех баров
      //---- осуществление сдвига начала отсчета отрисовки индикатора
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      int start=limit+1;
      ma1_=price[start];
      ma3_=price[start];
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(price,true);
//---- восстановление значений переменных
   ma1=ma1_;
   ma3=ma3_;
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      val=price[bar];
      ma1=p1*val+(1.0-p1)*ma1;
      ma3=p3*val+(1.0-p3)*ma3;
      slope1=(ma3-ma1)/(t1-t3);
      IndBuffer[bar]=ma3+slope1*t;
      //---- сохранение значений переменных
      if(bar)
        {
         ma1_=ma1;
         ma3_=ma3;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
