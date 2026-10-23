//+---------------------------------------------------------------------+
//|                                                            XIBS.mq5 | 
//|                                              Copyright © 2008, Rosh | 
//|                 http://www.investo.ru/forum/viewtopic.php?t=127513/ | 
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, Rosh"
#property link "http://www.investo.ru/forum/viewtopic.php?t=127513/"
#property description "Internal Bar Strength"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used for the indicator line
#property indicator_color1 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Internal Bar Strength"
//+-----------------------------------+
//| Levels parameters                 |
//+-----------------------------------+
#property indicator_level1 60
#property indicator_level2 40
#property indicator_levelcolor Magenta
#property indicator_levelstyle STYLE_DASHDOTDOT
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
enum Applied_price_     // Type of constant
  {
   PRICE_CLOSE_LOW,     // Close-Low
   PRICE_HIGH_CLOSE     // High-Close
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
input Smooth_Method IMA_Method=MODE_SMA; // Smoothing method
input int ILength=12;                    // Smoothing depth                    
input int IPhase=15;                     // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE_LOW;// Applied price
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double XIBS[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| XIBS indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=XMA1.GetStartBars(IMA_Method,ILength,IPhase);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("ILength", ILength);
   XMA1.XMAPhaseCheck("IPhase", IPhase, IMA_Method);

//---- set XIBS[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XIBS,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(IMA_Method);
   StringConcatenate(shortname,"Internal Bar Strength(",Smooth1,", ",ILength,", ",IPhase,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XIBS iteration function                                          | 
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
   double range,dprice,ibs;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(IPC) dprice=close[bar]-low[bar];
      else    dprice=high[bar]-close[bar];

      range=high[bar]-low[bar];

      if(range) ibs=dprice/range;
      else       ibs=0.0;

      XIBS[bar]=100*XMA1.XMASeries(0,prev_calculated,rates_total,IMA_Method,IPhase,ILength,ibs,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
