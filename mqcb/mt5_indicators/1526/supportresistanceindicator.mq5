//+------------------------------------------------------------------+
//|                                  Support-ResistanceIndicator.mq5 |
//|                                       Copyright © 2007, Tinytjan |
//|                                                 tinytjan@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Tinytjan"
#property link      "tinytjan@mail.ru"
#property description "Support-Resistance Indicator"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only 5 graphical plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color1 clrBlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Middle Line"

//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of levels colors
#property indicator_color2  clrLime
#property indicator_color3  clrRed
//---- levels are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- levels width is equal to 2
#property indicator_width2  2
#property indicator_width3  2
//---- display levels labels
#property indicator_label2  "+Resistance Line"
#property indicator_label3  "Support Line"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint WindowSize=20; //window width          
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double ExtLineBuffer0[];

//---- declaration of dynamic arrays that will further be 
// used as levels indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[];

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//|  Gauss algorithm description                                     |
//+------------------------------------------------------------------+    
#include <OneSideGaussian.mqh> 
//+------------------------------------------------------------------+   
//| Support-Resistance indicator initialization function             | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(WindowSize+5);
   BuffersInit();

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer0,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Support-Resistance Indicator(",WindowSize,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Support-Resistance Indicator iteration function                  | 
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
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar;
   double Max,Min,slow,shigh;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Max=0;
      Min=999999999;
      
      for(int kkk=bar; kkk<int(bar+WindowSize); kkk++)
        {
         slow=Smooth_5(rates_total,PRICE_LOW,kkk,open,low,high,close);
         if(slow<Min) Min=slow;

         shigh=Smooth_5(rates_total,PRICE_HIGH,kkk,open,low,high,close);
         if(shigh>Max) Max=shigh;
        }    
     
      ExtLineBuffer1[bar]=Max;
      ExtLineBuffer0[bar]=(Max+Min)/2;
      ExtLineBuffer2[bar]=Min;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
