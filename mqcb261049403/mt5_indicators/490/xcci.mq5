/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                         XCCI.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Commodity Chanel Index"
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
//---- medium orchid color is used for the indicator line
#property indicator_color1 MediumOrchid
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XCCI"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1       -100.0
#property indicator_level2        100.0
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_DASHDOTDOT

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMAD;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
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
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
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
input Smooth_Method DSmoothMethod=MODE_T3; // Price smoothing method
input int DPeriod=15;                      // Moving average period
input int DPhase=15;                       // Moving average smoothing parameter
                                           // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                                           // for VIDIA it is a CMO period, for AMA it is a slow average period

input int MPeriod=15;                      // Average deviation period

input Applied_price_ IPC=PRICE_TYPICAL;    // Price constant
/* , used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input int Shift=0;                         // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double XCCI[];

//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsD,StartBarsM;
//+------------------------------------------------------------------+   
//| XCCI indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBarsD=XMAD.GetStartBars(DSmoothMethod,DPeriod,DPhase);
   StartBarsM=MathMax(StartBarsD,MPeriod);
   StartBars=StartBarsM;

//---- setting up alerts for unacceptable values of external variables
   XMAD.XMALengthCheck("DPeriod", DPeriod);
   XMAD.XMALengthCheck("MPeriod", MPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMAD.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XCCI,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XCCI");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,SmoothD;
   SmoothD=XMAD.GetString_MA_Method(DSmoothMethod);
   StringConcatenate(shortname,"Commodity Chanel Index(",string(DPeriod),",",string(MPeriod),",",SmoothD,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XCCI iteration function                                          | 
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
   double price_,xma,Sum,D,M;
//---- declaration of integer variables
   int first,bar;
//---- declaration of static variables
   static double MPeriod_;

//---- calculate the first starting index for the loop of bars recalculation and initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      MPeriod_=MPeriod/0.015;
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- preliminary initialization of the indicator buffer using an empty value
      XCCI[bar]=EMPTY_VALUE;

      //---- one call of the XMASeries function 
      xma=XMAD.XMASeries(0,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,price_,bar,false);
      M=price_-xma;

      //---- avoid performing further calculations on the part of history where there is not enough data
      if(bar<StartBarsM) continue;

      //---- calculation of the price average deviation
      Sum=0.0;
      for(int j=0;j<MPeriod;j++) Sum+=MathAbs(PriceSeries(IPC,bar-j,open,low,high,close)-xma);
      D=Sum/MPeriod_;

      //---- indicator buffer initialization
      if(D!=0.0) XCCI[bar]=M/D;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
