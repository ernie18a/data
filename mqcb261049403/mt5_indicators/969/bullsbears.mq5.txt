//+------------------------------------------------------------------+
//|                                                   BullsBears.mq5 | 
//|                                        Copyright © 2012, Zhaslan |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Zhaslan"
#property link      ""
//---- Indicator Version Number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  BullsBears indicator drawing parameters     |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- as a cloud color
#property indicator_color1  OrangeRed,ForestGreen
//---- bearish indicator label display
#property indicator_label1  "BullsBears"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
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
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_LWMA;          // Smoothing method
input int XLength=12;                              // Smoothing depth                    
input int XPhase=15;                               // Smoothing parameter
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input int Shift=0;                                 // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- Declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
//---- Declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XMA1.GetStartBars(XMA_Method,XLength,XPhase);
//---- Setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   
//---- Set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- Shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- Shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- Performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- Initializations of variable for indicator short name
   string shortname="BullsBears";
//---- Creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- Determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- Check if number of bars is sufficient for calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of variables with a floating point  
   double ticksize,swing,Bulls_,Bears_,Hilo,OpCl;
//---- Declaration of integer variables
   int first,bar;
   long Volume;

//---- Calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0;                                           // starting index for calculation of all bars
   else first=prev_calculated-1;                         // starting index for calculation of new bars

//---- Main loop of indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(VolumeType==VOLUME_TICK) Volume=tick_volume[bar];
      else                        Volume=volume[bar];

      Hilo=high[bar]-low[bar];
      OpCl=open[bar]-close[bar];
      ticksize=Hilo/Volume;
      if(!ticksize) ticksize=1;
      swing=(Hilo+MathAbs(OpCl))/(2*ticksize);

      if(open[bar]>close[bar]) Bulls_=+OpCl/ticksize+swing; else Bulls_=swing;
      if(open[bar]<close[bar]) Bears_=-OpCl/ticksize+swing; else Bears_=swing;

      BullsBuffer[bar]=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,Bulls_,bar,false);
      BearsBuffer[bar]=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,Bears_,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
