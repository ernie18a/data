//+------------------------------------------------------------------+
//|                                                         XPVT.mq5 |
//|                                     Copyright © 2010, Martingeil | 
//|                                                                  | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Martingeil"
//---- link to the website of the author
#property link ""
#property description "Price and Volume Trend"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used for indicator line
#property indicator_color1  Red
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "PVT"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2  Blue
//---- the indicator 2 line is a dot-dash one
#property indicator_style2  STYLE_DASHDOTDOT
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bullish label of the indicator
#property indicator_label2  "Signal PVT"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
/*enum Smooth_Method - the enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input Smooth_Method XMA_Method=MODE_EMA; //averaging method
input int XLength=5; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double PVTBuffer[],SignBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XMA.GetStartBars(XMA_Method,XLength,XPhase)+1;

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,PVTBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set PVTBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Price and Volume Trend");
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   double dCurrentPrice,dPreviousPrice;
   int first,bar;
   long Vol;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
      if(VolumeType==VOLUME_TICK) PVTBuffer[0]=double(tick_volume[0]);
      else  PVTBuffer[0]=double(volume[0]);
     }

   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      if(VolumeType==VOLUME_TICK) Vol=long(tick_volume[bar]);
      else Vol=long(volume[bar]);

      //---- call of the PriceSeries function to get the input price 'price_'
      dCurrentPrice=PriceSeries(IPC,bar,open,low,high,close);
      dPreviousPrice=PriceSeries(IPC,bar-1,open,low,high,close);

      PVTBuffer[bar]=PVTBuffer[bar-1]+Vol*(dCurrentPrice-dPreviousPrice)/dPreviousPrice;
      SignBuffer[bar]=XMA.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,PVTBuffer[bar],bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
