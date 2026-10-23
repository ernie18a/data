//+---------------------------------------------------------------------+
//|                                                          T3MACO.mq5 | 
//|                                           Copyright © 2008, Perky_z | 
//|    http://groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, Perky_z"
#property link "http://groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used for the indicator line
#property indicator_color1 clrDodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "T3MACO"

//+-----------------------------------+
//|  XMA class description            |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CMoving_Average and CT3 classes variables from the SmoothAlgorithms.mqh file
CT3 T3;
CMoving_Average EMA1,EMA2;
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint FastEMA=5; //Fast EMA period
input uint SlowEMA=8; //Slow EMA period
input uint T3Length=12;//smoothing depth                    
input int T3Phase=15; //smoothing parameter
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double T3MACO[];

//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+   
//| T3MACO indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=2;
   min_rates_total=min_rates_+1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,T3MACO,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"T3MACO");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| T3MACO iteration function                                        | 
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double ema1,ema2;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ema1=EMA1.EMASeries(0,prev_calculated,rates_total,FastEMA,close[bar],bar,false);
      ema2=EMA2.EMASeries(0,prev_calculated,rates_total,SlowEMA,open[bar],bar,false);
      T3MACO[bar]=T3.T3Series(1,prev_calculated,rates_total,MODE_T3,T3Phase,T3Length,ema1-ema2,bar,false);
      T3MACO[bar]/=_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
