//+------------------------------------------------------------------+
//|                                                 iSmoothLines.mq5 |
//|                                            Copyright 2012, Lizar |
//|                              https://www.mql5.com/en/users/lizar |
//+------------------------------------------------------------------+
#define VERSION       "1.00" // Build 1 (05 Apr 2012)

#property copyright   "Copyright 2012, Lizar"
#property link        "https://www.mql5.com/en/users/lizar"
#property version     VERSION
#property description "Smooth lines for iCustomChart"

/*------------------------------------------------------------------+/
Description.
1. The indicator shows the application of the free 
   LibCustomChart library for automatic connection of the indicators to 
   iCustomChart custom charts created on the basis of 
   custom history files.  
2. The presence of iCustomChart custom chart is checked
   when attaching the indicator to a chart window. In case a custom 
   chart has been uploaded, the library functions use the data of that 
   chart. Otherwise, the data of a standard chart is used.
   Therefore, the indicator can work both with 
   custom and standard charts without the need for any changes.   
   
Instructions:
1. Download LibCustomChart.ex5 library file and place it to the
   terminal_data_folder\MQL5\Libraries
2. Download the file containing the library functions description LibCustomChart.mqh and 
   place it to the terminal_data_folder\MQL5\Include
3. Download Nikolay Kositsin's file containing the description of SmoothAlgorithms.mqh smoothings classes 
   SmoothAlgorithms.mqh and place it to the 
   terminal_data_folder\MQL5\Include
4. Download iSmoothLines.mq5 file and place it to the 
   terminal_data_folder\MQL5\Indicators
5. Download iSmoothLines.mq5 to MetaEditor and compile (F7)
6. iSmoothLines.ex5 indicator can be launched both on a standard and 
   custom chart created with the use of 
   iCustomChart.
7. The following steps must be executed to upload the indicator on a custom chart:
   - download demo or full version of iCustomChart and 
     attach it to any chart window;
   - then attach iSmoothLines to the same window. iSmoothLines 
     will automatically detect the presence of iCustomChart and 
     get calculation data from it. 
Links:
1. LibCustomChart library:
   http://www.mql5.com/en/market/product/196
2. Included file containing the library functions description (LibCustomChart.mqh):
   http://mql5.com/en/code/869
3. iCustomChart demo version:
   http://www.mql5.com/en/market/product/203
4. iCustomChart full version:
   http://www.mql5.com/en/market/product/186
5. Nikolay Kositsin's SmoothAlgorithms.mqh included file containing the description of 
   smoothings classes:
   http://www.mql5.com/en/code/869
/+------------------------------------------------------------------*/
//--- the file containing the LibCustomChart library functions description:
#include <LibCustomChart.mqh>
//--- smoothings classes description file:
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//|  Indicator drawing parameters                                    |
//+------------------------------------------------------------------+
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- 2 buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//--- one plot is used
#property indicator_plots   1
//--- color line is used for display
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  SlateBlue, Magenta
//--- dynamic arrays for the indicator buffers
double ExtIndicatorBuffer[];
double ExtColorBuffer[];
//+------------------------------------------------------------------+
//| Indicator input parameters                                       |
//+------------------------------------------------------------------+
input Smooth_Method MA_SMethod=MODE_LWMA; // Smoothing method
input int MA_Length=30;                   // Smoothing depth                    
input int MA_Phase=100;                   // Smoothing parameter
                                          // that changes within the range -100 ... +100 for JJMA
                                          // for VIDIA it is a CMO period, for AMA it is a slow average period

//+------------------------------------------------------------------+
//| Indicator global variables                                       |
//+------------------------------------------------------------------+
//--- declaration of the CXMA class variable from the SmoothAlgorithms.mqh file
CXMA ind;
//---
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   StartBars=ind.GetStartBars(MA_SMethod,MA_Length,MA_Phase)+1;

//--- setting up alerts for unacceptable values of external variables
   ind.XMALengthCheck("Length", MA_Length);
   ind.XMAPhaseCheck ("Phase", MA_Phase, MA_SMethod);

//--- set ExtIndicatorBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtIndicatorBuffer,INDICATOR_DATA);
//--- set ExtColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name=EnumToString(MA_SMethod)+"("+(string)MA_Length+","+(string)MA_Phase+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- connecting the indicator to iCustomChart using the library function:
   return(!CustomChartInit());
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- updating custom chart data using the library 
//    function: 
   if(!CustomChartRefresh()) return (0);

//--- checking the number of custom chart bars to be enough for the
//    calculation using the library function:
   if(CustomChartBars()<StartBars) return(0);

//--- indicators buffers synchronization with a custom chart
//    using the library function
   if(!CustomChartSync(ExtIndicatorBuffer))  return (prev_calculated);
   if(!CustomChartSync(ExtColorBuffer))      return (prev_calculated);

//--- declarations of local variables 
   int      first;                  // starting index for calculation of all bars
   int      bar;                    // current bar index for the indicator calculation
   int      custom_begin;           // the index of the first significant bar of the custom chart
   int      custom_prev_calculated; // number of custom chart bars calculated at previous call
   double   custom_price[1];        // the array for getting a custom chart open prices
   
//--- getting custom chart data using the library
//    function:
   custom_begin=CustomChartBegin();
   custom_prev_calculated=rates_total-CustomChartNewBar();
      
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=custom_begin) // checking for the first start of the indicator calculation
     {
      first=custom_begin; // starting index for calculation of all bars
      //---- setting of the indicator drawing start 
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,custom_begin+StartBars);
     }  
   else  first=custom_prev_calculated-1; // starting index for calculation of new bars
   
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- getting Open price of a custom chart using the library function:
      if(CopyClose(rates_total-1-bar,1,custom_price)!=1) custom_price[0]=EMPTY_VALUE;
      //--- XMASeries function call:
      ExtIndicatorBuffer[bar]=ind.XMASeries(custom_begin, custom_prev_calculated, rates_total, MA_SMethod, MA_Phase, MA_Length, custom_price[0], bar, false);
      //--- coloring the indicator line from the first significant indicator bar:
      if(bar<=custom_begin+StartBars) continue;
      if(ExtIndicatorBuffer[bar-1]<ExtIndicatorBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else  ExtColorBuffer[bar]=1.0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+