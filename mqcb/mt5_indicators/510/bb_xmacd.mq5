//+---------------------------------------------------------------------+ 
//|                                                        BB_XMACD.mq5 | 
//|                                         Copyright © 2009, EarnForex |
//|                                           http://www.earnforex.com/ |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the SmoothAlgorithms.mqh file      |
//| in the directory: MetaTrader\\MQL5\Include                          |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, EarnForex"
#property link      "http://www.earnforex.com"
#property version   "1.01"
#property description "BB MACD - Bollinger Bands with MACD mutation based on Moving Averages"
#property description "and Standard Deviation indicators."
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only three plots are used
#property indicator_plots   3
//+------------------------------------------+
//|  Signal line drawing parameters          |
//+------------------------------------------+
//---- drawing the indicator as a three-colored symbol
#property indicator_type1 DRAW_COLOR_ARROW
//---- the following colors are used in a three-colored line
#property indicator_color1 Gray,Lime,Magenta
//---- the indicator line is a continuous one
#property indicator_style1 STYLE_SOLID
//---- the width of the indicator line is 3
#property indicator_width1 3
//---- displaying the signal line label
#property indicator_label1  "Signal MACD"
//+------------------------------------------+
//|  Bollinger Bands drawing parameters      |
//+------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
//---- the following colors are used
#property indicator_color2 Blue
#property indicator_color3 Red
//---- the indicator lines are continuous ones
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- Bollinger Bands width is equal to 1
#property indicator_width2 1
#property indicator_width3 1
//---- display of Bollinger Bands labels
#property indicator_label2 "Up BB"
#property indicator_label3 "Dn BB"
//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4;
CStdDeviation STD;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
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
input Smooth_Method MA_SMethod=MODE_T3;        // Histogram smoothing method
input int Fast_XMA = 12;                       // Fast moving average period
input int Slow_XMA = 26;                       // Slow moving average period
input int SmPhase= 100;                        // Moving averages smoothing parameter
input Smooth_Method Signal_Method=MODE_JJMA;   // Signal line smoothing method
input int Signal_XMA=9;                        // Signal line period 
input int Signal_Phase=100;                    // Signal line parameter
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Price constant
input Smooth_Method BB_Method=MODE_SMA;        // Bollinger smoothing method
input int BBPeriod=20;                         // The period for Bollinger bands
input int BBPhase=100;                         // Bollinger smoothing parameter
input double BBDeviation=2.5;                  // Bollinger deviation
//---- declaration of the integer variables for the start of data calculation
int start,macd_start,sign_start;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double SignBuffer[],ColorSignBuffer[],ExtLineBuffer1[],ExtLineBuffer2[];
//+------------------------------------------------------------------+
//| The iPriceSeries function description                            |
//| Moving_Average class description                                 | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   macd_start=MathMax(XMA1.GetStartBars(MA_SMethod,Fast_XMA,SmPhase),XMA1.GetStartBars(MA_SMethod,Slow_XMA,SmPhase));
   sign_start=macd_start+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase);
   start=sign_start+XMA1.GetStartBars(BB_Method,BBPeriod,BBPhase);

//---- set SignBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SignBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Signal MACD");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ColorSignBuffer[] dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start+1);

//---- set ExtLineBuffer1[] and ExtLineBuffer2[] dynamic arrays as indicator buffers
   SetIndexBuffer(2,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer2,INDICATOR_DATA);

//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
   XMA1.XMALengthCheck("BBPeriod", BBPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);
   XMA1.XMAPhaseCheck("BBPhase", BBPhase, BB_Method);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_SMethod);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   string Smooth3=XMA1.GetString_MA_Method(BB_Method);
   StringConcatenate(shortname,
                     "XMACD( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",BBPeriod,", ",
                     Smooth1,", ",Smooth2,", ",Smooth3," )");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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
   if(rates_total<start) return(0);
//---- declaration of integer variables
   int first1,first2,bar;
//---- declaration of variables with a floating point  
   double price_,fast_xma,slow_xma,xmacd,sign_xma,bbxma,stdev;
//---- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first1=0;       // starting index for calculation of all first loop bars
      first2=start+1; // starting index for calculation of all second loop bars
     }
   else // starting index for calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
     }
//---- main indicator calculation loop
   for(bar=first1; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);

      fast_xma = XMA1.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Fast_XMA, price_, bar, false);
      slow_xma = XMA2.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Slow_XMA, price_, bar, false);

      xmacd=fast_xma-slow_xma;
      sign_xma=XMA3.XMASeries(macd_start,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);

      //---- Bollinger Bands calculation 
      bbxma=XMA4.XMASeries(sign_start+1,prev_calculated,rates_total,BB_Method,BBPhase,BBPeriod,sign_xma,bar,false);
      stdev=STD.StdDevSeries(sign_start,prev_calculated,rates_total,BBPeriod,BBDeviation,sign_xma,bbxma,bar,false);

      //---- 
      if(bar<=start)
        {
         bbxma=EMPTY_VALUE;
         stdev=0.0;
        }

      //---- loading the obtained values in the indicator buffers      
      SignBuffer[bar]=sign_xma;
      ExtLineBuffer1[bar]=bbxma+stdev;
      ExtLineBuffer2[bar]=bbxma-stdev;
     }
//---- main loop of the signal label coloring
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorSignBuffer[bar]=0;
      if(SignBuffer[bar]>SignBuffer[bar-1]) ColorSignBuffer[bar]=1;
      if(SignBuffer[bar]<SignBuffer[bar-1]) ColorSignBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
