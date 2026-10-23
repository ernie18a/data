/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                     T3Taotra.mq5 |
//|                   MQL5 jjrsx: Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 6
#property indicator_buffers 6 
//---- 6 plots are used 
#property indicator_plots   6
//---- indicator colors
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Magenta
#property indicator_color4 Aqua
#property indicator_color5 LimeGreen
#property indicator_color6 Blue
//---- drawing the indicator in the form of lines
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
#property indicator_type6 DRAW_LINE
//---- indicator lines are continuous curves
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
//---- width of the indicator lines is equal to 1
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
//---- displaying the indicator line label
#property indicator_label1  "T3Taotra" 
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
input int T3_Period_1 = 3; // Indicator period 1
input int T3_Period_2 = 5; // Indicator period 2
input int T3_Period_3 = 8; // Indicator period 3
input int T3_Period_4 = 12;// Indicator period 4
input int T3_Period_5 = 21;// Indicator period 5
input int T3_Period_6 = 34;// Indicator period 6
input int Smooth_Curvature=100;
input  Applied_price_  IPC=PRICE_CLOSE_;// Price constant
/* used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift1 = 0;  // Shift of the indicator 1 along the timeline 
input int Shift2 = 0;  // Shift of the indicator 2 along the timeline
input int Shift3 = 0;  // Shift of the indicator 3 along the timeline
input int Shift4 = 0;  // Shift of the indicator 4 along the timeline
input int Shift5 = 0;  // Shift of the indicator 5 along the timeline
input int Shift6 = 0;  // Shift of the indicator 6 along the timeline
//+-----------------------------------+
//---- indicator buffers
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
double Ind_Buffer5[];
double Ind_Buffer6[];
//+------------------------------------------------------------------+
// iPriceSeries() function description                               |
// iPriceSeriesAlert() function description                          |
// CT3 class description                                             |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| T3Taotra initialization function                                 |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set dynamic array as indicator buffer
   SetIndexBuffer(0,Ind_Buffer1,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift1);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as indicator buffer
   SetIndexBuffer(1,Ind_Buffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift2);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as indicator buffer
   SetIndexBuffer(2,Ind_Buffer3,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift3);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as indicator buffer
   SetIndexBuffer(3,Ind_Buffer4,INDICATOR_DATA);
//---- shifting the indicator 4 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift4);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as indicator buffer
   SetIndexBuffer(4,Ind_Buffer5,INDICATOR_DATA);
//---- shifting the indicator 5 horizontally
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift5);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as indicator buffer
   SetIndexBuffer(5,Ind_Buffer6,INDICATOR_DATA);
//---- shifting the indicator 6 horizontally
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift6);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,0);
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate
   (shortname,"T3Taotra( ",T3_Period_1,", ",T3_Period_2,", ",T3_Period_3,
    ", ",T3_Period_4,", ",T3_Period_5,", ",T3_Period_6," )");
//---- creating name for displaying if separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- declaration of the CT3 class variable from the T3Series_Cls.mqh file
   CT3 T3_;
//---- setting up alerts for unacceptable values of external variables
   T3_.MALengthCheck("T3_Period_1", T3_Period_1);
   T3_.MALengthCheck("T3_Period_2", T3_Period_2);
   T3_.MALengthCheck("T3_Period_3", T3_Period_3);
   T3_.MALengthCheck("T3_Period_4", T3_Period_4);
   T3_.MALengthCheck("T3_Period_5", T3_Period_5);
   T3_.MALengthCheck("T3_Period_6", T3_Period_6);
//---- initialization end
  }
//+------------------------------------------------------------------+
//| T3.Taotra iteration function                                     |
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
   if(rates_total<0)return(0);

//---- declaration of variables with a floating point
   double series;

//---- declaration of integer variables
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CT3 class variables array from the T3Series_Cls.mqh file
   static CT3 T3_[6];

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get the Series input price
      series=PriceSeries(IPC,bar,open,low,high,close);

      //---- six parallel calls of the T3Series function.
      //---- the Length parameter is not changed at every bar (Din = 0).  
      Ind_Buffer1[bar] = T3_[0].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_1, series,  bar, false);
      Ind_Buffer2[bar] = T3_[1].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_2, series,  bar, false);
      Ind_Buffer3[bar] = T3_[2].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_3, series,  bar, false);
      Ind_Buffer4[bar] = T3_[3].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_4, series,  bar, false);
      Ind_Buffer5[bar] = T3_[4].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_5, series,  bar, false);
      Ind_Buffer6[bar] = T3_[5].T3Series(0, prev_calculated, rates_total, 0, Smooth_Curvature, T3_Period_6, series,  bar, false);
     }
//---- end of indicator values calculation 
   return(rates_total);
  }
//+------------------------------------------------------------------+
