/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                         JJMA.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
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
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color1 Red
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "JJMA"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1_
  };
input int JMALength_=7;  //Depth of smoothing                   
input int JMAPhase_=100; //Smoothing parameter
                         //that changes within the range -100 ... +100,
                         //impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE_;//Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int JMAShift=0;      //Horizontal shift of the indicator in bars
input int JMAPriceShift=0; //Vertical shift of the indicator in points
//+-----------------------------------+
//---- indicator buffer
double J1JMA[];

double dPriceShift;
//+------------------------------------------------------------------+
// iPriceSeries() function description                               |
// iPriceSeriesAlert() function description                          |
// Description of the CJJMA class                                    |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| JJMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,J1JMA,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,JMAShift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,31);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JJMA");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JJMA( Length_ = ",JMALength_,", Phase_ = ",JMAPhase_,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Length_", JMALength_);
   JMA.JJMAPhaseCheck("Phase_", JMAPhase_);
//---- initialization of the vertical shift
   dPriceShift=_Point*JMAPriceShift;
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| JJMA iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<31)return(0);

//---- declaration of integer variables
   int first,bar;
//---- declaration of variables with a floating point  
   double series,j1jma;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of a variable of the JJMA class from the JJMASeries_Cls.mqh file
   static CJJMA JMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- calling the PriceSeries function to get the 'Series' input price
      series=PriceSeries(IPC,bar,open,low,high,close);

      //---- one call of the JJMASeries method. 
      //---- Phase and Length parameters are not changed at every bar (Din = 0) 
      j1jma=JMA.JJMASeries(0,prev_calculated,rates_total,0,JMAPhase_,JMALength_,series,bar,false);
      //----       
      J1JMA[bar]=j1jma+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+