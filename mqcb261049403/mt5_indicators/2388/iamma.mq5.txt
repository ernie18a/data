//+------------------------------------------------------------------+ 
//|                                                       i-AMMA.mq5 | 
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2007, RickD"
//--- a link to the website of the author
#property link      "www.e2e-fx.net"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Indicator drawing parameters      |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- Orange color is used as the color of the bullish line of the indicator
#property indicator_color1 clrOrange
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "i-AMMA"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint MA_Period=25; // Depth of smoothing                   
input int Shift=0;       // Horizontal shift of the indicator in bars
input int PriceShift=0;  // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[];
//--- 
double dPriceShift;
//--- declaration of integer variables of data starting point
int  min_rates_total;
//+------------------------------------------------------------------+    
//| i-AMMA indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"i-AMMA(",MA_Period,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| i-AMMA iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // a price array for indicator calculation
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);
//--- declaration of local variables
   int first,bar;
   double AMMA;
//---
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first=min_rates_total+begin; // starting index for the calculation of all bars
      IndBuffer[first-1]=price[first-1];
      //--- shift the beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     { 
      AMMA=((MA_Period-1)*(IndBuffer[bar-1]-dPriceShift)+price[bar])/MA_Period;       
      IndBuffer[bar]=AMMA+dPriceShift;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
