/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh version >= 3.01!!!
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                        AT^CF.mq5 |
//|                               Copyright © 2011, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- 4 buffers are used for calculation and drawing of the indicator
#property indicator_buffers 4
//---- only 4 plots are used
#property indicator_plots   4
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
//---- the following colors are used for the indicators lines
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Magenta
#property indicator_color4  Lime
//---- indicator lines are continuous curves
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID
//---- indicators lines width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
//---- display of the indicators labels
#property indicator_label1  "FATL"
#property indicator_label2  "SATL"
#property indicator_label3  "RFTL"
#property indicator_label4  "RSTL"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // PRICE_CLOSE
   PRICE_OPEN_,          // PRICE_OPEN
   PRICE_HIGH_,          // PRICE_HIGH
   PRICE_LOW_,           // PRICE_LOW
   PRICE_MEDIAN_,        // PRICE_MEDIAN
   PRICE_TYPICAL_,       // PRICE_TYPICAL
   PRICE_WEIGHTED_,      // PRICE_WEIGHTED
   PRICE_SIMPLE,         // PRICE_SIMPLE
   PRICE_QUARTER_,       // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   // PRICE_TRENDFOLLOW1_
  };

input Applied_price_ IPC=PRICE_CLOSE_;//Price constant
/* used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input int FATLShift=0; // Horizontal shift of the FATL indicator in bars
input int SATLShift=0; // Horizontal shift of the SATL indicator in bars
input int RFTLShift=0; // Horizontal shift of the RFTL indicator in bars
input int RSTLShift=0; // Horizontal shift of the RSTL indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double FATLBuffer[],SATLBuffer[],RFTLBuffer[],RSTLBuffer[];

int start;
//+------------------------------------------------------------------+
// Description of the iPriceSeries() function                        |
// CFATL, CSATL, RFTL and CRSTL classes description                  |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables
   start=99;
//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,FATLBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SATLBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,RFTLBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,RSTLBuffer,INDICATOR_DATA);
//---- horizontal shift of the indicators
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
   PlotIndexSetInteger(1,PLOT_SHIFT,SATLShift);
   PlotIndexSetInteger(2,PLOT_SHIFT,RFTLShift);
   PlotIndexSetInteger(3,PLOT_SHIFT,RSTLShift);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"FATL");
   PlotIndexSetString(1,PLOT_LABEL,"SATL");
   PlotIndexSetString(2,PLOT_LABEL,"RFTL");
   PlotIndexSetString(3,PLOT_LABEL,"RSTL");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"AT^CF");
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<start) return(0);

//---- declarations of local variables 
   int first,bar;
   double price;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of CFATL, CSATL CRFTL and CRSTL classes variables from the SmoothAlgorithms.mqh file
   static CFATL FATL;
   static CSATL SATL;
   static CRFTL RFTL;
   static CRSTL RSTL;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- getting the input price
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- LOAD OBTAINED DIGITAL FILTERS VALUES INTO THE INDICATOR BUFFERS
      FATLBuffer[bar]=FATL.FATLSeries(0,prev_calculated,rates_total,price,bar,false);
      SATLBuffer[bar]=SATL.SATLSeries(0,prev_calculated,rates_total,price,bar,false);
      RFTLBuffer[bar]=RFTL.RFTLSeries(0,prev_calculated,rates_total,price,bar,false);
      RSTLBuffer[bar]=RSTL.RSTLSeries(0,prev_calculated,rates_total,price,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
