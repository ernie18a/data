//+---------------------------------------------------------------------+ 
//|                                                             TTF.mq5 | 
//|                                        Copyright © 2005, Nick Bilak | 
//|                                                 beluck[at]gmail.com | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, Nick Bilak"
//---- author of the indicator
#property link      "beluck[at]gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DarkOrchid color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDarkOrchid
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "TTF"
//+----------------------------------------------+
//| Signal indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used for the indicator bearish line
#property indicator_color2  clrMagenta
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint TTFbars=8;      // extremums searching period
input int TopLine=75;      // top level to trigger
input int BottomLine=-75;  // bottom level to trigger
input uint T3Period=14;    // T3 smoothing period
input double b_=70;        // Coefficient b x100
input int Shift=0;         // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double TTFBuffer[];
double SignalBuffer[];
//---- Declaration of integer variables for the indicator handles
int CP_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
// Description of the class CT3                                      |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(2*TTFbars+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,TTFBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(TTFBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SignalBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"TTF(",TTFbars,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
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
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,maxbar;
   double HHRecent,LLOlder,HHOlder,LLRecent,BuyPower,SellPower,TTF,T3TTF;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//----   
   maxbar=rates_total-2-min_rates_total;
   
//---- declaration of variable of the class T3 from the file T3Series_Cls.mqh
   static CT3 T3_;
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HHRecent=high[ArrayMaximum(high,bar,TTFbars)];
      LLRecent=low[ArrayMinimum(low,bar,TTFbars)];
      HHOlder=high[ArrayMaximum(high,bar+TTFbars,TTFbars)];
      LLOlder=low[ArrayMinimum(low,bar+TTFbars,TTFbars)];
      //----
      BuyPower=HHRecent-LLOlder;
      SellPower=HHOlder-LLRecent;
      TTF=(BuyPower-SellPower)/(0.5*(BuyPower+SellPower))*100;    
      T3TTF=T3_.T3Series(maxbar,prev_calculated,rates_total,0,b_,T3Period,TTF,bar,true);
      TTFBuffer[bar]=T3TTF;
      //----
      if (T3TTF>=0) SignalBuffer[bar]=TopLine;
      else SignalBuffer[bar]=BottomLine;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
