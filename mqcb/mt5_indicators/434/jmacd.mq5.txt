/*
 * Place the SmoothAlgorithms.mqh file
 * to the terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                        JMACD.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_HISTOGRAM
//---- blue violet color is used as the color of the diagrams of the MACD indicator
#property indicator_color1 BlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "JMACD"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- magenta color is used as the color of the signal line
#property indicator_color2 Magenta
//---- the indicator line is a dash-dotted curve
#property indicator_style2 STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width2 2
//---- displaying the signal line label
#property indicator_label2  "Signal Line"
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
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  //PRICE_TRENDFOLLOW1_
  };
input int Fast_JMA = 12; //Period of the fast MA
input int Slow_JMA = 26; //Depth of the SMMA smoothing
input int Signal_JMA= 9; //Signal line period 
input int Phase_=100;    //Smoothing parameter
                         //that changes within the range -100 ... +100
//impacts the transitional process quality;
input Applied_price_ AppliedPrice=PRICE_CLOSE_; //Price constant
/* used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+-----------------------------------+
//---- indicator buffer
double MACDBuffer[],SignBuffer[];

int start=60,macd_start=30;
//+------------------------------------------------------------------+
// iPriceSeries function description                                 |
// CJJMA class description                                           |
//+------------------------------------------------------------------+  
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+    
//| JMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set MACDBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,macd_start+1);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JMACD");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set SignBuffer dynamic array as indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start+1);
//---- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Signal JMA");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initialization of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"JMACD( ",Fast_JMA,", ",Slow_JMA,", ",Signal_JMA," )");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- declaration of a CJJMA class variable from the JJMASeries_Cls.mqh file
   CJJMA JMA;
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMALengthCheck("Fast_JMA", Fast_JMA);
   JMA.JJMALengthCheck("Slow_JMA", Slow_JMA);
   JMA.JJMALengthCheck("Slow_JMA", Signal_JMA);
//---- setting up alerts for unacceptable values of external variables
   JMA.JJMAPhaseCheck("Phase_",Phase_);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking the number of bars to be enough for the calculation
   if(rates_total<start) return(0);

//---- Declaration of integer variables
   int first,bar;
//---- Declaration of variables with a floating point  
   double price_,fast_jma,slow_jma,jmacd,sign_jma;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting index for calculation of all bars

      //---- Initialization of the indicator buffers at bars that are not calculated
      for(bar = 0; bar <= macd_start; bar++) MACDBuffer[bar] = 0.0;
      for(bar = 0; bar <= start;      bar++) SignBuffer[bar] = 0.0;
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of variables of the JJMA class from the JJMASeries_Cls.mqh file
   static CJJMA JMA1,JMA2,JMA3;

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;

      fast_jma = JMA1.JJMASeries(0, prev_calculated, rates_total, 0, Phase_, Fast_JMA, price_, bar, false);
      slow_jma = JMA2.JJMASeries(0, prev_calculated, rates_total, 0, Phase_, Slow_JMA, price_, bar, false);

      jmacd=fast_jma-slow_jma;

      sign_jma=JMA3.JJMASeries(macd_start,prev_calculated,rates_total,0,Phase_,Signal_JMA,jmacd,bar,false);

      //---- Loading the obtained values to the indicator buffers      
      MACDBuffer[bar] = jmacd;
      SignBuffer[bar] = sign_jma;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
