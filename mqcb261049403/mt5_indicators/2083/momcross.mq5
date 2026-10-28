//+---------------------------------------------------------------------+ 
//|                                                        MomCross.mq5 | 
//|                                  Copyright © 2005, Taylor Stockwell |
//|                                           mailto:stockwet@yahoo.com |
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Taylor Stockwell"
#property link      "mailto:stockwet@yahoo.com"
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- four buffers are used for calculation of drawing of the indicator
#property indicator_buffers 4
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrLime,clrRed
//--- displaying the indicator label
#property indicator_label1  "MomCross"
//+----------------------------------------------+
//| declaration of enumerations                  |
//+----------------------------------------------+
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint FastLength=5;              // Fast Momentum period
input uint SlowLength=14;             // Slow Momentum period
input uint SmoothLength=3;            // Smoothing period
input Applied_price_ IPC=PRICE_CLOSE; // Applied price
input int Shift=0;                    // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| iPriceSeries function description                                |
//| description of classes CMomentum and CJJMA                       |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| Momentum indicator initialization function                       | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---
   min_rates_=int(MathMax(FastLength,SlowLength))+1;
   min_rates_total=min_rates_+30;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"MomCross( ",FastLength,", ",SlowLength,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Momentum iteration function                                      | 
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
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of variables with a floating point  
   double price,fmom,smom;
//--- declaration of integer variables and getting calculated bars
   int first,bar;
//--- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated==0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- declaration of the CMomentum and CJJMA classes variables from the SmoothAlgorithms.mqh file
   static CMomentum FMom,SMom;
   static CJJMA FJMA,SJMA;
//--- the main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      fmom=FMom.MomentumSeries(0,prev_calculated,rates_total,FastLength,price,bar,false)/_Point;
      smom=SMom.MomentumSeries(0,prev_calculated,rates_total,SlowLength,price,bar,false)/_Point; 
      UpBuffer[bar]=FJMA.JJMASeries(min_rates_,prev_calculated,rates_total,0,100,SmoothLength,fmom,bar,false);
      DnBuffer[bar]=SJMA.JJMASeries(min_rates_,prev_calculated,rates_total,0,100,SmoothLength,smom,bar,false);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
