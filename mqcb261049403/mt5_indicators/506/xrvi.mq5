/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                         XRVI.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+---------------------------------------+
//|  Indicator XRVI drawing parameters    |
//+---------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1 Red
//---- the indicator line is a dot-dash one
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XRVI"

//+---------------------------------------+
//|  Signal line drawing parameter        |
//+---------------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color2 BlueViolet
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Signal line"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,//Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method RviMethod=MODE_JurX; //First smoothing averaging method 
input int RviPeriod=10; //First smoothing depth                    
input int RviPhase=15; //First smoothing parameter
                       //for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                       // for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method SignMethod=MODE_JurX; //Second smoothing averaging method 
input int SignPeriod= 5; //Second smoothing depth 
input int SignPhase=15;  //Second smoothing parameter
                         //for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                         // for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;//Price constant
/* , used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Horizontal shift of the indicator in bars
input int PriceShift=0; // Vertical shift of the indicator in points
//+-----------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double XRVI[],SIGN[];

//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| XRVI indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(RviMethod, RviPeriod, RviPhase);
   StartBars2=XMA2.GetStartBars(SignMethod, SignPeriod, SignPhase);
   StartBars=StartBars1+StartBars2;
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("RviPeriod", RviPeriod);
   XMA2.XMALengthCheck("SignPeriod", SignPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("RviPhase", RviPhase, RviMethod);
   XMA2.XMAPhaseCheck("SignPhase", SignPhase, SignMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XRVI,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SIGN,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(RviMethod);
   string Smooth2=XMA1.GetString_MA_Method(SignMethod);
   StringConcatenate(shortname,"XRVI(",RviPeriod,", ",SignPeriod,", ",Smooth1,", ",Smooth2,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XRVI iteration function                                          | 
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
   if(rates_total<StartBars) return(0);

//---- declaration of variables with a floating point  
   double rvi,xrvi,signal;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- RVI calculation
      if(high[bar]-low[bar]!=0) rvi=(close[bar]-open[bar])/(high[bar]-low[bar]);
      else rvi=0.0;

      //---- two calls of the XMASeries function. 
      //---- the 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      xrvi=XMA1.XMASeries(0,prev_calculated,rates_total,RviMethod,RviPhase,RviPeriod,rvi,bar,false);
      signal=XMA2.XMASeries(StartBars1,prev_calculated,rates_total,SignMethod,SignPhase,SignPeriod,xrvi,bar,false);
      //----       
      XRVI[bar]=xrvi;
      SIGN[bar]=signal;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
