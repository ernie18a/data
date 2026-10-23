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
//---- author of the indicator
#property copyright "Copyright © 2007, Matthew (Dr Chaos) Kennel"
#property link      "ftp://lyapunov.ucsd.edu/pub/nonlinear"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- FireBrick color is used as the color of the bullish line of the indicator
#property indicator_color1  clrFireBrick
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "EMAPredictive3"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input double ShortPeriod=8.0;
input double LongPeriod=25.0;
input double ExtraTimeForward=1.0;
input int Shift=0; //horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
double p1,p3,t,t1,t3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(LongPeriod,ShortPeriod));

   p1=2.0/(LongPeriod+1.0);
   p3=2.0/(ShortPeriod+1.0);
   t1=(LongPeriod-1.0)/2.0;
   t3=(ShortPeriod-1.0)/2.0;
   t=ShortPeriod+ExtraTimeForward;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"EMAPredictive3");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- declaration of local variables 
   int limit,bar;
   double ma1,ma3,val,slope1,predict;
   static double ma1_,ma3_;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1-begin; // starting index for calculation of all bars
      //---- performing the shift of beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      int start=limit+1;
      ma1_=price[start];
      ma3_=price[start];
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(price,true);

//---- restoring the values of the variables
   ma1=ma1_;
   ma3=ma3_;

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      val=price[bar];
      //----
      ma1=p1*val+(1.0-p1)*ma1;
      ma3=p3*val+(1.0-p3)*ma3;
      slope1=(ma3-ma1)/(t1-t3);
      predict=ma3+slope1*t;
      IndBuffer[bar]=predict;

      //---- saving values of variables
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
