//+------------------------------------------------------------------+
//|                                            OneSideGaussianMA.mq5 | 
//|                                         Copyright © 2008, mladen | 
//|                                                mladenfxgmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, mladen"
#property link "mladenfxgmail.com"
//---- indicator version number
#property version   "1.00"
#property description "Moving Average on the basis of Gauss algorithm"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color1  clrDeepPink,clrGray,clrMediumSlateBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "OneSideGaussianMA"
//+-----------------------------------+
//|  Gauss averaging description      |
//+-----------------------------------+
#include <OneSideGaussianLibrary.mqh> 
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//#define MAXLENGTH 34 // The constant of Gauss function averaging period
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*
enum Applied_price_
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum SmoothMode
  {
   Smooth1 = 0,
   Smooth2,
   Smooth3,
   Smooth4,
   Smooth5,
   Smooth6,
   Smooth7,
   Smooth8
  };
*/
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input SmoothMode SmoothType=Smooth6; //type of averaging
input Applied_price_ IPC=PRICE_CLOSE_;//price constant
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=MAXLENGTH*2+1;
   GaussianInit();

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"One side Gaussian MA (",EnumToString(SmoothType),", ",EnumToString(IPC),", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
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
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double ;
//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);


//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=Smooth(SmoothType,rates_total,IPC,bar,open,low,high,close);
//----  
   if(prev_calculated<=0) limit--;

//---- Main indicator coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(IndBuffer[bar+1]<IndBuffer[bar]) ColorIndBuffer[bar]=2;
      else if(IndBuffer[bar+1]>IndBuffer[bar]) ColorIndBuffer[bar]=0;
      else ColorIndBuffer[limit]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
