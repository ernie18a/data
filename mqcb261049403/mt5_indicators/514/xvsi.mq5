//+---------------------------------------------------------------------+
//|                                                            XVSI.mq5 | 
//|                                         Copyright © 2005, DriverDan |
//|                                           superfunman2000@yahoo.com |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: MetaTrader\\MQL5\Include                          |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2005, DriverDan"
#property link "superfunman2000@yahoo.com/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1 Red
//---- the indicator line is a dot-dash one
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XVSI"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color2 Blue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Signal XVSI"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
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
input Smooth_Method DSmoothMethod=MODE_T3;         // Indicator smoothing method
input int DPeriod=15;                              // Smoothing period
input int DPhase=15;                               // Smoothing parameter
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input int Shift=0;                                 // Horizontal shift of the indicator in bars
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double vsiBuffer[],vsiMABuffer[];
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+   
//| XVSI indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=XMA.GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
//---- setting up alerts for invalid values of external variables
   XMA.XMALengthCheck("DPeriod",DPeriod);
//---- setting up alerts for invalid values of external variables
   XMA.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);

//---- set vsiBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,vsiBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set vsiMABuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,vsiMABuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth;
   Smooth=XMA.GetString_MA_Method(DSmoothMethod);
   StringConcatenate(shortname,"XVSI(",string(DPeriod),",",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determine the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XVSI iteration function                                          | 
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
   double vol;
//---- declaration of integer variables
   int first,bar,timeDiff;
//---- calculate the first starting index for the loop of bars recalculation and initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1;                                           // starting index for calculation of all bars
     }
   else first=prev_calculated-1;                         // starting index for calculation of new bars
//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(VolumeType==VOLUME_TICK) vol=double(tick_volume[bar]);
      else                        vol=double(volume[bar]);

      if(bar==rates_total-1)
        {
         timeDiff=int(TimeCurrent()-time[bar]);
         if(timeDiff>0) vsiBuffer[bar]=vol/timeDiff;
        }
      else vsiBuffer[bar]=vol/(time[bar]-time[bar-1]);

      vsiMABuffer[bar]=XMA.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,vsiBuffer[bar],bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
