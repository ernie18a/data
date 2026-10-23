/*
 * The operation of the indicator requires
 * SmoothAlgorithms.mqh
 * to be placed in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                    ColorXATR.mq5 | 
//|                                   Copyright © 2011,   Martingeil | 
//|                                                    fx.09@mail.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Martingeil"
#property link "fx.09@mail.ru"
//---- indicator version number
#property version   "1.00"
#property description "Color smoothed ATR"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  declaration of constants              |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color1  Gray,Gold,Red
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "XATR"

//+-----------------------------------+
//|  CXMA class description            |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA;
//+-----------------------------------+
//|  declaration of enumerations          |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input int ATRPeriod=12; //ATR period
input Smooth_Method XMA_Method=MODE_JJMA; //smoothing method
input int XLength=5; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient process;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//---- Declaration of integer variables for storing indicator handles
int ATR_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- getting the ATR indicator handle
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get the ATR indicator handle");

//---- Initialization of variables of data starting point
   min_rates_total=XMA.GetStartBars(XMA_Method,XLength,XPhase)+ATRPeriod+1;

//---- setting alerts for invalid values of external parameters
   XMA.XMALengthCheck("XLength", XLength);
   XMA.XMAPhaseCheck("XPhase", XPhase, XMA_Method);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer,true);

//---- initialization of a variable for a short name of the indicator
   string shortname;
   string Smooth=XMA.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XATR(",ATRPeriod,", ",Smooth,", ",XLength,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Declaration of variables with a floating point  
   double ATR[],xatr;
//---- Declaration of integer variables and getting the bars already calculated
   int maxbar,to_copy,limit,bar;

   maxbar=rates_total-ATRPeriod-1;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=maxbar; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+1;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(ATR,true);

//---- copy new data into the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- Main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      xatr=XMA.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,ATR[bar],bar,true);
      IndBuffer[bar]=NormalizeDouble(xatr/_Point,0);
     }
//----  
   if(!prev_calculated) limit--;

//---- Main indicator coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(IndBuffer[bar+1]<IndBuffer[bar]) ColorIndBuffer[bar]=2.0;
      else if(IndBuffer[bar+1]>IndBuffer[bar]) ColorIndBuffer[bar]=1.0;
      else ColorIndBuffer[limit]=0.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
