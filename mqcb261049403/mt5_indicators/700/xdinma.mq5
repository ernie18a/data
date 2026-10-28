//+------------------------------------------------------------------+
//|                                                       XdinMA.mq5 | 
//|                                       Copyright © 2011,   dimeon | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| in the directory: MetaTrader\MQL5\Include                        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, dimeon"
#property link ""
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- dark orange color is used for the indicator line
#property indicator_color1 DarkOrange
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XdinMA"
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
input Smooth_Method MA_Method1=MODE_SMA; // Smoothing method
input int Length_main=10;                // main smoothing depth
input int Length_plus=20;                // plus smoothing depth
input int PhaseX=15;                     // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;    // Applied price
input int Shift=0;                       // Horizontal shift of the indicator in bars
input int PriceShift=0;                  // Vertical shift of the indicator in points
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double XdinMA[];
//---- declaration of the average vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+   
//| XdinMA indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   int StartBars1=XMA1.GetStartBars(MA_Method1, Length_main, PhaseX);
   int StartBars2=XMA2.GetStartBars(MA_Method1, Length_plus, PhaseX);
   min_rates_total=MathMax(StartBars1,StartBars2);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length_main", Length_main);
   XMA2.XMALengthCheck("Length_plus", Length_plus);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("PhaseX",PhaseX,MA_Method1);

//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set XdinMA[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XdinMA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"XdinMA(",Length_main,", ",Length_plus,", ",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XdinMA iteration function                                        | 
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
   double price_,ma_main,ma_plus;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the XMASeries method function
      //---- the 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      ma_main = XMA1.XMASeries(0, prev_calculated, rates_total, MA_Method1, PhaseX, Length_main, price_, bar, false);
      ma_plus = XMA2.XMASeries(0, prev_calculated, rates_total, MA_Method1, PhaseX, Length_plus, price_, bar, false);
      //----       
      XdinMA[bar]=ma_main*2-ma_plus+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
