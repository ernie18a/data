/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 *
 * This indicator is based on the algorithm of smoothing of the indicator 
 * JRSX. The final result of this algorithm is slightly similar to 
 * the double JMA smoothing, but it's less perfect because of its simplicity.
 */

//+------------------------------------------------------------------+ 
//|                                                        JJurX.mq4 | 
//|                           Copyright © 2010,     Nikolay Kositsin | 
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
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- use gold color for the indicator line
#property indicator_color1 Gold
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "JJurX"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ //Type of price constant
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
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1
  };
input int JurX_Length  = 5; //Depth of the JurX smoothing 
input int JJMA_Length  = 4; //Depth of the JJMA smoothing 
input int  JJMA_Phase=-100; //Parameter of the first smoothing,
                            //that changes within the range -100 ... +100
                            //impacts the transitional process quality;
input  Applied_price_  IPC=PRICE_CLOSE_; //Price constant
/* used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Horizontal shift of the indicator in bars
input int PriceShift = 0; // Vertical shift of the average in points
//+-----------------------------------+
//---- indicator buffers
double Ind_Buffer[];
//----
double dPriceShift;
//+------------------------------------------------------------------+
// iPriceSeries() function description                               |
// iPriceSeriesAlert() function description                          |
// JJMA class description                                            |
// CJurX class description                                           |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| JJurX indicator initialization function                          | 
//+------------------------------------------------------------------+   
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Ind_Buffer,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,30);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JJurX");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate
   (shortname,"JJurX( JurX_Length = ",JurX_Length,
    ", JJMA_Length = ",JJMA_Length,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("JJMA_Length", JJMA_Length);
   JMA.JJMALengthCheck("JurX_Length", JurX_Length);
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMAPhaseCheck("JJMA_Phase",JJMA_Phase);
//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- initialization end
  }
//+------------------------------------------------------------------+
//| JJurX iteration function                                         | 
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
   if(rates_total<30)return(0);

//---- declaration of integer variables
   int first,bar;

//---- declaration of variables with a floating point  
   double series,jurx,jjurx;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of a variable of the JurX class from the JurXSeries_Cls.mqh file
   static CJurX Jur;

//---- declaration of a variable of the JJMA class from the JJMASeries_Cls.mqh file
   static CJJMA JMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get the Series input price
      series=PriceSeries(IPC,bar,open,low,high,close);

      //---- one call of the JurXSeries function 
      //---- the Length parameter is not changed at every bar (Din = 0).  
      jurx=Jur.JurXSeries(0,prev_calculated,rates_total,0,JurX_Length,series,bar,false);

      //---- one call of the JJMASeries function
      //---- Phase and Length parameters are not changed at every bar (Din = 0).  
      jjurx=JMA.JJMASeries(0,prev_calculated,rates_total,0,JJMA_Phase,JJMA_Length,jurx,bar,false);

      //---- initialization of a cell of the indicator buffer with the obtained value       
      Ind_Buffer[bar]=jjurx+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+