//+------------------------------------------------------------------+
//|                                                        PLdot.mq5 |
//|                                      Copyright © 2006, Eli hayun |
//|                                          http://www.elihayun.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eli hayun"
#property link      "http://www.elihayun.com"
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- The number of indicator buffers
#property indicator_buffers 1 
//---- Only one graphical plotting used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_ARROW
//---- DeepPink is used as the color of the indicator line
#property indicator_color1 clrDeepPink
//---- The width of the indicator line is equal to 2
#property indicator_width1  2
//---- Display of the indicator label
#property indicator_label1  "PLdot"

//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in points
//+-----------------------------------+

//---- Declaring a dynamic array that will be further 
// used as an indicator buffer
double PLdot[];

//---- Declaring a variable of the value of the vertical MA shift
double dPriceShift;
//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| PLdot indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=4;

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,PLdot,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"PLdot");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| PLdot iteration function                                         | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
  //---- Check if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=min_rates_total; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double res=(
                  ((high[bar-1]+low[bar-1]+close[bar-1])/3)+
                  ((high[bar-2]+low[bar-2]+close[bar-2])/3)+
                  ((high[bar]+low[bar]+close[bar])/3)
                  )/3;
      //----       
      PLdot[bar]=res+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
