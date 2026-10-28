//+------------------------------------------------------------------+
//|                                               JS-Stoh+BB+RSI.mq5 | 
//|                                      Copyright © 2009, js_sergey | 
//|                       js_sergey@list.ru, http://multiexperts.ru/ | 
//+------------------------------------------------------------------+
/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
#property copyright "Copyright © 2009, js_sergey"
#property link "http://multiexperts.ru/"
#property description "X2MA Bollinger Bands"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- only 5 graphical plots are used
#property indicator_plots   5
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color1 clrBlue
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Stochastic"

//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- green color is used as the color of the indicator line
#property indicator_color2 clrTeal
//---- the indicator line is a dash-dotted curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "RSI"

//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color3 clrBlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width3  2
//---- displaying the indicator label
#property indicator_label3  "Stochastic Signal"

//+----------------------------------------------+
//|  BB levels indicator drawing parameters      |
//+----------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color4  clrRed
#property indicator_color5  clrRed
//---- Bollinger Bands are continuous curves
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//---- Bollinger Bands width is equal to 1
#property indicator_width4  1
#property indicator_width5  1
//---- display the labels of Bollinger Bands levels
#property indicator_label4  "+2Sigma Stochastic"
#property indicator_label5  "-2Sigma Stochastic"

//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  80.0
#property indicator_level2  70.0
#property indicator_level3  50.0
#property indicator_level4  30.0
#property indicator_level5  20.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  Averaging classes description               |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA;
CStdDeviation STD;
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint STO_KPeriod=5;  // K period of stochastic
input uint STO_DPeriod=3;  // D period of stochastic
input uint STO_Slowing=3;  // Slowing of stochastic
input ENUM_MA_METHOD STO_Method=MODE_SMA; // smoothing type of stochastic
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH; // stochastic calculation method

input uint BandsPeriod=10; //period of averaging of BB
input double BandsDeviation=1.0; //deviation

input uint RSI_Period=8; //RSI indicator period
input ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE; //price type of RSI indicator

input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];

//---- declaration of integer variables for the indicators handles
int RSI_Handle,STO_Handle;

//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_sto;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_sto=int(STO_KPeriod+STO_DPeriod+STO_Slowing+1);
   int min_rates_=int(min_rates_sto+BandsDeviation);
   min_rates_total=int(MathMax(min_rates_,RSI_Period));

//---- getting handle of the iRSI indicator  
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,RSI_Period,RSI_Price);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");

//---- Getting handle of the iStochastic indicator
   STO_Handle=iStochastic(NULL,0,STO_KPeriod,STO_DPeriod,STO_Slowing,STO_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer3,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer4,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer5,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"JS-Stoh+BB+RSI");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- Declaration of integer variables
   int limit,bar,to_copy,xmaxbar,smaxbar;
//---- declaration of variables with a floating point  
   double stoh,xstoh,stdev;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 

   xmaxbar=rates_total-min_rates_sto-1;
   smaxbar=xmaxbar-int(BandsPeriod);
   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,ExtLineBuffer1)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle,MAIN_LINE,0,to_copy,ExtLineBuffer2)<=0) return(RESET);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      stoh=ExtLineBuffer1[bar];
      xstoh=XMA.XMASeries(xmaxbar,prev_calculated,rates_total,int(MODE_SMA),0,BandsPeriod,stoh,bar,true);
      ExtLineBuffer3[bar]=xstoh;
      stdev=STD.StdDevSeries(smaxbar,prev_calculated,rates_total,BandsPeriod,BandsDeviation,stoh,xstoh,bar,true);
      ExtLineBuffer4[bar]=xstoh+stdev;
      ExtLineBuffer5[bar]=xstoh-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
