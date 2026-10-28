//+--------------------------------------------------------------------------------------------------+
//|                                                                   b_Kaufman_Efficiency_Ratio.mq5 |
//|                                                                    Copyright © 2011, barmenteros |
//|                                                            http://www.mql4.com/users/barmenteros |
//|                                                        https://www.mql5.com/en/users/barmenteros |
//+--------------------------------------------------------------------------------------------------+
#property copyright     "Copyright © 2011, barmenteros"
#property link          "barmenteros.fx@gmail.com"
#property version       "1.00"
#property description   "Kaufman Efficiency Ratio (also called \"generalized fractal"
#property description   "efficiency\") according to Perry Kaufman books \"Smarter Trading\""
#property description   "and \"Trading Systems & Methods\"."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_color1  clrRed
#property indicator_label1  "Kaufman Efficiency Ratio"
//+--------------------------------------------------------------------------------------------------+
//| Enumerations                                                                                     |
//+--------------------------------------------------------------------------------------------------+
enum his_switch
  {
   On,
   Off
  };
//--- input parameters
input uchar       ERperiod=10;            // Efficiency ratio period
input his_switch  histogram=Off;          // Histogram switch
input char        shift=0;                // Horizontal shift (in bars)
//--- indicator buffers
double         ERBfr[];
//+--------------------------------------------------------------------------------------------------+
//| NetPriceMovement                                                                                 |
//+--------------------------------------------------------------------------------------------------+
double NetPriceMovement(int initialbar, int period, const double &price[])
   {
    double n;
    n=MathAbs(price[initialbar]-price[initialbar-period]);
    return(n);
   }
//+--------------------------------------------------------------------------------------------------+
//| Volatility                                                                                       |
//+--------------------------------------------------------------------------------------------------+
double Volatility(int initialbar, int period, const double &price[])
   {
    int j;
    double v=0.0;
    for(j=0; j<period; j++)
      v+=MathAbs(price[initialbar-j]-price[initialbar-1-j]);
    return(v);
   }
//+--------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                         |
//+--------------------------------------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ERBfr);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
// ---- drawing settings
   if(histogram==Off) PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
   else               PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,shift);
//--- name for DataWindow and indicator subwindow label
   string short_name="KEffRatio(";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+string(ERperiod)+")");
   PlotIndexSetString(0,PLOT_LABEL,short_name+string(ERperiod)+")");
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ERperiod);
//--- initialization done
  }
//+--------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                              |
//+--------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // size of the price[] array
                const int prev_calculated,// bars handled on a previous call
                const int begin,          // where the significant data start from
                const double &price[])    // array to calculate
  {
//--- declaration of local variables 
   int    limit,i;
   double direction,noise;
//--- check for bars count
   if(rates_total<ERperiod-1+begin)
      return(0); // not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
      {
       limit=ERperiod+begin;
       ArrayInitialize(ERBfr,EMPTY_VALUE);
      }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total;i++)
      {
       direction=NetPriceMovement(i, ERperiod, price);
       noise=Volatility(i, ERperiod, price);
       if(noise==0.0) noise=0.000000001;
       ERBfr[i]=direction/noise;
      }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+--------------------------------------------------------------------------------------------------+
