/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                         XATR.mq5 | 
//|                               Copyright © Sovpel Alexander, 2009 | 
//|                               E-mail: Sovpel-Alexander@yandex.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © Sovpel Alexander, 2009"
#property link "E-mail: Sovpel-Alexander@yandex.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
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
//---- DodgerBlue color is used for the indicator line
#property indicator_color1 DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "XATR"

//+-----------------------------------+
//|  Описание класса CXATR            |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXATR class variables from the SmoothAlgorithms.mqh file
CXMA XATR1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
input Smooth_Method XMA_Method=MODE_LWMA; //averaging method
input int XLength=12; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double XATR[];

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| XATR indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XATR1.GetStartBars(XMA_Method,XLength,XPhase)+1;
//---- setting alerts for invalid values of external parameters
   XATR1.XMALengthCheck("XLength", XLength);
   XATR1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XATR,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XATR1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XATR(",XLength,", ",Smooth1,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| XATR iteration function                                          | 
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
   double atr;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=1; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      atr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
      atr/=_Point;
      XATR[bar]=XATR1.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,atr,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
