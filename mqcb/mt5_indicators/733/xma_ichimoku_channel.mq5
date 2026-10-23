//+------------------------------------------------------------------+
//|                                 XMA_Ichimoku_Convert_Channel.mq5 |
//|                                        Copyright © 2010, ellizii |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, ellizii"
#property link ""
#property description "XMA Ichimoku Convert Channel"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color1 Blue
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Ichimoku XMA"
//+--------------------------------------------+
//|  Levels drawing parameters                 |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of levels colors
#property indicator_color2  MediumSeaGreen
#property indicator_color3  Red
//---- levels are dott-dash curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- display levels labels
#property indicator_label2  "Up Ichimoku Convert"
#property indicator_label3  "Down Ichimoku Convert"
//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum MODE_PRICE  // Type of constant
  {
   OPEN = 0,     // By open prices
   LOW,          // By lows
   HIGH,         // By highs
   CLOSE         // By close prices
  };
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
input uint Up_period=3; // High price calculation period
input uint Dn_period=3; // Low price calculation period
//---- 
extern MODE_PRICE Up_mode=HIGH;  // Highs searching prices 
extern MODE_PRICE Dn_mode=LOW;   // Lows searching prices 
//---- 
input Smooth_Method XMA_Method=MODE_SMA; // Smoothing method
input int XLength=100;                   // Smoothing depth                    
input int XPhase=15;                     // Smoothing parameter

input double Up_percent = 1.0; // Percentage of the deviation from the average for building the channel upper border
input double Dn_percent = 1.0; // Percentage of the deviation from the average for building the channel lower border
//---- 
input int Shift=0;      // Horizontal shift of the indicator in bars
input int PriceShift=0; // Vertical shift of the indicator in points
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double XMA[];
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double UpLineBuffer[],DnLineBuffer[];
//---- declaration of the average vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1;
//+------------------------------------------------------------------+   
//| XMA_Ichimoku_Convert_Channel indicator initialization function   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation

   StartBars1=int(MathMax(Up_period,Dn_period));
   StartBars=StartBars1+XMA1.GetStartBars(XMA_Method,XLength,XPhase);

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);

//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set XMA[] dynamic array as an indicator buffer
   SetIndexBuffer(0,XMA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(XMA,true);

//---- set UpLineBuffer[] and DnLineBuffer[] dynamic arrays into indicator buffers
   SetIndexBuffer(1,UpLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnLineBuffer,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(UpLineBuffer,true);
   ArraySetAsSeries(DnLineBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XMA Ichimoku Convert Channel(",XLength,", ",XPhase,", ",Smooth,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+
//| Searching for highs                                              |
//+------------------------------------------------------------------+
int FindMaximum(const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                MODE_PRICE Mode,
                uint index,
                uint period)
  {
//----
   int max=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: max=ArrayMaximum(Open,index,period); break;
      case LOW: max=ArrayMaximum(Low,index,period); break;
      case HIGH: max=ArrayMaximum(High,index,period); break;
      case CLOSE: max=ArrayMaximum(Close,index,period); break;
     }

//----
   return(max);
  }
//+------------------------------------------------------------------+
//| Searching for lows                                               |
//+------------------------------------------------------------------+
int FindMinimum(const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                MODE_PRICE Mode,
                uint index,
                uint period)
  {
//----
   int min=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: min=ArrayMinimum(Open,index,period); break;
      case LOW: min=ArrayMinimum(Low,index,period); break;
      case HIGH: min=ArrayMinimum(High,index,period); break;
      case CLOSE: min=ArrayMinimum(Close,index,period); break;
     }

//----
   return(min);
  }
//+------------------------------------------------------------------+ 
//| XMA_Ichimoku_Convert_Channel iteration function                  | 
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
   double Ich_Up,Ich_Dn;
//---- declaration of integer variables
   int limit,maxbar;

   maxbar=rates_total-1-StartBars1;
//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=maxbar;                         // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ich_Up=high[FindMaximum(open,high,low,close,Up_mode,bar,Up_period)];
      Ich_Dn=low[FindMinimum(open,high,low,close,Dn_mode,bar,Dn_period)];
      XMA[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,(Ich_Up+Ich_Dn)/2,bar,true)+PriceShift;
      UpLineBuffer[bar]=(1+(Up_percent/100))*XMA[bar];
      DnLineBuffer[bar]=(1-(Dn_percent/100))*XMA[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
