/*
 * For the indicator to work, place the files
 * SmoothAlgorithms.mqh and 
 * IndicatorsAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                      XCCI_BB.mq5 | 
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
#property indicator_buffers 6 
//---- six plots are used
#property indicator_plots   6
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
//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color2  Blue
#property indicator_color3  Red
#property indicator_color4  Gray
#property indicator_color5  Red
#property indicator_color6  Blue
//---- Bollinger Bands are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
//---- display of Bollinger Bands labels
#property indicator_label2  "+2Sigma"
#property indicator_label3  "+Sigma"
#property indicator_label4  "Middle"
#property indicator_label5  "-Sigma"
#property indicator_label6  "-2Sigma"

//+------------------------------------------------+
// Description of smoothing classes and indicators |
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh>
#include <IndicatorsAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMAD;
//---- declaration of variables of the CBBands class 
CBBands BBands;
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
   PRICE_SIMPLE_,         //Simple Price (OC/2)
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

input int BBPeriod=100;                    // The period for Bollinger bands
input double BBDeviation1 = 1.6;           // Big deviation
input double BBDeviation2 = 1.0;           // Small deviation

input int Shift=0;                         // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double XCCI[];

//---- declaration of dynamic arrays that further 
//---- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];

//---- declaration of the Bollinger Bands proportion variable
double quotient;

//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsD,StartBarsM;
//+------------------------------------------------------------------+   
//| XCCI indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBarsD=XMAD.GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   StartBarsM=MathMax(StartBarsD,MPeriod);
   StartBars=StartBarsM+BBPeriod;

//---- initialization of the Bollinger Bands proportion variable
   quotient=BBDeviation2/BBDeviation1;

//---- setting up alerts for unacceptable values of external variables
   XMAD.XMALengthCheck("DPeriod", DPeriod);
   XMAD.XMALengthCheck("MPeriod", MPeriod);
   XMAD.XMALengthCheck("BBPeriod", BBPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMAD.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XCCI,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XCCI");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
//---- create labels to display in Data Window
   PlotIndexSetString(1,PLOT_LABEL,"+2Sigma");
   PlotIndexSetString(2,PLOT_LABEL,"+Sigma");
   PlotIndexSetString(3,PLOT_LABEL,"Middle");
   PlotIndexSetString(4,PLOT_LABEL,"-Sigma");
   PlotIndexSetString(5,PLOT_LABEL,"-2Sigma");
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);

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
   double price_,xma,Sum,D,M,BB;
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

      if(bar<StartBarsM) continue;

      //---- calculation of the price average deviation
      Sum=0.0;
      for(int j=0;j<MPeriod;j++) Sum+=MathAbs(PriceSeries(IPC,bar-j,open,low,high,close)-xma);
      D=Sum/MPeriod_;

      //---- indicator buffer initialization
      if(D!=0.0) XCCI[bar]=M/D;
     }

//---- Bollinger Bands main calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      BBands.BBandsSeries(StartBarsM,prev_calculated,rates_total,
                          BBPeriod,BBDeviation1,MODE_SMA,XCCI[bar],bar,false,
                          ExtLineBuffer5[bar],ExtLineBuffer3[bar],ExtLineBuffer1[bar]);

      //---- 
      BB=(ExtLineBuffer1[bar]-ExtLineBuffer3[bar])*quotient;
      ExtLineBuffer2[bar]=ExtLineBuffer3[bar]+BB;
      ExtLineBuffer4[bar]=ExtLineBuffer3[bar]-BB;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
