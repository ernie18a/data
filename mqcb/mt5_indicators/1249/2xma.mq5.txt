//+------------------------------------------------------------------+
//|                                                         2XMA.mq5 | 
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 4 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator
#property indicator_color1 clrMaroon,clrDarkSlateBlue
//---- displaying the indicator label
#property indicator_label1  "Lower XMACD";"Upper XMACD"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- use the following color for the indicator line
#property indicator_color2 clrGold
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Fast Signal Line"

//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- use the following color for the indicator line
#property indicator_color3 clrMediumTurquoise
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Slow Signal Line"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4;
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
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
input Smooth_Method MA_Method1=MODE_LWMA; //method of averaging of the fast XMA
input uint Length1=28; //fast XMA period                  
input int Phase1=15; //fast XMA parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC1=PRICE_CLOSE;//fast XMA price constant

input Smooth_Method MA_Method2=MODE_LWMA; //method of averaging of the slow XMA 
input uint Length2=144; //slow XMA period
input int Phase2=15;  //slow XMA parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC2=PRICE_CLOSE;//slow XMA price constant

input Smooth_Method MA_Method3=MODE_SMA; //method of averaging of the fast signal line
input uint Length3=14; //fast signal line period
input int Phase3=15;  //fast signal line parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method MA_Method4=MODE_SMA; //method of averaging of the slow signal line
input uint Length4=70; //slow signal line period
input int Phase4=15;  //slow signal line parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double UpBuffer[],DnBuffer[],FastSignBuffer[],SlowSignBuffer[];

//---- Declaration of the average vertical shift value variable
double dPriceShift;
//---- Declaration of integer variables of data starting point
int min_rates_xmacd,min_rates_total;
//+------------------------------------------------------------------+   
//| 2XMA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   int min_rates_fast1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   int min_rates_slow1=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   int min_rates_fast2=XMA3.GetStartBars(MA_Method3, Length3, Phase3);
   int min_rates_slow2=XMA4.GetStartBars(MA_Method4, Length4, Phase4);  
   min_rates_xmacd=int(MathMax(min_rates_fast1,min_rates_slow1));
   min_rates_total=min_rates_xmacd+int(MathMax(min_rates_fast2,min_rates_slow2));

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA3.XMALengthCheck("Length3", Length3);
   XMA4.XMALengthCheck("Length4", Length4);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
   XMA3.XMAPhaseCheck("Phase3", Phase3, MA_Method3);
   XMA4.XMAPhaseCheck("Phase4", Phase4, MA_Method4);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,FastSignBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,SlowSignBuffer,INDICATOR_DATA);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname="2XMA";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| 2XMA iteration function                                          | 
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
   double fastxma,slowxma,fastsignal,slowsignal,fprice,sprice,xmacd;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price
      fprice=PriceSeries(IPC1,bar,open,low,high,close);
      sprice=PriceSeries(IPC2,bar,open,low,high,close);

      //---- Two calls of the XMASeries function.   
      fastxma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,fprice,bar,false);
      slowxma=XMA2.XMASeries(0,prev_calculated,rates_total,MA_Method2,Phase2,Length2,sprice,bar,false);
      //----       
      UpBuffer[bar]=NormalizeDouble(fastxma+dPriceShift,_Digits);
      DnBuffer[bar]=NormalizeDouble(slowxma+dPriceShift,_Digits);
      xmacd=fastxma-slowxma;

      //---- Two calls of the XMASeries function.   
      fastsignal=XMA3.XMASeries(min_rates_xmacd,prev_calculated,rates_total,MA_Method3,Phase3,Length3,xmacd,bar,false);
      slowsignal=XMA4.XMASeries(min_rates_xmacd,prev_calculated,rates_total,MA_Method4,Phase4,Length4,xmacd,bar,false);

      FastSignBuffer[bar]=NormalizeDouble(slowxma+fastsignal+dPriceShift,_Digits);
      SlowSignBuffer[bar]=NormalizeDouble(slowxma+slowsignal+dPriceShift,_Digits);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
