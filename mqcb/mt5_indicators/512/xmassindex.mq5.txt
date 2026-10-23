//+---------------------------------------------------------------------+
//|                                                      XMassIndex.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the SmoothAlgorithms.mqh file      |
//| in the directory: MetaTrader\\MQL5\Include                          |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- dodger blue color is used for the indicator line
#property indicator_color1 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Mass Index"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_SMethod=MODE_EMA; // Smoothing method
input int SmLength=25;                   // Smoothing depth                    
input int SmPhase=15;                    // Smoothing parameter
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double XMASSINDEX[];
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+   
//| XMassIndex indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=XMA1.GetStartBars(MA_SMethod,SmLength,SmPhase);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length", SmLength);
   XMA1.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);

//---- set XMASSINDEX[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XMASSINDEX,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XMA");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_SMethod);
   StringConcatenate(shortname,"Mass Index",SmLength,", ",Smooth1,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XMassIndex iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(rates_total<StartBars) return(0);
//---- declaration of variables with a floating point  
   double InputVelue,index;
//---- Declaration of integer variables and getting already calculated bars
   int first,bar;
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                                           // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars
//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      InputVelue=high[bar]-low[bar];
      index=XMA1.XMASeries(0,prev_calculated,rates_total,MA_SMethod,SmPhase,SmLength,InputVelue,bar,false);
      XMASSINDEX[bar]=index;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
