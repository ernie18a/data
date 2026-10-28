//+------------------------------------------------------------------+
//|                                                VininI_WPR_FO.mq5 |
//|                                Copyright © 2009, Victor Nicolaev |
//|                                            e-mail: vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Victor Nicolaev"
#property link      "e-mail: vinin@mail.ru"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- indicator drawing 
#property indicator_type1 DRAW_COLOR_ARROW
//---- Blue, Lime and Red colors are used
#property indicator_color1 Blue,Lime,Red
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "VininI WPR FO"
//+--------------------------------------+
//|  Indicator window borders parameters |
//+--------------------------------------+
#property indicator_minimum -1.25
#property indicator_maximum  1.25
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum ENUM_IND_STYLE  // The indicator display style
  {
   COLOR_LINE = DRAW_COLOR_LINE,          // Colored line
   COLOR_HISTOGRAM=DRAW_COLOR_HISTOGRAM,  // Colored histogram
   COLOR_ARROW=DRAW_COLOR_ARROW           // Colored labels
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int  WPR_Period=5;                   // WPR period
input int  MA_Period =9;                   // Moving average period
input ENUM_MA_METHOD  MA_Method_=MODE_EMA; // Smoothing method
input double HighLevel  =+0.5;
input double MiddleLevel= 0.0;
input double LowLevel   =-0.5;
input ENUM_IND_STYLE Style=COLOR_HISTOGRAM; // Indicator display style
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ColorBuffer[],ExtLineBuffer[];
//---- declaration of integer variables for the indicators handles
int WPR_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| CMoving_Average class description                                | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=WPR_Period+MA_Period+1;
//---- getting handle of the WPR indicator
   WPR_Handle=iWPR(NULL,0,WPR_Period);
   if(WPR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the WPR indicator");

//---- set ExtLineBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- changing of the indicator display style   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Style);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- set ColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ColorBuffer,true);

//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Gray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Magenta);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"VininI WPR FO(",WPR_Period,", ",MA_Period,", ",EnumToString(MA_Method_),")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
// IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(WPR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int to_copy,limit,bar,maxbar;
   double WPR[],velue,ma,expma,fish;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-1-WPR_Period;                   // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;              // starting index for calculation of new bars

//---- calculation of maxbar starting index for the MASeries() function
   maxbar=rates_total-1-WPR_Period;

//---- calculation of the necessary amount of data to be copied 
   to_copy=limit+1;

//---- copy newly appeared data in the WPR[] array
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(WPR,true);

//---- declaration of the CMoving_Average class variables from the SmoothAlgorithms.mqh file
   static CMoving_Average MA;

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      velue=0.1*(WPR[bar]+50);
      ma=MA.MASeries(maxbar,prev_calculated,rates_total,MA_Period,MA_Method_,velue,bar,true);

      if(bar<maxbar)
        {
         expma=MathExp(2.0*ma);
         fish=(expma-1.0)/(expma+1.0);
        }
      else fish=EMPTY_VALUE;

      ExtLineBuffer[bar]=fish;
      ColorBuffer[bar]=0;
      if(ma>HighLevel&&ma!=EMPTY_VALUE) ColorBuffer[bar]=1;
      if(ma<LowLevel &&ma!=EMPTY_VALUE) ColorBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
