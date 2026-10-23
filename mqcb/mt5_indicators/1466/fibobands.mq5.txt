//+------------------------------------------------------------------+
//|                                                    FiboBands.mq5 | 
//|                                             Copyright © 2013,    | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright ""
#property link ""
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 7 
//---- only one plot is used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- gray color is used as the color of the indicator line
#property indicator_color1 clrGray
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "X2MA"

//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrLime
#property indicator_color4  clrMagenta
#property indicator_color5  clrMagenta
#property indicator_color6  clrLime
#property indicator_color7  clrDodgerBlue
//---- Bollinger Bands are dott-dash curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
//---- Bollinger Bands width is equal to 2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
//---- display the labels of Bollinger Bands levels
#property indicator_label2  "+4.236 level"
#property indicator_label3  "+2.618 level"
#property indicator_label4  "+1.618 level"
#property indicator_label5  "-1.618 level"
#property indicator_label6  "-2.618 level"
#property indicator_label7  "-4.236 level"

//+-----------------------------------+ 
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0   // The constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
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
input Smooth_Method MA_Method1=MODE_SMA; //first smoothing method
input uint Length1=100; //first smoothing depth                    
input int Phase1=15; //first smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method MA_Method2=MODE_JJMA; //second smoothing method
input uint Length2=20; //second smoothing depth 
input int Phase2=100;  //second smoothing parameter,
                       // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input uint ATRPeriod=100; //ATR period
input double Deviation=1.0; //deviation

input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double X2MA[];

//---- declaration of dynamic arrays that will further be 
//---- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[];
double ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];

//---- Declaration of the average vertical shift value variable
double dPriceShift;
//----Declaration of variables for storing the indicators handles
int ATR_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//---- declaration of variables for storing coefficients
double Deviation1,Deviation2,Deviation3;
//+------------------------------------------------------------------+   
//| X2MA FiboBands indicator initialization function                 | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=XMA1.GetStartBars(MA_Method1,Length1,Phase1)+1;
   min_rates_total=min_rates_+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=int(MathMax(min_rates_total,ATRPeriod));
//----
   Deviation1=Deviation*1.618;
   Deviation2=Deviation*2.618;
   Deviation3=Deviation*4.236;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- getting the ATR indicator handle
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the ATR indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"FiboBands(",Smooth1,", ",Smooth2,", ",Length1,", ",Length2,", ",ATRPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| X2MA FiboBands iteration function                                | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double price,x1xma,x2xma,dev1,dev2,dev3,ATR[1];
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- Two calls of the XMASeries function. 
      //The 'begin' parameter is increased by min_rates_ in the second call,  as another XMA smoothing  
      x1xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      x2xma=XMA2.XMASeries(min_rates_,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,false);
      X2MA[bar]=x2xma+dPriceShift;

      //---- copy newly appeared data in the ATR[] array
      if(CopyBuffer(ATR_Handle,0,rates_total-1-bar,1,ATR)<=0) return(RESET);

      //---- bands calculation

      dev1=Deviation1*ATR[0];
      dev2=Deviation2*ATR[0];
      dev3=Deviation3*ATR[0];

      ExtLineBuffer1[bar]=X2MA[bar]+dev3;
      ExtLineBuffer2[bar]=X2MA[bar]+dev2;
      ExtLineBuffer3[bar]=X2MA[bar]+dev1;
      ExtLineBuffer4[bar]=X2MA[bar]-dev1;
      ExtLineBuffer5[bar]=X2MA[bar]-dev2;
      ExtLineBuffer6[bar]=X2MA[bar]-dev3;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
