//+---------------------------------------------------------------------+ 
//|                                                        NavelEMA.mq5 | 
//|                                        Copyright © 2008, Bookkeeper |
//|                                                yuzefovich@gmail.com | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Bookkeeper"
#property link "yuzefovich@gmail.com" 
//---- indicator version number
#property version   "1.00"
#property description "The classic EMA with the real number and input timeseries of the calculated one"
#property description "by formula: NavelEMA = EMA( ( close*5 + open*2 + high + low ) / 9 )."
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- MediumOrchid color is used as the color of the bullish line of the indicator
#property indicator_color1 clrMediumOrchid
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "NavelEMA"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input double EmaLength=12.75; // depth of smoothing                   
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in points
//+-----------------------------------+
//---- indicator buffer
double EMABuffer[];
double dPriceShift;
//---- Declaration of global variables
int min_rates_total;
//+------------------------------------------------------------------+
// CMoving_Average class description                                 |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| EMA indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=2;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,EMABuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"NavelEMA( Length = ",EmaLength,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| EMA iteration function                                           | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of local variables
   int first,bar;
   double series,ema;

   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
     {
      first=0; // starting number for calculation of all bars
     }
   else first=prev_calculated-min_rates_total; // starting index for the calculation of new bars

//---- declaration of the CMoving_Average class variables from the SmoothAlgorithms.mqh file 
   static CMoving_Average EMA;

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      series=(close[bar]*5+open[bar]*2+high[bar]+low[bar])/9;
      ema=EMA.EMASeries(0,prev_calculated,rates_total,EmaLength,series,bar,false);      
      EMABuffer[bar]=ema+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
