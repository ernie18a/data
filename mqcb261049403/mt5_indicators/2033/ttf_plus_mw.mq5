//+---------------------------------------------------------------------+
//|                                                     TTF_Plus_MW.mq5 |
//|                                            Copyright © 2007, MojoFX |
//|                                            http://fx.studiomojo.com |
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2007, MojoFX"
//--- link to the website of the author
#property link "http://fx.studiomojo.com"
//--- Indicator version
#property version   "1.00"
//---- Drawing the indicator in the main window
#property indicator_chart_window
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 1 as a label
#property indicator_type1   DRAW_ARROW
//--- blue color is used for the indicator line
#property indicator_color1  clrBlue
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying of the the indicator label
#property indicator_label1  "Upper TTF_Plus_MW"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//--- medium violet red color is used for the indicator line
#property indicator_color2  clrMediumVioletRed
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the the indicator label
#property indicator_label2  "Lower TTF_Plus_MW"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint   TTFbars=6;                 // Extrema finding period
input Smooth_Method XMA_Method=MODE_T3; // Method of averaging
input uint XLength=12;                  // Smoothing depth                    
input int XPhase=15;                    // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input int    Shift=0;                   // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Getting the handle of the ATR indicator
   int ATRPeriod=15;
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- initialization of variables of the start of data calculation
   min_rates_=int(TTFbars+1);
   min_rates_total=int(MathMax(XMA1.GetStartBars(XMA_Method,XLength,XPhase)+min_rates_,ATRPeriod));
//--- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing buffer elements as timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing buffer elements as timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"TTF_Plus_MW(",TTFbars,", ",Smooth,", ",XLength,XPhase,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- declarations of local variables 
   double ATR[],HighestHighRecent,HighestHighOlder;
   double LowestLowRecent,LowestLowOlder,BuyPower,SellPower,res,TTF;
   int limit,to_copy,bar,maxbar;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_-1;               // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;            // starting index for calculation of new bars
     }
   maxbar=rates_total-min_rates_-1;
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      HighestHighRecent=high[ArrayMaximum(high,bar+TTFbars+1,TTFbars)];
      HighestHighOlder=high[ArrayMaximum(high,bar+1,TTFbars)];
      LowestLowRecent=low[ArrayMinimum(low,bar+TTFbars+1,TTFbars)];
      LowestLowOlder=low[ArrayMinimum(low,bar+1,TTFbars)];
      BuyPower=HighestHighRecent-LowestLowOlder;
      SellPower=HighestHighOlder -LowestLowRecent;
      res=0.5*(BuyPower+SellPower);
      if(res) TTF=100*(BuyPower-SellPower)/res;
      else TTF=EMPTY_VALUE;
      TTF=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,TTF,bar,true);
      if(TTF<=-100) ExtMapBufferDown[bar]=high[bar]+ATR[bar]*3/8;
      if(TTF>=+100) ExtMapBufferUp[bar]=low[bar]-ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
