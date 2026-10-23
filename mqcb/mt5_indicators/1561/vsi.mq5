//+------------------------------------------------------------------+
//|                                                          VSI.mq5 |
//|                                      Copyright © 2005, DriverDan |
//|                                        superfunman2000@yahoo.com | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, DriverDan"
//---- link to the website of the author
#property link "superfunman2000@yahoo.com"

#property description "Indicator that calculates volume per second (or period) and the corresponding MA."
#property description "Uses volume per second since it will be uniform for all chart periods."
#property description "Indicator seems to work best on 15m to 4h charts. IMHO, 1m and 5m periods are"
#property description "too short for valid results and 1d+ will show low periods for partial days on MT4."
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Magenta color is used for indicator line
#property indicator_color1   clrMagenta
//---- the indicator 1 line is a dot-dash one
#property indicator_style1  STYLE_DASHDOTDOT
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "VSI"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2  clrBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bullish label of the indicator
#property indicator_label2  "Signal VSI"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input Smooth_Method XMA_Method=MODE_EMA; //averaging method
input int XLength=5; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input bool showPerPeriod=false;  //showPerPeriod (false = volume per second, true = volume per chart period)
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double VSIBuffer[],SignBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total,PSec;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XMA.GetStartBars(XMA_Method,XLength,XPhase)+1;
   PSec=PeriodSeconds(PERIOD_CURRENT);

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,VSIBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set VSIBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"VSI");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int first,bar,timeDiff;
   double Vol;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      if(VolumeType==VOLUME_TICK) Vol=double(tick_volume[bar]);
      else Vol=double(volume[bar]);

      timeDiff=int(TimeCurrent()-time[bar]);
      if(bar==rates_total-1 && timeDiff>0) VSIBuffer[bar]=Vol/timeDiff;
      else VSIBuffer[bar]=Vol/PSec;

      if(showPerPeriod) VSIBuffer[bar]*=PSec;
      SignBuffer[bar]=XMA.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,VSIBuffer[bar],bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
