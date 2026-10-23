/*
 * Place SmoothAlgorithms.mqh
 * in the following folder (directory): MetaTrader\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                       MACD Elder Impulse Max.mq5 | 
//|                                       Copyright © 2012, MaxAgeNT | 
//|                                        http://forex.agent.zp.ua/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, MaxAgeNT"
#property link "http://forex.agent.zp.ua/" 
//---- Indicator Version Number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four-color histogram
#property indicator_color1 Gray,Red,Blue,Lime
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "MACD"

//---- drawing of the indicator as a three color line
#property indicator_type2 DRAW_COLOR_LINE
//---- the following colors are used in a three-colored line
#property indicator_color2 Gray,Teal,Magenta
//---- the indicator line is a dash-dotted curve
#property indicator_style2 STYLE_DASHDOTDOT
//---- the width of indicator line is 3
#property indicator_width2 3
//---- displaying the signal line label
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ // Type of constant
  {
   PRICE_CLOSE_ = 1,     // PRICE_CLOSE
   PRICE_OPEN_,          // PRICE_OPEN
   PRICE_HIGH_,          // PRICE_HIGH
   PRICE_LOW_,           // PRICE_LOW
   PRICE_MEDIAN_,        // PRICE_MEDIAN
   PRICE_TYPICAL_,       // PRICE_TYPICAL
   PRICE_WEIGHTED_,      // PRICE_WEIGHTED
   PRICE_SIMPL_,         // PRICE_SIMPL_
   PRICE_QUARTER_,       // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   // PRICE_TRENDFOLLOW1_
  };
input int Fast_MA = 12;                        // Period of the fast moving average
input int Slow_MA = 26;                        // SMMA smoothing depth
input ENUM_MA_METHOD MA_Method_=MODE_EMA;      // Indicator smoothing method
input int Signal_MA=9;                         // Signal line period 
input ENUM_MA_METHOD Signal_Method_=MODE_EMA;  // Indicator smoothing method
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Price constant
//+-----------------------------------+
//---- Declaration of the integer variables for the start of data calculation
int start,macd_start=0;
//---- Declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double MACDBuffer[],SignBuffer[],ColorMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//| iPriceSeries function description                                |
//| Moving_Average class description                                 | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   if(MA_Method_!=MODE_EMA) macd_start=MathMax(Fast_MA,Slow_MA);
   start=macd_start+Signal_MA+1;

//---- transformation of the dynamic array MACDBuffer[] into an indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,macd_start);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"MACD");
//---- setting the indicator values that will not be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ColorMACDBuffer[] dynamic array as a color indicator buffer   
   SetIndexBuffer(1,ColorMACDBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,macd_start+1);

//---- set SignBuffer[] dynamic array as an indicator buffer[]
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Signal SMA");
//---- setting the indicator values that will not be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ColorSignBuffer[] dynamic array as a color indicator buffer   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start+1);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"MACD( ",Fast_MA,", ",Slow_MA,", ",Signal_MA," )");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
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
//---- Check if number of bars is sufficient for calculation
   if(rates_total<start) return(0);

//---- Declaration of integer variables
   int first1,first2,first3,bar;
//---- Declaration of variables with a floating point  
   double price_,fast_ma,slow_ma,Scurrent,current,prev;
   static double Sprev;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first1=0;            // starting index for calculation of all first loop bars
      first2=macd_start+1; // starting index for calculation of all second loop bars
      first3=start+1;      // starting number for calculation of all third loop bars
     }
   else // starting index for calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
      first3=first1;
     }

//---- Declaration of the CMoving_Average class variables from the MASeries_Cls.mqh file
   static CMoving_Average MA1,MA2,MA3,MA4;

//---- Main cycle of calculation of the indicator
   for(bar=first1; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);

      fast_ma = MA1.MASeries(0, prev_calculated, rates_total, Fast_MA, MA_Method_, price_, bar, false);
      slow_ma = MA2.MASeries(0, prev_calculated, rates_total, Slow_MA, MA_Method_, price_, bar, false);

      MACDBuffer[bar]=fast_ma-slow_ma;

      SignBuffer[bar]=MA3.MASeries(macd_start,prev_calculated,rates_total,Signal_MA,Signal_Method_,MACDBuffer[bar],bar,false);
     }

//---- Main loop of the MACD indicator coloring
   for(bar=first2; bar<rates_total; bar++)
     {
      Scurrent = MA4.MASeries(macd_start+1, prev_calculated, rates_total, Fast_MA, MODE_EMA, close[bar], bar, false);
      
      if(bar==first2)
        {
         Sprev=Scurrent;
         continue;
        }
        
      current=MACDBuffer[bar];
      prev=MACDBuffer[bar-1];
      
      ColorMACDBuffer[bar]=0;
      
      if(current<prev&&Scurrent<Sprev) ColorMACDBuffer[bar]=1;
      if(current<prev&&Scurrent>Sprev) ColorMACDBuffer[bar]=2;
      if(current>prev&&Scurrent<Sprev) ColorMACDBuffer[bar]=2;
      if(current>prev&&Scurrent>Sprev) ColorMACDBuffer[bar]=3;
      
      if(bar<rates_total-1) Sprev=Scurrent;
     }

//---- Main loop of the signal line coloring
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorSignBuffer[bar]=0;
      if(MACDBuffer[bar]>SignBuffer[bar-1]) ColorSignBuffer[bar]=1;
      if(MACDBuffer[bar]<SignBuffer[bar-1]) ColorSignBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
