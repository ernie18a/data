//+------------------------------------------------------------------+
//|                                                    BBflat_sw.mq5 | 
//|                                           Copyright © 2008, Raff | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Raff"
#property link ""
#property description ""
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in a separate window
#property indicator_separate_window
//---- Number of indicator buffers 3
#property indicator_buffers 3 
//---- Three graphical constructions used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- Blue is used a the line color
#property indicator_color1 clrBlue
//---- Indicator line - solid
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is 2
#property indicator_width1  2
//---- Indicator label shown
#property indicator_label1  "Signal Line"

//+--------------------------------------------+
//|  Parameters for drawing BB levels indicator|
//+--------------------------------------------+
//---- Drawing Bollinger levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- Selecting the color of the levels
#property indicator_color2  clrRed
#property indicator_color3  clrRed
//---- Levels - solid lines
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- The width of the levels is 1
#property indicator_width2  1
#property indicator_width3  1
//---- Showing the labels of the levels
#property indicator_label2  "+NSigma"
#property indicator_label3  "-NSigma"
//+----------------------------------------------+
//| Parameters for drawing horizontal levels     |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//|  Description of averaging classes |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- Declaring the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
CStdDeviation STD;
//+-----------------------------------+
//|  Declaring enumerations           |
//+-----------------------------------+
enum Applied_price_ //Constant type
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
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; //Method of averaging
input int XLength=100; //Depth of smoothing                    
input int XPhase=15; //Averaging parameter,
                     //for JJMA changing within -100 ... +100, affects the quality of the transient process;
// For VIDIA it is CMO period, for AMA it is the period of a slow MA
input int BandsPeriod=100; //Period of BB averaging
input double BandsDeviation = 2.0; //Deviation

input Applied_price_ IPC=PRICE_CLOSE;//Price constant
input int Shift=0; // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- Declaring a dynamic array that will be further 
// used as an indicator buffer
double ExtLineBuffer[];

//---- Declaring a dynamic array that will be further 
// used as indicator buffers for Bollinger levels
double ExtLineBuffer1[],ExtLineBuffer2[];

//---- Declaring integer variables of the start of data calculation
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=XMA1.GetStartBars(XMA_Method,XLength,XPhase)+1;
   min_rates_total=min_rates_+BandsPeriod;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMALengthCheck("BandsPeriod", BandsPeriod);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Drawing of empty values is forbidden
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Initializations of variable for indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"BBflat_sw(",XLength,", ",BandsPeriod,", ",Smooth,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- End of initialization
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
  //---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaring floating point variables  
   double price,xma,stdev;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,false);
      stdev=STD.StdDevSeries(min_rates_,prev_calculated,rates_total,BandsPeriod,BandsDeviation,price,xma,bar,false)/_Point;     
      ExtLineBuffer[bar]=(price-xma)/_Point;     
      ExtLineBuffer1[bar]=+stdev;
      ExtLineBuffer2[bar]=-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
