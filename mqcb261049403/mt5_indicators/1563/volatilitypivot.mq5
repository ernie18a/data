//+------------------------------------------------------------------+
//|                                              VolatilityPivot.mq5 |
//|                                         Copyright © 2007, S.B.T. | 
//|                                     http://sufx.core.t3-ism.net/ | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, S.B.T."
//---- link to the website of the author
#property link "http://sufx.core.t3-ism.net/"
//---- indicator version number
#property version   "1.10"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- FireBrick color is used as the color of the bullish line of the indicator
#property indicator_color1  clrFireBrick
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "VolatilityPivot"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
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
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXATR class variables from the SmoothAlgorithms.mqh file
CXMA XATR1;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method ima_Method=MODE_LWMA; //averaging method                  
input int           ima_Phase=15; //smoothing parameter,
                                  // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input uint          ima_range=100;
input bool          Mode=false;
input double        atr_factor=3;
input double        DeltaPrice=30;
input int           Shift=0; //horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(XATR1.GetStartBars(ima_Method,ima_range,ima_Phase)+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"VolatilityPivot");
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
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double atr,DeltaStop;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=1; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {

      if(!Mode)
        {
         atr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
         DeltaStop=XATR1.XMASeries(1,prev_calculated,rates_total,ima_Method,ima_Phase,ima_range,atr,bar,false);
         DeltaStop*=atr_factor;
        }
      else DeltaStop=DeltaPrice*_Point;

      if(close[bar]==IndBuffer[bar-1]) IndBuffer[bar]=IndBuffer[bar-1];
      else
        {
         if(close[bar-1]<IndBuffer[bar-1] && close[bar]<IndBuffer[bar-1]) IndBuffer[bar]=MathMin(IndBuffer[bar-1],close[bar]+DeltaStop);
         else
           {
            if(close[bar-1]>IndBuffer[bar-1] && close[bar]>IndBuffer[bar-1]) IndBuffer[bar]=MathMax(IndBuffer[bar-1],close[bar]-DeltaStop);
            else if(close[bar]>IndBuffer[bar-1]) IndBuffer[bar]=close[bar]-DeltaStop;
            else IndBuffer[bar]=close[bar]+DeltaStop;
           }
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
