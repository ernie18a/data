//+------------------------------------------------------------------+
//|                                              X2MA_BBx3_Cloud.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "X2MA Bollinger Bands"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 11
#property indicator_buffers 11 
//---- 7 graphical plots are used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use blue violet color for the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "X2MA line"
//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color2  Red
#property indicator_color3  Red
//---- Bollinger Bands are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- display of Bollinger Bands labels
#property indicator_label2  "+2Sigma line"
#property indicator_label3  "-2Sigma line"
//+--------------------------------------------+
//|  Background drawing parameters             |
//+--------------------------------------------+
//---- drawing the background as a cloud
#property indicator_type4   DRAW_FILLING
#property indicator_type5   DRAW_FILLING
#property indicator_type6   DRAW_FILLING
#property indicator_type7   DRAW_FILLING
//---- selection of background colors
#property indicator_color4  Aquamarine
#property indicator_color5  PaleTurquoise
#property indicator_color6  Wheat
#property indicator_color7  LightPink
//---- display of Bollinger Bands labels
#property indicator_label4  "+2Sigma Cloud Out"
#property indicator_label5  "+2Sigma Cloud In"
#property indicator_label6  "-2Sigma Cloud In"
#property indicator_label7  "-2Sigma Cloud Out"
//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
CStdDeviation STD;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
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
input Smooth_Method MA_Method1=MODE_SMA;  // First smoothing method
input int Length1=100;                    // First smoothing depth                    
input int Phase1=15;                      // First smoothing parameter
input Smooth_Method MA_Method2=MODE_JJMA; // Second smoothing method
input int Length2=20;                     // Second smoothing depth 
input int Phase2=100;                     // Second smoothing parameter
input int BandsPeriod=100;                // BB smoothing period
input double BandsDeviation = 2.0;        // Number of deviations
input Applied_price_ IPC=PRICE_CLOSE;     // Applied price
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in points
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double X2MA[];
//---- declaration of dynamic arrays that
//---- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[];
double ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[];
double ExtLineBuffer7[],ExtLineBuffer8[];
double ExtLineBuffer9[],ExtLineBuffer10[];
//---- declaration of the average vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| X2MA BBx3 indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1)+1;
   StartBars2=StartBars1+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars2+BandsPeriod;

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA2.XMALengthCheck("BandsPeriod", BandsPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set X2MA[] dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set ExtLineBuffer1[] and ExtLineBuffer2[] dynamic arrays into indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer9,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer10,INDICATOR_DATA);
//---- set the position, from which the background drawing starts
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(10,PLOT_DRAW_BEGIN,StartBars);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA_Bollinger Bands(",
                     Length1,", ",Length2,", ",BandsPeriod,", ",Smooth1,", ",Smooth2,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| X2MA BBx3 iteration function                                     | 
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
   double price_,x1xma,x2xma,stdev;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the XMASeries function. 
      //---- the 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //----       
      X2MA[bar]=x2xma+dPriceShift;
     }

//---- Bollinger Bands main calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      stdev = STD.StdDevSeries(StartBars2, prev_calculated, rates_total, BandsPeriod, BandsDeviation, price_, X2MA[bar], bar, false);

      ExtLineBuffer1[bar]=X2MA[bar]+stdev+dPriceShift;
      ExtLineBuffer2[bar]=X2MA[bar]-stdev+dPriceShift;

      ExtLineBuffer3[bar]=X2MA[bar]+stdev*100+dPriceShift;
      ExtLineBuffer4[bar]=X2MA[bar]+stdev+dPriceShift;

      ExtLineBuffer5[bar]=X2MA[bar]+stdev+dPriceShift;
      ExtLineBuffer6[bar]=X2MA[bar]+dPriceShift;

      ExtLineBuffer7[bar]=X2MA[bar]+dPriceShift;
      ExtLineBuffer8[bar]=X2MA[bar]-stdev+dPriceShift;

      ExtLineBuffer9[bar]=X2MA[bar]-stdev+dPriceShift;
      ExtLineBuffer10[bar]=X2MA[bar]-stdev*100+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
