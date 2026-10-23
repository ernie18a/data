/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                        J2JMA.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
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
//---- Magenta color is used for indicator line
#property indicator_color1 Magenta 
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "J2JMA"
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
input double Length1 = 5; // Depth of the first smoothing 
input double Length2 = 5; // Depth of the second smoothing                    
input double Phase1= 100; // First smoothing parameter,
                          //that changes within the range -100 ... +100
                          //impacts the transitional process quality;
input double Phase2=100;  // Second smoothing parameter,
                          //that changes within the range -100 ... +100
                          //impacts the transitional process quality;
input Applied_price_ IPC=PRICE_CLOSE_;// Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;      // Horizontal shift of the indicator in bars
input int PriceShift=0; // Vertical shift of the indicator in points

//---- indicator buffers
double J2JMA[];

double dPriceShift;
//+------------------------------------------------------------------+
// Description of the CJJMA class                                    |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| J2JMA indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,J2JMA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,61);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"J2JMA");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"J2JMA( Length1 = ",Length1,", Length2 = ",Length2,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Length1", (int)Length1);
   JMA.JJMALengthCheck("Length2", (int)Length2);
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMAPhaseCheck("Phase1", (int)Phase1);
   JMA.JJMAPhaseCheck("Phase2", (int)Phase2);
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| J2JMA iteration function                                         | 
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
   if(rates_total<60) return(0);

//---- declaration of variables with a floating point  
   double price_,j1jma,j2jma;
//---- declaration of integer variables and getting calculated bars
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the variables of the CJJMA class from the SmoothAlgorithms.mqh file
   static CJJMA JMA1,JMA2;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the JJMASeries function. 
      //---- Phase and Length parameters are not changed at every bar (Din = 0)
      //---- The 'begin' parameter is increased by 30 in the second call, as it is the second JMA smoothing.  
      j1jma = JMA1.JJMASeries( 0, prev_calculated, rates_total, 0, Phase1, Length1, price_, bar, false);
      j2jma = JMA2.JJMASeries(30, prev_calculated, rates_total, 0, Phase2, Length2,  j1jma, bar, false);
      //----       
      J2JMA[bar]=j2jma+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+