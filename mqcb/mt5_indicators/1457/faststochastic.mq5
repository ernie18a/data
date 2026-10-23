//+---------------------------------------------------------------------+
//|                                                  FastStochastic.mq5 |
//|                                                 Copyright © 2012, . |
//|                                         https://www.metaquotes.net/ |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "https://www.metaquotes.net/"
#property description "Fast stochastic, created as a color histogram"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 5 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- the following colors are used in the histogram
#property indicator_color1 clrGray,clrLimeGreen,clrTeal,clrCrimson,clrPurple
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "Main"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator as a three-colored line
#property indicator_type2   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color2 clrGray,clrBlue,clrMagenta
//---- the indicator line is a stroke
#property indicator_style2  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  70.0
#property indicator_level2  50.0
#property indicator_level3  30.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
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
input int InpKPeriod=5;  // K period
input Smooth_Method XMA_Method=MODE_SMA; //signal line smoothing method
input uint InpDPeriod=3;  // D period               
input int XPhase=15; //signal line smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; //horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpSTOH[],DnSTOH[],SIGN[];
double ColorSTOH[],ColorSIGN[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| STOH indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=InpKPeriod;
   min_rates_total=min_rates_+1+XMA1.GetStartBars(XMA_Method,InpDPeriod,XPhase);;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSTOH,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpSTOH,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSTOH,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DnSTOH,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorSTOH,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorSTOH,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,SIGN,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SIGN,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ColorSIGN,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorSIGN,true);

//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"FastStochastic("+(string)InpKPeriod+","+(string)InpDPeriod+")");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| STOH iteration function                                          | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- Declaration of integer variables
   int limit,bar,maxbar;
//---- declaration of variables with a floating point  
   double HH,LL,Range,Main,Price;
   static double Prev_Main;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_; // starting index for the calculation of all bars
      Prev_Main=50;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   maxbar=rates_total-min_rates_;
   Main=Prev_Main;

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,InpKPeriod)];
      LL=low [ArrayMinimum(low, bar,InpKPeriod)];
      Range=MathMax(_Point*1,HH-LL);
      Price=PriceSeries(IPC,bar,open,low,high,close);
      Main=100*(Price-LL)/Range;
      SIGN[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,InpDPeriod,Main,bar,true);

      if(Main<50)
        {
         DnSTOH[bar]=Main;
         UpSTOH[bar]=50;
        }
      else
        {
         UpSTOH[bar]=Main;
         DnSTOH[bar]=50;
        }

      //---- Stoh indicator coloring
      ColorSTOH[bar]=0;
            
      if(Main>50)
        {
         if(Main>Prev_Main) ColorSTOH[bar]=1;
         if(Main<Prev_Main) ColorSTOH[bar]=2;
        }

      if(Main<50)
        {
         if(Main<Prev_Main) ColorSTOH[bar]=3;
         if(Main>Prev_Main) ColorSTOH[bar]=4;
        }

      //---- signal line coloring
      ColorSIGN[bar]=0;
      if(Main>SIGN[bar+1]) ColorSIGN[bar]=1;
      if(Main<SIGN[bar+1]) ColorSIGN[bar]=2;
      
      if(bar) Prev_Main=Main;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
