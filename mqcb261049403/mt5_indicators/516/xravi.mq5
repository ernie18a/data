//+---------------------------------------------------------------------+
//|                                                           XRAVI.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\\MQL5\Include                |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Range Action Verification Index"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of the indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
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
//---- displaying the indicator label
#property indicator_label1  "XRAVI"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 +0.1
#property indicator_level2 -0.1
#property indicator_levelcolor Red
#property indicator_levelstyle STYLE_DASHDOTDOT
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
enum Applied_price_ //Type of constant
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
input Smooth_Method MA_SMethod=MODE_SMA;// Smoothing method
input int Length1=7;                    // Smoothing depth 
input int Length2=65;                   // Smoothing depth                    
input int SmPhase=15;                   // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;   // Applied price
input int Shift=0;                      // Horizontal shift of the indicator in bars
//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double XRAVI[];
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+   
//| XRAVI indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   int StartBars1=XMA1.GetStartBars(MA_SMethod, Length1, SmPhase);
   int StartBars2=XMA1.GetStartBars(MA_SMethod, Length2, SmPhase);
   StartBars=MathMax(StartBars1,StartBars2);
//---- setting up alerts for invalid values of external variables
   XMA1.XMALengthCheck("Length", Length1);
   XMA1.XMALengthCheck("Length", Length2);
   XMA1.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);

//---- set XRAVI[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XRAVI,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XRAVI");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_SMethod);
   StringConcatenate(shortname,"XRAVI(",Length1,", ",Length2,", ",Smooth1,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XRAVI iteration function                                         | 
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
   double price_,x1xma,x2xma;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                                           // starting index for calculation of all bars
   else first=prev_calculated-1;                         // starting index for calculation of new bars
//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //---- two calls of the XMASeries function.  
      x1xma = XMA1.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Length2, price_, bar, false);
      //----       
      if(x2xma!=0 && x2xma!=EMPTY_VALUE) XRAVI[bar]=100.0*(x1xma-x2xma)/x2xma;
      else                             XRAVI[bar]=EMPTY_VALUE;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
