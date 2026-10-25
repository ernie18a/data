/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                      XRSX_BB.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strength Index"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 9 
//---- only seven plots are used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color1 Gray,Green,Blue,Red,Magenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of the indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "XRSX"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator as a three-colored line
#property indicator_type2   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color2 Gray,Lime,DarkOrange
//---- the indicator line is a stroke
#property indicator_style2  STYLE_DASH
//---- the indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Signal line"
//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing Bollinger Bands as lines
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color3  Blue
#property indicator_color4  Red
#property indicator_color5  Gray
#property indicator_color6  Red
#property indicator_color7  Blue
//---- Bollinger Bands are dott-dash curves
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
//---- display of Bollinger Bands labels
#property indicator_label3  "+2Sigma"
#property indicator_label4  "+Sigma"
#property indicator_label5  "Middle"
#property indicator_label6  "-Sigma"
#property indicator_label7  "-2Sigma"

//+------------------------------------------------+
//| Description of smoothing classes and indicators|
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+-----------------------------------+
//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA UPXRSX,DNXRSX,XSIGN,XMA;
CStdDeviation STD;
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
   PRICE_SIMPLE_,        //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndStyle //The indicator display style
  {
   COLOR_LINE = DRAW_COLOR_LINE,          //Colored line
   COLOR_HISTOGRAM=DRAW_COLOR_HISTOGRAM,  //Colored histogram
   COLOR_ARROW=DRAW_COLOR_ARROW           //Colored labels
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
input Smooth_Method DSmoothMethod=MODE_JurX; //Price smoothing method
input int DPeriod=15;                        //Moving average period
input int DPhase=100;                        //Moving average smoothing parameter
                                             // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                                             // for VIDIA it is a CMO period, for AMA it is a slow average period

input Smooth_Method SSmoothMethod=MODE_JJMA; //Signal line smoothing method
input int SPeriod=7;                         //Signal line period
input int SPhase=100;                        //Signal line parameter
                                             // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                                             // for VIDIA it is a CMO period, for AMA it is a slow average period

input Applied_price_ IPC=PRICE_CLOSE;        //Price constant
/* , used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */

input int Shift=0;                           //Horizontal shift of the indicator in bars
input IndStyle Style=COLOR_HISTOGRAM;        //XRSX display style

input int BBPeriod=100;                      //The period for Bollinger levels
input double BBDeviation1 = 1.0;             //Small deviation
input double BBDeviation2 = 1.6;             //Big deviation
//+-----------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double XRSX[],XXRSX[];
double ColorXRSX[],ColorXXRSX[];
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];

//---- declaration of the Bollinger Bands proportion variable
double quotient;

//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsD,StartBarsS,StartBarsB;
//+------------------------------------------------------------------+   
//| XRSX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBarsD=UPXRSX.GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   StartBarsS=StartBarsD+UPXRSX.GetStartBars(SSmoothMethod,SPeriod,SPhase);
   StartBarsB=StartBarsD+BBPeriod;
   StartBars=MathMax(StartBarsS,StartBarsB);

//---- setting up alerts for unacceptable values of external variables
   UPXRSX.XMALengthCheck("DPeriod", DPeriod);
   UPXRSX.XMALengthCheck("SPeriod", SPeriod);
//---- setting up alerts for unacceptable values of external variables
   UPXRSX.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);
   UPXRSX.XMAPhaseCheck("SPhase",SPhase,SSmoothMethod);

//---- initialization of the Bollinger Bands proportion variable
   quotient=BBDeviation2/BBDeviation1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XRSX,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBarsD+1);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- changing of the indicator display style   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Style);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXRSX,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBarsD+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,XXRSX,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBarsS+1);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorXXRSX,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBarsS+1);

//---- converting dynamic arrays into indicator buffers
   SetIndexBuffer(4,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer5,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBarsB);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBarsB);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBarsB);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBarsB);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBarsB);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth;
   Smooth=UPXRSX.GetString_MA_Method(DSmoothMethod);
   StringConcatenate(shortname,"Relative Strength Index(",string(DPeriod),",",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XRSX iteration function                                          | 
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
   double dprice_,absdprice_,up_xrsx,dn_xrsx,xrsx,xxrsx,xma,stdev1,stdev2;
//---- declaration of integer variables and getting already calculated bars
   int first1,first2,first3,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first1=1; // starting index for calculation of all bars
      first2=StartBarsD+1;
      first3=StartBarsS+1;
     }
   else
     {
      first1=prev_calculated-1; // starting index for calculation of new bars
      first2=first1;
      first3=first1;
     }

//---- main indicator calculation loop
   for(bar=first1; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get incrementation of the input price dprice_
      dprice_=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-1,open,low,high,close);

      absdprice_=MathAbs(dprice_);

      //---- two calls of the XMASeries function.  
      up_xrsx = UPXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,   dprice_,bar,false);
      dn_xrsx = DNXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,absdprice_,bar,false);

      //---- preventing zero divide on empty values
      if(dn_xrsx==0) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;

         //---- upper and lower limits of the indicator 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }

      //---- loading the obtained value in the indicator buffer
      XRSX[bar]=xrsx*100;

      //---- signal line calculation
      xxrsx=XSIGN.XMASeries(StartBarsD,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,XRSX[bar],bar,false);

      //---- Loading the obtained value in the indicator buffer
      XXRSX[bar]=xxrsx;

      //---- Bollinger Bands calculation

      xma=XMA.XMASeries(StartBarsD+1,prev_calculated,rates_total,MODE_SMA_,0,BBPeriod,XRSX[bar],bar,false);
      stdev1=STD.StdDevSeries(StartBarsB,prev_calculated,rates_total,BBPeriod,BBDeviation1,XRSX[bar],xma,bar,false);
      stdev2=stdev1*quotient;
      //---- 
      if(bar<=StartBarsB+BBPeriod)
        {
         xma=EMPTY_VALUE;
         stdev1=0.0;
         stdev2=0.0;
        }

      ExtLineBuffer1[bar]=xma+stdev2;
      ExtLineBuffer2[bar]=xma+stdev1;
      ExtLineBuffer3[bar]=xma;
      ExtLineBuffer4[bar]=xma-stdev1;
      ExtLineBuffer5[bar]=xma-stdev2;
     }

//---- Bollinger Bands calculation main loop
   for(bar=first3; bar<rates_total; bar++)
     {

     }

//---- main loop of the MACD indicator coloring
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorXRSX[bar]=0;

      if(XRSX[bar]>0)
        {
         if(XRSX[bar]>XRSX[bar-1]) ColorXRSX[bar]=1;
         if(XRSX[bar]<XRSX[bar-1]) ColorXRSX[bar]=2;
        }

      if(XRSX[bar]<0)
        {
         if(XRSX[bar]<XRSX[bar-1]) ColorXRSX[bar]=3;
         if(XRSX[bar]>XRSX[bar-1]) ColorXRSX[bar]=4;
        }
     }

//---- main loop of the signal line coloring
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorXXRSX[bar]=0;
      if(XRSX[bar]>XXRSX[bar-1]) ColorXXRSX[bar]=1;
      if(XRSX[bar]<XXRSX[bar-1]) ColorXXRSX[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
