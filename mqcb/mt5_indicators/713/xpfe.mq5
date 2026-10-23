//+------------------------------------------------------------------+
//|                                                         XPFE.mq5 | 
//|                  Copyright © 2008, giampiero.raschetti@gmail.com |
//|                                            http://www.fxtrade.it |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, giampiero.raschetti@gmail.com"
#property link "http://www.fxtrade.it"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- one plot is used
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
//---- displaying the indicator line label
#property indicator_label1  "XPFE"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
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
   PRICE_SIMPLE,         // Simple Price (OC/2)
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
input int PfePeriod=5;                     // PFE period
input Smooth_Method PfeMA_Method=MODE_EMA; // Smoothing method
input int PfeLength=5;                     // Smoothing depth                    
input int PfePhase=15;                     // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int Shift=0;                         // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double XPFE[];

//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_Pfe;
//+------------------------------------------------------------------+   
//| XPFE indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_Pfe=PfePeriod+1;
   min_rates_total=min_rates_Pfe+XMA1.GetStartBars(PfeMA_Method,PfeLength,PfePhase);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("PfeLength", PfeLength);
   XMA1.XMAPhaseCheck("PfePhase", PfePhase, PfeMA_Method);

//---- set XPFE[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XPFE,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,PLOT_EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(PfeMA_Method);
   StringConcatenate(shortname,"XPFE(",PfeLength,", ",Smooth1,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XPFE iteration function                                          | 
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double x1xma,noise,pfe;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=min_rates_Pfe;       // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      noise=0.000000001;
      for(int k=0; k<PfePeriod; k++)
        noise+=MathAbs(PriceSeries(IPC,bar-k,open,low,high,close)-PriceSeries(IPC,bar-k-1,open,low,high,close));
      
      pfe=(PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-PfePeriod,open,low,high,close))/noise;

      x1xma=XMA1.XMASeries(min_rates_Pfe,prev_calculated,rates_total,PfeMA_Method,PfePhase,PfeLength,pfe,bar,false);
     
      XPFE[bar]=x1xma;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
