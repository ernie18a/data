//+---------------------------------------------------------------------+
//|                                         ZZ_YZ_MDAC_ELDER 1-1000.mq5 | 
//|                                             Copyright © 2007, YURAZ | 
//|                                                         yzh@mail.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property  copyright "Copyright © 2007, YURAZ"
#property  link      "yzh@mail.ru"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the three color histogram
#property indicator_color1 clrRed,clrBlue,clrTeal
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "ZZ_YZ_MDAC_ELDER 1-1000"
//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- color is used for the color of the indicator line
#property indicator_color2 clrChocolate
//---- the indicator line is a continuous curve
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width2 2
//---- displaying the signal line label
#property indicator_label2  "Signal Line"
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
input int Fast_MA = 12;                        // Fast MA period
input int Slow_MA = 26;                        // Depth of the SMMA smoothing
input ENUM_MA_METHOD MA_Method_=MODE_EMA;      // Indicator averaging method
input int Signal_MA=9;                         // Period of the signal line 
input ENUM_MA_METHOD Signal_Method_=MODE_EMA;  // Indicator averaging method
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Price constant
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,macd_min_rates_total=0;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double MACDBuffer[],SignBuffer[],ColorMACDBuffer[];
//+------------------------------------------------------------------+
// Description of the iPriceSeries function                          |
// Description of the Moving_Average class                           | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   if(MA_Method_!=MODE_EMA) macd_min_rates_total=MathMax(Fast_MA,Slow_MA);
   min_rates_total=macd_min_rates_total+Signal_MA+1;
//---- set the dynamic array MACDBuffer as an indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorMACDBuffer,INDICATOR_COLOR_INDEX);
//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ZZ_YZ_MDAC_ELDER 1-1000( ",Fast_MA,", ",Slow_MA,", ",Signal_MA," )");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of integer variables
   int first1,first2,bar,clr;
//---- declaration of variables with a floating point  
   double price_,fast_ma,slow_ma;

//---- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      first1=0; // starting number for calculation of all first loop bars
      first2=macd_min_rates_total+1; // starting number for calculation of all bars of the second loop
     }
   else // starting number for calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
     }

//---- declaration of the CMoving_Average class variables from the MASeries_Cls.mqh file
   static CMoving_Average MA1,MA2,MA3;

//---- The main loop of the indicator calculation
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);

      fast_ma = MA1.MASeries(0, prev_calculated, rates_total, Fast_MA, MA_Method_, price_, bar, false);
      slow_ma = MA2.MASeries(0, prev_calculated, rates_total, Slow_MA, MA_Method_, price_, bar, false);

      MACDBuffer[bar]=fast_ma-slow_ma;
      SignBuffer[bar]=MA3.MASeries(macd_min_rates_total,prev_calculated,rates_total,Signal_MA,Signal_Method_,MACDBuffer[bar],bar,false);
     }

//---- Main loop of the MACD indicator coloring
   for(bar=first2; bar<rates_total && !IsStopped(); bar++)
     {
      double current=MACDBuffer[bar];
      double prev=MACDBuffer[bar-1];

      double Scurrent=SignBuffer[bar];
      double Sprev=SignBuffer[bar-1];

      if(current>prev && Scurrent>Sprev) clr=2;
      else
         if(current<prev && Scurrent<Sprev) clr=0;
      else
         if(current>prev && Scurrent<Sprev) clr=1;
      else
         if(current<prev && Scurrent>Sprev) clr=1;

      ColorMACDBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
