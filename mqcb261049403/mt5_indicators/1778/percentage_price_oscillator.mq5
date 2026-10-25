//+------------------------------------------------------------------+
//|                                  Percentage_Price_Oscillator.mq5 |
//|                                       Copyright © 2007 Tom Balfe | 
//|                                         redcarsarasota@yahoo.com | 
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2007 Tom Balfe"
//---- link to the website of the author
#property link "redcarsarasota@yahoo.com"

#property description "This is a momentum indicator."
#property description "Signal line is EMA of PPO."
#property description "Follows formula: PPO=(FastEMA-SlowEMA)/SlowEMA"

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
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Red is used for the line indicator color
#property indicator_color1  clrRed
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "PPO"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- DodgerBlue is used for the line indicator color
#property indicator_color2  clrDodgerBlue
//---- Indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the bullish label of the indicator
#property indicator_label2  "Signal PPO"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3;
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
input Smooth_Method FastMethod=MODE_EMA; //method of fast averaging
input uint FastLength=12; //depth of the fast averaging          
input int FastPhase=15; //Fast averaging parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method SlowMethod=MODE_EMA; //method of slow averaging
input uint SlowLength=26; //depth of slow averaging                 
input int SlowPhase=15; //Slow averaging parameter
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method SignMethod=MODE_EMA; //Smoothing method
input uint SignLength=9; //Smoothing depth                    
input int SignPhase=15; //Smoothing parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Applied_price_ IPC=PRICE_CLOSE;//price constant
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that  
// will be used as indicator buffers
double PPOBuffer[],SignBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=int(MathMax(XMA1.GetStartBars(FastMethod,FastLength,FastPhase),XMA1.GetStartBars(SlowMethod,SlowLength,SlowPhase)));
   min_rates_total=min_rates_+XMA1.GetStartBars(SignMethod,SignLength,SignPhase);

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,PPOBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Set the PPOBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Percentage_Price_Oscillator");
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

      //---- Calling the PriceSeries function to get the input price price_
      double price=PriceSeries(IPC,bar,open,low,high,close);
      
      double fast=XMA1.XMASeries(0,prev_calculated,rates_total,FastMethod,FastPhase,FastLength,price,bar,false);
      double slow=XMA2.XMASeries(0,prev_calculated,rates_total,SlowMethod,SlowPhase,SlowLength,price,bar,false);
      if(!slow) slow=1;
      double ppo=(fast-slow)/slow;

      PPOBuffer[bar]=ppo;
      SignBuffer[bar]=XMA3.XMASeries(min_rates_,prev_calculated,rates_total,SignMethod,SignPhase,SignLength,ppo,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
