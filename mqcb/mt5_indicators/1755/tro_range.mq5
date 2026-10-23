//+------------------------------------------------------------------+ 
//|                                                    TRO_RANGE.mq5 | 
//|                   Copyright © 2007, Avery T. Horton, Jr. aka TRO | 
//|                                     http://www.therumpldone.com/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Avery T. Horton, Jr. aka TRO"
#property link "http://www.therumpldone.com/" 
//---- Indicator version
#property version   "1.00"
//---- The indicator is drawn in a separate window
#property indicator_separate_window 
//---- The number of indicator buffers is 2
#property indicator_buffers 2 
//---- One graphical construction is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator is drawn as a our-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- The colors of th histogram
#property indicator_color1 clrBlueViolet,clrMagenta
//---- Solid line
#property indicator_style1 STYLE_SOLID
//---- The width of the indicator is 2
#property indicator_width1 2
//---- The indicator label
#property indicator_label1 "TRO_RANGE"

//+-----------------------------------+
//|  Declaring constants              |
//+-----------------------------------+
#define RESET 0 // A constant to return a command to recalculate the indicator to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Threshold=200; // Threshold in points
//+-----------------------------------+
//---- Declaring integer variables of data calculation start
int min_rates_total;
//---- Declaring dynamic arrays that will
// further be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| TRO_RANGE indicator initialization function                      | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=1;

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"TRO_RANGE( ",Threshold," )");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- End of initialization
  }
//+------------------------------------------------------------------+  
//| TRO_RANGE iteration function                                     | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,clr;
   double Range;
   
//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- Calculations of the necessary number of copied data
//and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1; // Starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Range=(high[bar]-low[bar])/_Point;
      IndBuffer[bar]=Range;

      if(Range>=Threshold) clr=0;
      else clr=1;
      ColorIndBuffer[bar]=clr;

      //---- the number of the indicator 1 horizontal levels  
      IndicatorSetInteger(INDICATOR_LEVELS,1);
      //---- Values of the indicator horizontal levels   
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Threshold);
      //---- The color of the horizontal levels is Teal  
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrTeal);
      //---- Short dot-dash is used for the horizontal level line  
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
