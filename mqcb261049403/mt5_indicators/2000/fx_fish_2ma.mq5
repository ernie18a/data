//+---------------------------------------------------------------------+
//|                                                     FX_FISH_2MA.mq5 |
//|                                        Copyright © 2005, Kiko Segui | 
//|                                                  webtecnic@terra.es | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2005, Kiko Segui"
#property link "webtecnic@terra.es" 
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 5
#property indicator_buffers 5 
//--- four plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing indicator as a five-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- colors of the five-color histogram are as follows
#property indicator_color1 clrMagenta,clrPurple,clrGray,clrBlue,clrDodgerBlue
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "FX_FISH Histogram"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//--- color used for the color of the indicator line
#property indicator_color2 clrDarkViolet
//--- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2 2
//--- displaying the signal line label
#property indicator_label2  "FX_FISH Line"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//--- color used for the color of the indicator line
#property indicator_color3 clrTeal
//--- Indicator line is a solid one
#property indicator_style3 STYLE_SOLID
//--- indicator line width is 3
#property indicator_width3 2
//--- displaying the signal line label
#property indicator_label3  "FX_FISH MA Line1"
//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type4 DRAW_LINE
//--- color used for the color of the indicator line
#property indicator_color4 clrDarkOrange
//--- Indicator line is a solid one
#property indicator_style4 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width4 2
//--- displaying the signal line label
#property indicator_label4  "FX_FISH MA Line2"
//+-----------------------------------+
//|  Description of smoothing classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPL_,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint period=10;                            // Extrema finding period
input Smooth_Method MA_Method1=MODE_SMA;         // Histogram averaging method
input uint Length1=9;                            // Histogram averaging period
input int Phase1=100;                            // Histogram averaging parameter
//--- Phase1: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase1: for VIDYA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_SMA;         // Signal line averaging method
input uint Length2 = 45;                         // Signal line averaging period
input int Phase2 = 100;                          // Signal line averaging parameter
//--- Phase2: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase2: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ AppliedPrice=PRICE_CLOSE_;  // Price constant
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2;
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer1[],IndBuffer2[],IndBuffer3[],IndBuffer4[],IndBuffer[],ColorIndBuffer1[];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=int(period);
   min_rates_2=min_rates_1+XMA1.GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total=min_rates_2+XMA1.GetStartBars(MA_Method2,Length2,Phase2);
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ColorIndBuffer1,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,IndBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,IndBuffer4,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer1,true);
   ArraySetAsSeries(ColorIndBuffer1,true);
   ArraySetAsSeries(IndBuffer2,true);
   ArraySetAsSeries(IndBuffer3,true);
   ArraySetAsSeries(IndBuffer4,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1",Length1);
   XMA1.XMALengthCheck("Length2",Length2);
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);
   XMA1.XMAPhaseCheck("Phase2",Phase2,MA_Method2);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"FX_FISH_2MA( ",period,", ",Length1,", ",Length2," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of integer variables
   int limit,bar,maxbar1,maxbar2;
//--- declaration of variables with a floating point  
   double price,Value,Range,Fish,MaxH,MinL;
   static double Value1,Fish1;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_1-1; // starting index for calculation of all bars
      Value1=0.0;
      Fish1=0.0;
     }
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only
//---
   maxbar1=rates_total-min_rates_1-1;
   maxbar2=rates_total-min_rates_2-1;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//--- restoring the values of the variables
   Value=Value1;
   Fish=Fish1;
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MaxH=high[ArrayMaximum(high,bar,period)];
      MinL=low[ArrayMinimum(low,bar,period)];
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);
      Range=MaxH-MinL;
      if(Range) Value=0.33*2*((price-MinL)/Range-0.5)+0.67*Value1;
      else Value=0.0;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      Fish=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      IndBuffer1[bar]=Fish;
      IndBuffer2[bar]=Fish;
      //--- saving values of variables
      if(bar)
        {
         Value1=Value;
         Fish1=Fish;
        }
      IndBuffer3[bar]=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,Fish,bar,true);
      IndBuffer4[bar]=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,IndBuffer3[bar],bar,true);
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) limit=rates_total-min_rates_total;
//--- Main cycle of the histogram coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      if(IndBuffer1[bar]>0)
        {
         if(IndBuffer1[bar]>IndBuffer1[bar+1]) clr=4;
         if(IndBuffer1[bar]<IndBuffer1[bar+1]) clr=3;
        }
      if(IndBuffer1[bar]<0)
        {
         if(IndBuffer1[bar]<IndBuffer1[bar+1]) clr=0;
         if(IndBuffer1[bar]>IndBuffer1[bar+1]) clr=1;
        }
      ColorIndBuffer1[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
