//+---------------------------------------------------------------------+
//|                                              Accelerator_Signal.mq5 |
//|                                       Copyright © 2007, Asystem2000 | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, Asystem2000"
#property link "" 
//--- Indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers 4
#property indicator_buffers 4 
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrDeepSkyBlue,clrMagenta
//--- displaying the indicator label
#property indicator_label1  "Accelerator Signal"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//--- colors of the five-color histogram are as follows
#property indicator_color2 clrDeepPink,clrOrange,clrGray,clrLimeGreen,clrTeal
//--- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2 2
//--- displaying the indicator label
#property indicator_label2  "Accelerator"
//+-----------------------------------+
//|  Description of smoothing classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4;
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
input Smooth_Method XMA_Method=MODE_SMA;        // Method of averaging of the Accelerator histogram
input int Fast_XMA=5;                           // Period of the fast MA
input int Slow_XMA = 34;                        // Period of the slow MA
input int XPhase = 100;                         // MA averaging parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method Sm_Method=MODE_SMA;         // Method of averaging of the Accelerator histogram
input int Sm_XMA=5;                             // Signal line period 
input int Sm_Phase=100;                         // Signal line parameter
input Smooth_Method Signal_Method=MODE_SMA;     // Signal line averaging method
input int Signal_XMA=5;                         // Period of the signal line 
input int Signal_Phase=100;                     // Parameter of the signal line
input Applied_price_ AppliedPrice=PRICE_CLOSE;  // Price constant
//+-----------------------------------+
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2;
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[],UpSignBuffer[],DnSignBuffer[];
//+------------------------------------------------------------------+    
//| Accelerator indicator initialization function                    | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- Initialization of variables of the start of data calculation
   min_rates_1=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_2=min_rates_1+XMA1.GetStartBars(Sm_Method,Sm_XMA,Sm_Phase);
   min_rates_total=min_rates_2+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;
//--- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSignBuffer,INDICATOR_DATA);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,DnSignBuffer,INDICATOR_DATA);   
//--- set XMACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);  
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Sm_XMA", Sm_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//--- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Sm_Phase", Sm_Phase, Sm_Method);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);
//--- Initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"Accelerator( ",Fast_XMA,", ",Slow_XMA,", ",Sm_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Accelerator iteration function                                   | 
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
//--- declaration of integer variables
   int first1,first2,bar;
//--- declaration of variables with a floating point  
   double price_,fast_xma,slow_xma,xmacd,sign_xma,accel,xaccel;
//--- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      first1=0; // starting number for calculation of all first loop bars
      first2=min_rates_1+1; // starting number for calculation of all bars of the second loop
     }
   else // starting number for calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
     }
//--- the main loop of the indicator calculation
   for(bar=first1; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;
      fast_xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price_,bar,false);
      slow_xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,price_,bar,false);
      xmacd=(fast_xma-slow_xma)/_Point;
      sign_xma=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,Sm_Method,Sm_Phase,Sm_XMA,xmacd,bar,false);
      accel=xmacd-sign_xma;
      xaccel=XMA4.XMASeries(min_rates_2,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,accel,bar,false);
      //--- Loading the obtained values in the indicator buffer    
      IndBuffer[bar]=accel;
      UpSignBuffer[bar]=accel;
      DnSignBuffer[bar]=xaccel;
     }
//--- Main loop of the XMACD indicator coloring
   for(bar=first2; bar<rates_total; bar++)
     {
      int clr=2;
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
