//+---------------------------------------------------------------------+
//|                                                           Fast2.mq5 | 
//|                                             Copyright © 2008, xrust | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, xrust"
#property link ""
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//----three buffers are used for calculation of drawing of the indicator
#property indicator_buffers 3
//---- three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color1 clrBlueViolet
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Fast2 HISTOGRAM"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- color is used for the color of the indicator line
#property indicator_color2 clrTeal
//---- indicator line is a solid curve
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 1
#property indicator_width2 1
//---- displaying the signal line label
#property indicator_label2  "Fast Signal"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//---- color is used for the color of the indicator line
#property indicator_color3 clrRed
//---- indicator line is a solid curve
#property indicator_style3 STYLE_SOLID
//---- indicator line width is 1
#property indicator_width3 1
//---- displaying the signal line label
#property indicator_label3  "Slow Signal"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_LWMA; // Method of averaging of the first smoothing 
input uint Length1=3;                     // Depth of the first smoothing                    
input int  Phase1=15;                     // Parameter o the first smoothing,
// for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_LWMA; // Method of averaging of the second smoothing 
input uint Length2=9;                     // Depth of the second smoothing 
input int  Phase2=15;                     // Parameter of the second smoothing,
// for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double HistBuffer[],Sign1Buffer[],Sign2Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   int min_rates_1=XMA1.GetStartBars(MA_Method1,Length1,Phase1);
   int min_rates_2=XMA2.GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=min_rates_1+min_rates_2+2;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1",Length1);
   XMA2.XMALengthCheck("Length2",Length2);

//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);
   XMA2.XMAPhaseCheck("Phase2",Phase2,MA_Method2);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,HistBuffer,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,Sign1Buffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,Sign2Buffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- Initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"Fast2(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=2;                 // starting index for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting index for calculation of new bars
     }

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      HistBuffer[bar]=(close[bar]-open[bar]+((close[bar-1]-open[bar-1])/MathSqrt(2))+((close[bar-2]-open[bar-2])/MathSqrt(3)))/_Point;

      //---- two calls of the XMASeries function. 
      Sign1Buffer[bar]=XMA1.XMASeries(2,prev_calculated,rates_total,MA_Method1,Phase1,Length1,HistBuffer[bar],bar,false);
      Sign2Buffer[bar]=XMA2.XMASeries(2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,HistBuffer[bar],bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
