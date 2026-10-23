/*
 * The operation of the indicator requires
 * SmoothAlgorithms.mqh
 * to be placed in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                    Squize_MA.mq5 | 
//| mtf:ForexTSD.com                       Copyright © 2007, Kalenzo | 
//| mladen's formula   ki                bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
#property description "A new and very good MA version - the chart features conventional flat limits." 
#property description "A breakout suggests the presence of conditions for a steady trend."
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers is 4
#property indicator_buffers 4 
//---- only 4 plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  declaration of constants              |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Chocolate color is used the the indicator line color
#property indicator_color1 clrChocolate
//---- the indicator line is a dash-and-dot curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Squize_MA1"
//+--------------------------------------------+
//|  Indicator level drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selecting colors for Bollinger bands
#property indicator_color2  clrTeal
#property indicator_color3  clrRed
//---- Bollinger bands are dash-and-dot curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- Bollinger band width is 5
#property indicator_width2  5
#property indicator_width3  5
//---- displaying Bollonger band labels
#property indicator_label2  "+Squize_MA Env"
#property indicator_label3  "-Squize_MA Env"
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type4   DRAW_LINE
//---- blue-violet color is used as the indicator line color
#property indicator_color4 clrBlueViolet
//---- the indicator line is a dash-and-dot curve
#property indicator_style4  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width4  2
//---- displaying the indicator label
#property indicator_label4  "Squize_MA2"

//+-----------------------------------+
//|  Description of averaging classes      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of CXMA and CStdDeviation class variables from SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  declaration of enumerations          |
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
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_EMA; //first smoothing method
input uint Length1=5; //first smoothing depth                    
input int Phase1=15; //first smoothing parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient process;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC1=PRICE_CLOSE;//price constant

input Smooth_Method MA_Method2=MODE_EMA; //second smoothing method
input uint Length2=21; //second smoothing depth 
input int Phase2=100;  //second smoothing parameter,
                       //for JJMA, it varies within the range -100 ... +100 and influences the quality of the transient process;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC2=PRICE_CLOSE;//price constant

input uint MAsThreSHoldPips=15;
input bool ATRmode=true;
input uint ATRperiod=50;
input double ATRmultipl=0.4;

input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double XMA1Buffer[],XMA2Buffer[];
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers of Bollinger bands
double ExtLineBuffer1[],ExtLineBuffer2[];
//---- Declaration of a variable for storing the indicator handle
int ATR_Handle;
//---- Declaration of integer variables of data starting point
uint min_rates_1,min_rates_2,min_rates_total;
//+------------------------------------------------------------------+   
//| Squize_MA indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=MathMax(min_rates_1,min_rates_2);
   if(ATRmode) min_rates_total+=ATRperiod;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA2.XMALengthCheck("BandsPeriod",ATRperiod);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- getting the ATR indicator handle
   if(ATRmode)
     {
      ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRperiod);
      if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get the ATR indicator handle");
     }

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,XMA1Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(XMA1Buffer,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- setting a position from which the drawing of breakout levels begins
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction on drawing empty values by the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(3,XMA2Buffer,INDICATOR_DATA);
//---- shifting indicator 4 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(XMA2Buffer,true);

//---- initialization of a variable for a short name of the indicator
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA_Bollinger Bands(",
                     Length1,", ",Length2,", ",ATRperiod,", ",Smooth1,", ",Smooth2,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Squize_MASquize_MA iteration function                            | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
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
   if(ATRmode && BarsCalculated(ATR_Handle)<rates_total || rates_total<int(min_rates_total)) return(RESET);

//---- Declaration of variables with a floating point  
   double price_1,price_2,x1xma,x2xma,madif,delta,Range[];
//---- Declaration of integer variables and getting the bars already calculated
   int to_copy,limit,bar;
   uint maxbar=rates_total-1;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total; // calculated number of all bars
      limit=rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
      to_copy=limit+1; // calculated number of new bars only
     }

//---- copy new data into the Range[] array
   if(ATRmode)if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);

//---- indexing array elements as time series  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- Main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_1=PriceSeries(IPC1,bar,open,low,high,close);
      price_2=PriceSeries(IPC2,bar,open,low,high,close);

      //---- Two calls of the XMASeries function. 
      //In the second call, the begin parameter is increased by StartBars1 as this is a repeated XMA smoothing  
      x1xma = XMA1.XMASeries(maxbar, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_1, bar, true);
      x2xma = XMA2.XMASeries(maxbar, prev_calculated, rates_total, MA_Method2, Phase2, Length2, price_2, bar, true);
      madif = MathAbs(x1xma-x2xma);
      //----
      XMA1Buffer[bar]=x1xma;
      XMA2Buffer[bar]=x2xma;
      //----
      if(ATRmode) delta=Range[bar]*ATRmultipl/_Point;
      else        delta=MAsThreSHoldPips;
      //----
      if(madif/_Point<delta)
        {
         double dPoint=delta*_Point;
         ExtLineBuffer1[bar]=x2xma+dPoint;
         ExtLineBuffer2[bar]=x2xma-dPoint;
        }
      else
        {
         ExtLineBuffer1[bar]=EMPTY_VALUE;
         ExtLineBuffer2[bar]=EMPTY_VALUE;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
