//+------------------------------------------------------------------+
//|                                                  Velocity_v2.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2006, TrendLaboratory"
//---- link to the website of the author
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property description ""

//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1   DRAW_HISTOGRAM
//---- SlateGray is used for the color of the indicator line
#property indicator_color1  clrSlateGray
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the line width of the indicator 1 is 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Velocity_v2"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used as the color of the indicator line
#property indicator_color2  clrMagenta
//---- Indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the bullish label of the indicator
#property indicator_label2  "Signal Velocity_v2"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of variables of the classes CMomentum and CAMA from the file SmoothAlgorithms.mqh
CMomentum Mom;
CXMA XMA1,XMA2,XMA3,XMA4;
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
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
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_ //Type of constant
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
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint MomPeriod=1; //period of Momentum 

input Smooth_Method VelocityMethod=MODE_EMA; //the method of fast averaging
input uint VelocityLength=8; //the depth of fast averaging          
input int VelocityPhase=15; //the parameter of fast averaging
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method SignMethod=MODE_EMA; //Smoothing method
input uint SignLength=5; //Smoothing depth                    
input int SignPhase=15; //Smoothing parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Applied_price_ IPC=PRICE_CLOSE;//price constant
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// will be used as indicator buffers
double VelBuffer[],SignBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_1,min_rates_2,min_rates_3,min_rates_4,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=int(MomPeriod);
   int res=XMA1.GetStartBars(VelocityMethod,VelocityLength,VelocityPhase);
   min_rates_2=min_rates_1+res;
   min_rates_3=min_rates_2+res;
   min_rates_4=min_rates_3+res;
   min_rates_total=min_rates_4+XMA1.GetStartBars(SignMethod,SignLength,SignPhase);;

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,VelBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Set the VelBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Velocity_v2");
//--- Determining the accuracy of displaying the indicator values
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
   int first;

//---- Calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting number for calculation of all bars
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars

//---- main cycle of calculation of the indicator
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double price=PriceSeries(IPC,bar,open,low,high,close);
      double mom=Mom.MomentumSeries(0,prev_calculated,rates_total,MomPeriod,price,bar,false);     
      double xmom=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,VelocityMethod,VelocityPhase,VelocityLength,mom,bar,false);
      double xxmom=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,VelocityMethod,VelocityPhase,VelocityLength,xmom,bar,false);
      double xxxmom=XMA3.XMASeries(min_rates_3,prev_calculated,rates_total,VelocityMethod,VelocityPhase,VelocityLength,xxmom,bar,false);
      VelBuffer[bar]=xxxmom;
      SignBuffer[bar]=XMA4.XMASeries(min_rates_4,prev_calculated,rates_total,SignMethod,SignPhase,SignLength,xxxmom,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
