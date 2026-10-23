//+------------------------------------------------------------------+
//|                                             XprofuterOverlay.mq5 |
//|                                                                  |
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1  Red
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Signal"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input uint per       = 14;  // Period for signal
input uint drawShift = 14;  // Forward shift
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double ExtLineBuffer[];
double ExtBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(per);

//---- set ExtLineBuffer1dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by drawShift
   PlotIndexSetInteger(0,PLOT_SHIFT,drawShift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer,true);
   
//---- set ExtLineBuffer1dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Xprofuter(",per," ,",drawShift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables
   int bar,limit,lim;
   double imp,barClose;

//---- Calculate the "limit" starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-min_rates_total; // starting index for calculation of all bars
     }
   else limit=int(rates_total-prev_calculated+per); // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(int(bar-per)<0) lim=0;
      else lim=int(bar-per);

      imp=0;
      for(int i=bar; i>=lim; i--) imp+=(close[i]-open[i]);
      ExtBuffer[bar]=imp;
      ExtLineBuffer[bar]=EMPTY_VALUE;
     }
     
   barClose = close[0]-ExtBuffer[per];
//---- main cycle of calculation of the indicator
   for(bar = int(per-1); bar >= 0 && !IsStopped(); bar--) ExtLineBuffer[bar]=barClose+ExtBuffer[bar];
//----      
   return(rates_total);
  }
//+------------------------------------------------------------------+
