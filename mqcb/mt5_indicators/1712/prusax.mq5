//+------------------------------------------------------------------+ 
//|                                                       prusax.mq5 | 
//|                                Copyright © 2007, modified by zIG | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, modified by zIG"
#property link "" 
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- The number of indicator buffers is 3
#property indicator_buffers 3 
//---- Only one graphical plotting used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a three color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM2
//---- Colors used for the three color histogram
#property indicator_color1 clrMagenta,clrGray,clrLime
//---- The indicator line is solid
#property indicator_style1 STYLE_SOLID
//---- The line width is 2
#property indicator_width1 2
//---- Showing the indicator label
#property indicator_label1 "prusax"

//---- Declaring integer variables of data calculation start
int min_rates_total;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double UpIndBuffer[],DnIndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"prusax");
//--D determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- End of initialization
  } 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              | 
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
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of local variables 
   int first,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1;  // Starting number for calculating all bars
     }
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(close[bar]>open[bar])
        {
         UpIndBuffer[bar]=high[bar];
         DnIndBuffer[bar]=open[bar];
         ColorIndBuffer[bar]=2;
        }
      else if(close[bar]<open[bar])
        {
         UpIndBuffer[bar]=open[bar];
         DnIndBuffer[bar]=low[bar];
         ColorIndBuffer[bar]=0;
        }
      else
        {
         UpIndBuffer[bar]=open[bar];
         DnIndBuffer[bar]=open[bar];
         ColorIndBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
