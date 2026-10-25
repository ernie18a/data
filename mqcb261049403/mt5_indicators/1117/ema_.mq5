//+------------------------------------------------------------------+ 
//|                                                          EMA.mq5 | 
//|                    MQL5 code: Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.00"
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
//---- clrMediumSlateBlue color is used as the color of the bullish line of the indicator
#property indicator_color1 clrMediumSlateBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "EMA"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input double EmaLength=12.75; // smoothing depth                   
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
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,EMABuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"EMA");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"EMA( Length = ",EmaLength,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| EMA iteration function                                           | 
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
   int first,bar;
   double ema;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=begin; // starting number for calculation of all bars
      //---- performing the shift of beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      for(bar=0; bar<begin; bar++) EMABuffer[bar]=EMPTY_VALUE;
     }
   else first=prev_calculated-min_rates_total; // starting number for calculation of new bars

//---- declaration of the CMoving_Average class variables from the SmoothAlgorithms.mqh file 
   static CMoving_Average EMA;

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      ema=EMA.EMASeries(begin,prev_calculated,rates_total,EmaLength,price[bar],bar,false);
      EMABuffer[bar]=ema+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
