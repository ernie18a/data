/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                         JCCX.mq5 | 
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
//---- dodger blue color is used as the color of the indicator line
#property indicator_color1 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying labels of the indicator
#property indicator_label1  "JCCX"
//---- parameters of horizontal levels of the indicator
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor DeepPink
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPLE,         //PRICE_SIMPLE
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1_
  };
input int JMALength=8;  // Depth of the input price JMA smoothing
input int JMAPhase=100; // JJMA smoothing parameter,
                        //that changes within the range -100 ... +100
                        //impacts the transitional process quality;
input int JurXLength=8; // Depth of the indicator JurX smoothing

input Applied_price_ IPC=PRICE_CLOSE_; // Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;      // Horizontal shift of the indicator in bars
//---- indicator buffers
double JCCX[];
//+--------------------------------------------------------------------------+
// Description of the CJJMA and CJurX classes and the PriceSeries() function |
//+--------------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| JCCX indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,JCCX,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,30);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JCCX");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JCCX( JMALength = ",JMALength,
                     ", JMAPhase = ",JMAPhase,", JurXLength = ",JurXLength,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- declaration of a variable of the CJMA class from the SmoothAlgorithms.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("JMALength",  JMALength );
   JMA.JJMALengthCheck("JurXLength", JurXLength);
   JMA.JJMAPhaseCheck ("JMAPhase",   JMAPhase  );
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| JCCX iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
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
   if(rates_total<0) return(0);

//---- Declaration of variables with a floating point  
   double price_,jma,up_cci,dn_cci,up_jccx,dn_jccx,jccx;
//---- declaration of integer variables
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0;                    // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of variables of the CJurX class from the SmoothAlgorithms.mqh file
   static CJurX Jur1,Jur2;
//---- declaration of a variable of the CJMA class from the SmoothAlgorithms.mqh file
   static CJJMA JMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- one call of the JJMASeries function to get the JMA average
      jma=JMA.JJMASeries(0,prev_calculated,rates_total,0,JMAPhase,JMALength,price_,bar,false);

      //---- determine the deviation of a price from the average value
      up_cci = price_ - jma;
      dn_cci = MathAbs(up_cci);

      //---- two calls of the JurXSeries function.  
      up_jccx = Jur1.JurXSeries(30, prev_calculated, rates_total, 0, JurXLength, up_cci, bar, false);
      dn_jccx = Jur2.JurXSeries(30, prev_calculated, rates_total, 0, JurXLength, dn_cci, bar, false);

      //---- preventing zero divide on empty values
      if(dn_jccx==0) jccx=EMPTY_VALUE;
      else
        {
         jccx=up_jccx/dn_jccx;

         //---- upper and lower limits of the indicator 
         if(jccx > +1)jccx = +1;
         if(jccx < -1)jccx = -1;
        }

      //---- loading the obtained value in the indicator buffer
      JCCX[bar]=jccx;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+