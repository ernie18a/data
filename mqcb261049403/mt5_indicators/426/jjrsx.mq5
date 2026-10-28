/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                        JJRSX.mq5 | 
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
//---- blue violet color is used as the color of the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "JJRSX"
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
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPLE,         //PRICE_SIMPLE
   PRICE_QUARTER_,       //PRICE_QUARTER
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1_
  };
input int JJMALength=8;  // Depth of smoothing 
input int JJMASmooth = 8;  // Depth of the JJMA smoothing 
input int JJMAPhase = 100; // Parameter of the JJMA smoothing,
                           // that changes within the range -100 ... +100,
// impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE_;//Price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Horizontal shift of the indicator in bars
//---+
//---- indicator buffers
double JJRSX[];
//+------------------------------------------------------------------+
// iPriceSeries function description                                 |
// CJurX class description                                           |
// CJJMA class description                                           |
//+------------------------------------------------------------------+  
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| JJRSX indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set dynamic array as indicator buffer
   SetIndexBuffer(0,JJRSX,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,32);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JJRSX");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JJRSX( Length = ",JJMALength,
                     ", Smooth = ",JJMASmooth,", Phase = ",JJMAPhase,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Length", JJMALength);
   JMA.JJMALengthCheck("Smooth", JJMASmooth);
   JMA.JJMAPhaseCheck ("Phase",  JJMAPhase );
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| JJRSX iteration function                                         | 
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
   if(rates_total<32) return(0);

//---- Declaration of variables with a floating point  
   double dprice_,udprice_,up_jrsx,dn_jrsx,jrsx,jjrsx;
//---- Declaration of integer variables and getting calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=1; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of variables of the JurX class from the JurXSeries_Cls.mqh file
   static CJurX Jur1,Jur2;
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   static CJJMA JMA;

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- Call of the PriceSeries function to get incrementation of the input price dprice_
      dprice_=PriceSeries(IPC,bar,open,low,high,close)
              -PriceSeries(IPC,bar-1,open,low,high,close);

      udprice_=MathAbs(dprice_);

      //---- Two calls of the JurXSeries function.  
      up_jrsx = Jur1.JurXSeries(1, prev_calculated, rates_total, 0, JJMALength,  dprice_, bar, false);
      dn_jrsx = Jur2.JurXSeries(1, prev_calculated, rates_total, 0, JJMALength, udprice_, bar, false);

      //---- Preventing zero divide on empty values
      if(dn_jrsx==0) jrsx=EMPTY_VALUE;
      else
        {
         jrsx=up_jrsx/dn_jrsx;
         //---- Upper and lower limits of the indicator 
         if(jrsx > +1)jrsx = +1;
         if(jrsx < -1)jrsx = -1;
        }

      //---- One call of the JJMASeries function
      jjrsx=JMA.JJMASeries(1,prev_calculated,rates_total,0,JJMAPhase,JJMASmooth,jrsx,bar,false);

      //---- Loading the obtained value in the indicator buffer
      JJRSX[bar]=jjrsx;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
