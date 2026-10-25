//+------------------------------------------------------------------+
//|                                                         XRSX.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
//| The file SmoothAlgorithms.mqh                                    |
//| must be placed in the directory: MetaTrader\\MQL5\Include        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strength Index"
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers
#property indicator_buffers 4 
//--- only one plot is used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the histogram
#property indicator_color1 Gray,Green,Blue,Red,Magenta
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- the width of the indicator line is 3
#property indicator_width1  3
//--- displaying the indicator label
#property indicator_label1  "XRSX"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a three color line
#property indicator_type2   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color2 Gray,Lime,DarkOrange
//--- the indicator line is dashed
#property indicator_style2  STYLE_DASH
//--- Indicator line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  -50.0
#property indicator_level2  +50.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA UPXRSX,DNXRSX,XSIGN;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
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
//+-----------------------------------+
//| Input parameters of the indicator |
//+-----------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA;  // Price smoothing method
input int DPeriod=15;                         // Moving average period
input int DPhase=100;                         // Moving average smoothing parameter,
//--- for JJMA that varies within the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method SSmoothMethod=MODE_JurX;  // Signal line smoothing method
input int SPeriod=7;                          // Signal line period
input int SPhase=100;                         // Signal line parameter
//--- for JJMA that varies within the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;         // Price constant
input int Shift=0;                            // Horizontal shift of the indicator in bars
input IndStyle Style=COLOR_HISTOGRAM;         // XRSX display style
//+-----------------------------------+
//--- declaration of dynamic arrays that further will be used as indicator buffers
double XRSX[],XXRSX[];
double ColorXRSX[],ColorXXRSX[];
//--- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsD,StartBarsS;
//+------------------------------------------------------------------+   
//| XRSX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   StartBarsD=UPXRSX.GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   StartBarsS=StartBarsD+UPXRSX.GetStartBars(SSmoothMethod,SPeriod,SPhase);
   StartBars=StartBarsS;
//--- setting up alerts for invalid values of external parameters
   UPXRSX.XMALengthCheck("DPeriod", DPeriod);
   UPXRSX.XMALengthCheck("SPeriod", SPeriod);
//--- setting up alerts for invalid values of external parameters
   UPXRSX.XMAPhaseCheck("DPhase",DPhase,DSmoothMethod);
   UPXRSX.XMAPhaseCheck("SPhase",SPhase,SSmoothMethod);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XRSX,INDICATOR_DATA);
//--- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XRSX");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- changing the indicator display style   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Style);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXRSX,INDICATOR_COLOR_INDEX);
//--- shifting the beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBarsD+1);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,XXRSX,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Signal line");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorXXRSX,INDICATOR_COLOR_INDEX);
//--- shifting the beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars+1);
//--- initializations of a variable for a short name of the indicator
   string shortname,Smooth;
   Smooth=UPXRSX.GetString_MA_Method(DSmoothMethod);
   StringConcatenate(shortname,"Relative Strength Index(",string(DPeriod),",",Smooth,")");
//--- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
  }
//+------------------------------------------------------------------+ 
//| XRSX iteration function                                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<StartBars) return(0);
//--- declaration of variables with a floating point  
   double dprice_,absdprice_,up_xrsx,dn_xrsx,xrsx,xxrsx;
//--- declaration of integer variables and getting the bars already calculated
   int first1,first2,first3,bar;
//--- calculation of the starting number 'first' for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first1=1; // starting index for calculation of all bars
      first2=StartBarsD+1;
      first3=StartBars+1;
     }
   else
     {
      first1=prev_calculated-1; // starting index for calculation of new bars
      first2=first1;
      first3=first1;
     }
//--- main indicator calculation loop
   for(bar=first1; bar<rates_total; bar++)
     {
      //--- calling the PriceSeries function to get the increment of the input price dprice_
      dprice_=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-1,open,low,high,close);
      absdprice_=MathAbs(dprice_);
      //--- two calls of the XMASeries function.  
      up_xrsx = UPXRSX.XMASeries(1, prev_calculated, rates_total, DSmoothMethod, DPhase, DPeriod,    dprice_, bar, false);
      dn_xrsx = DNXRSX.XMASeries(1, prev_calculated, rates_total, DSmoothMethod, DPhase, DPeriod, absdprice_, bar, false);
      //--- preventing division by zero on empty values
      if(dn_xrsx==0) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;
         //--- upper and lower limits of the indicator 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }
      //--- copying the obtained value to the indicator buffer
      XRSX[bar]=xrsx*100;
      xxrsx=XSIGN.XMASeries(StartBarsD,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,XRSX[bar],bar,false);
      //--- copying the obtained value to the indicator buffer
      XXRSX[bar]=xxrsx;
     }
//--- main loop of the MACD indicator coloring
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
//--- main loop of the signal line coloring
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorXXRSX[bar]=0;
      if(XRSX[bar]>XXRSX[bar-1]) ColorXXRSX[bar]=1;
      if(XRSX[bar]<XXRSX[bar-1]) ColorXXRSX[bar]=2;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
