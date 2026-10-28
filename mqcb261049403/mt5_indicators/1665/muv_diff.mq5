//+------------------------------------------------------------------+
//|                                                     MUV_DIFF.mq5 | 
//|                                          Copyright © 2008, svm-d |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, svm-d"
//---- author of the indicator
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  SMA MUV_DIFF indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color1  clrRed
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "SMA MUV_DIFF"
//+----------------------------------------------+
//|  EMA MUV_DIFF indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator bearish line
#property indicator_color2  clrBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "EMA MUV_DIFF"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint MAPeriod=14;// the indicator period 
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SmaDiffBuffer[];
double EmaDiffBuffer[];
//---- Declaration of integer variables for the indicator handles
int E_Handle,S_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(MAPeriod+1);

//---- getting handle of the XMUV SMA indicator
   S_Handle=iCustom(NULL,0,"XMUV",0,MAPeriod,0,0,0);
   if(S_Handle==INVALID_HANDLE) Print(" Failed to get handle of XMUV SMA indicator");

//---- getting handle of the EMUV SMA indicator
   E_Handle=iCustom(NULL,0,"XMUV",1,MAPeriod,0,0,0);
   if(E_Handle==INVALID_HANDLE) Print(" Failed to get handle of XMUV EMA indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SmaDiffBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SmaDiffBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,EmaDiffBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(EmaDiffBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"MUV_DIFF(",MAPeriod,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
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
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(S_Handle)<rates_total
      || BarsCalculated(E_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double SDiff[],EDiff[];

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+2;
//---- copy the new data into the array
   if(CopyBuffer(S_Handle,0,0,to_copy,SDiff)<=0) return(RESET);
   if(CopyBuffer(E_Handle,0,0,to_copy,EDiff)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries 
   ArraySetAsSeries(SDiff,true);
   ArraySetAsSeries(EDiff,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      
      
      SmaDiffBuffer[bar]=(SDiff[bar]-SDiff[bar+1])/_Point;
      EmaDiffBuffer[bar]=(EDiff[bar]-EDiff[bar+1])/_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
