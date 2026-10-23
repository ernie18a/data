//+---------------------------------------------------------------------+
//|                                                        XChannel.mq5 | 
//|                                               Copyright © 2006, Gep | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Gep"
#property link ""
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the color of the indicator
#property indicator_color1  clrYellow
//--- displaying the indicator label
#property indicator_label1 "Up;Down"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; // Smoothing method
input uint XLength=20;                   // Depth of averaging                    
input int XPhase=15;                     // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input int Delta=100;                     // Vertical shift of channels in points
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double UpIndBuffer[];
double DnIndBuffer[];
//---
double dDelta;
//--- Declaring integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| XChannel indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_total=XMA1.GetStartBars(XMA_Method, XLength, XPhase);
   dDelta=Delta*_Point;
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("XLength", XLength);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XChannel(",XLength,", ",Smooth,", ",Delta,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+ 
//| XChannel iteration function                                      | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of variables with a floating point  
   double upxma,dnxma;
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     { 
      upxma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,high[bar],bar,false);
      dnxma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,low[bar],bar,false);
      //---       
      UpIndBuffer[bar]=upxma+dDelta;
      DnIndBuffer[bar]=dnxma-dDelta;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
