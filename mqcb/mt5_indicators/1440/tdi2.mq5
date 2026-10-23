//+---------------------------------------------------------------------+
//|                                                           TDI-2.mq5 |
//|                                              Copyright © Rosh, 2009 |
//|                                         https://www.metaquotes.net/ |
//|                                                     Written by Rosh |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © Rosh, 2009"
#property link "https://www.metaquotes.net/"
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+---------------------------------------+
//|  TDI indicator drawing parameters     |
//+---------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1 clrRed
//---- the indicator line is a dot-dash one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Trend Direction Index"

//+---------------------------------------+
//|  Signal line drawing parameter        |
//+---------------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color2 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Direction"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3;
//+-----------------------------------+
//|  Declaration of enumerations      |
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
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price 
  };
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
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method TdiMethod=MODE_SMA; //smoothing method
input int TdiPeriod=20; //smoothing depth                    
input int TdiPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                     // For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double TDI[],Direct[];

//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+   
//| TDI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=TdiPeriod;
   min_rates_2=min_rates_1+XMA1.GetStartBars(TdiMethod, TdiPeriod, TdiPhase);
   min_rates_total=min_rates_1+min_rates_2+2*XMA1.GetStartBars(TdiMethod, TdiPeriod, TdiPhase);
//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("TdiPeriod", TdiPeriod);
   XMA1.XMAPhaseCheck("TdiPhase", TdiPhase, TdiMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,TDI,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Direct,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(TdiMethod);
   StringConcatenate(shortname,"Trend Direction Index(",Smooth,", ",TdiPeriod,", ",TdiPhase,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| TDI iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double Mom,MomAbs,MomSum,MomSumAbs,MomAbsSum,MomAbsSum2;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=TdiPeriod; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Mom=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-TdiPeriod,open,low,high,close);
      MomAbs=MathAbs(Mom);
      MomSum=TdiPeriod*XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,TdiMethod,TdiPhase,TdiPeriod,Mom,bar,false);
      MomSumAbs=MathAbs(MomSum);
      MomAbsSum=TdiPeriod*XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,TdiMethod,TdiPhase,TdiPeriod,MomAbs,bar,false);
      MomAbsSum2=2*TdiPeriod*XMA3.XMASeries(min_rates_2,prev_calculated,rates_total,TdiMethod,TdiPhase,2*TdiPeriod,MomAbs,bar,false);
      TDI[bar]=MomSumAbs-(MomAbsSum2-MomAbs);
      Direct[bar]=MomSum;     
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
