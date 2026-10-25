//+---------------------------------------------------------------------+
//|                                                             WPR.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Larry Williams' Percent Range"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 4 
//---- 2 plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator as a three-colored line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color1 Gray,LightSeaGreen,HotPink
//---- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "Signal"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- the following colors are used in the histogram
#property indicator_color2 Blue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "WPR"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1     -20.0
#property indicator_level2     -80.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XSIGN;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ // Type of constant
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndStyle // indicator display style
  {
   COLOR_LINE = DRAW_COLOR_LINE,  // Colored line
   COLOR_ARROW=DRAW_COLOR_ARROW   // Colored labels
  };
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int DPeriod=15;                        // WPR period
input Smooth_Method SSmoothMethod=MODE_JJMA; // Signal line smoothing method
input int SPeriod=7;                         // Signal line period
input int SPhase=100;                        // Signal line parameter
input Applied_price_ IPC=PRICE_CLOSE;        // Price constant
input int Shift=0;                           // Horizontal shift of the indicator in bars
input IndStyle Style=DRAW_COLOR_ARROW;       // WPR display style
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double WPR[],XWPR[];
double ColorXWPR[];
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsD,StartBarsS;
//+------------------------------------------------------------------+   
//| WPR indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBarsD=DPeriod+1;
   StartBarsS=StartBarsD+XSIGN.GetStartBars(SSmoothMethod,SPeriod,SPhase);
   StartBars=StartBarsS;

//---- setting up alerts for unacceptable values of external variables
   XSIGN.XMALengthCheck("SPeriod",SPeriod);
//---- setting up alerts for unacceptable values of external variables
   XSIGN.XMAPhaseCheck("SPhase",SPhase,SSmoothMethod);

//---- set XWPR[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XWPR,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ColorXWPR[] dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXWPR,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars+1);

//---- set WPR[] dynamic array as an indicator buffer
   SetIndexBuffer(2,WPR,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- changing of the indicator display style   
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,Style);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth;
   Smooth=XSIGN.GetString_MA_Method(SSmoothMethod);
   StringConcatenate(shortname,"Larry Williams' Percent Range(",string(DPeriod),",",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| WPR iteration function                                           | 
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
   double HH,LL,price_;
//---- declaration of integer variables and getting calculated bars
   int first1,first2,first3,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first1=StartBarsD; // starting index for calculation of all bars
      first2=StartBarsD+1;
      first3=StartBars+1;
     }
   else
     {
      first1=prev_calculated-1; // starting index for calculation of new bars
      first2=first1;
      first3=first1;
     }

//---- main indicator calculation loop
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      ArraySetAsSeries(low,true);
      ArraySetAsSeries(high,true);
      int rate_=rates_total-1-bar;
      LL=low[ArrayMinimum(low,rate_,DPeriod)];
      HH=high[ArrayMaximum(high,rate_,DPeriod)];

      //---- loading the obtained value in the indicator buffer
      if(HH!=LL) WPR[bar]=-(HH-price_)*100/(HH-LL);
      else       WPR[bar]=WPR[bar-1];

      //---- loading the obtained value in the indicator buffer
      XWPR[bar]=XSIGN.XMASeries(StartBarsD,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,WPR[bar],bar,false);
     }

//---- main loop of the signal line coloring
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorXWPR[bar]=0;
      if(XWPR[bar]>XWPR[bar-1]) ColorXWPR[bar]=1;
      if(XWPR[bar]<XWPR[bar-1]) ColorXWPR[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
