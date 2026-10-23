/*
* Place the SmoothAlgorithms.mqh file
* to the terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+
//|                                                    JMomentum.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
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
//---- use maroon color for the indicator line
#property indicator_color1 Maroon
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "JMomentum"
//---- parameters of the indicator horizontal levels
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor Magenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
input int SLength=8;                   // Smoothing depth 
input int JLength=8;                   // Momentum indicator JMA smoothing depth                  
input int JPhase=100;                  // JMA smoothing parameter,
                                       //that changes within the range -100 ... +100
//impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE;  // Price constant
/*used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;                     // Horizontal shift of the indicator in bars
//---+
//---- indicator buffers
double JMomentum[];
//+------------------------------------------------------------------+
// iPriceSeries function description                                 |
// iPriceSeriesAlert function description                            |
// CMomentum class description                                       |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+   
//| JMomentum indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,JMomentum,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JMomentum");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JMomentum( Length = ",SLength,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- declaration of the CMomentum class variable from the SmoothAlgorithms.mqh file
   CMomentum Mom;
//---- declaration of the CJJMA class variable from the SmoothAlgorithms.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   Mom.MALengthCheck("Length", SLength);
   JMA.JJMALengthCheck("JLength", JLength);
   JMA.JJMAPhaseCheck("JPhase", JPhase);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| JMomentum iteration function                                     | 
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
   if(rates_total<SLength+31) return(0);

//---- declaration of variables with a floating point  
   double price,momentum,jmomentum;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated==0)        // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CMomentum and CJJMA classes variables from the SmoothAlgorithms.mqh file
   static CMomentum Mom;
   static CJJMA JMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get incrementation of the input price dprice_
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the MomentumSeries function.  
      momentum=Mom.MomentumSeries(0,prev_calculated,rates_total,SLength,price,bar,false);

      //---- one call of the JJMASeries function. 
      //---- Phase and Length parameters are not changed at every bar (Din = 0) 
      jmomentum=JMA.JJMASeries(SLength+1,prev_calculated,rates_total,0,JPhase,JLength,momentum,bar,false);

      //---- loading the obtained value in the indicator buffer
      JMomentum[bar]=jmomentum;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
