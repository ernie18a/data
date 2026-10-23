//+------------------------------------------------------------------+
//|                                                  iFXAnalyser.mq5 |
//|                           Copyright © 2006, Renato P. dos Santos |
//|                   inspired on 4xtraderCY's and SchaunRSA's ideas |
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=16086 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Renato P. dos Santos"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=16086"
//--- indicator version
#property version   "1.00"
//--- indicator description
#property description ""
//--- drawing the indicator in a separate window
#property indicator_separate_window  
//--- three buffers are used for the indicator calculation and drawing
#property indicator_buffers 3
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Upper line 1 drawing parameters             |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color1  clrBlue
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Div"
//+----------------------------------------------+
//| Line 2 drawing parameters                    |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- red color is used as the color of the indicator line
#property indicator_color2  clrRed
//--- the line of the indicator 2 is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2  "Slope"
//+----------------------------------------------+
//| Line 3 drawing parameters                    |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- green color is used as the color of the indicator bearish line
#property indicator_color3  clrGreen
//--- the line of the indicator 3 is a continuous curve
#property indicator_style3  STYLE_SOLID
//--- indicator 3 line width is equal to 1
#property indicator_width3  1
//--- display of the bearish indicator label
#property indicator_label3  "Acel"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint                FastMAPeriod=4;
input  ENUM_MA_METHOD     FastMAType=MODE_SMA;
input ENUM_APPLIED_PRICE  FastMAPrice=PRICE_CLOSE;
input uint                SlowMAPeriod=6;
input  ENUM_MA_METHOD     SlowMAType=MODE_SMA;
input ENUM_APPLIED_PRICE  SlowMAPrice=PRICE_CLOSE;
input int    Shift=0;  // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
//--- Declaration of integer variables of data starting point
int min_rates_total;
//--- Declaration of integer variables for the indicator handles
int FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(FastMAPeriod,SlowMAPeriod)+4);
//--- getting the handle of the Fast iMA indicator
   FsMA_Handle=iMA(_Symbol,PERIOD_CURRENT,FastMAPeriod,0,FastMAType,FastMAPrice);
   if(FsMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the Fast iMA indicator");
      return(INIT_FAILED);
     }
//--- getting the handle of the Slow iMA indicator
   SlMA_Handle=iMA(_Symbol,PERIOD_CURRENT,SlowMAPeriod,0,SlowMAType,SlowMAPrice);
   if(SlMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the Slow iMA indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind1Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Ind2Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind2Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,Ind3Buffer,INDICATOR_DATA);
//--- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind3Buffer,true);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"i-iFXAnalyser(",FastMAPeriod,",",SlowMAPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double FsMA[],SlMA[];
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+4;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FsMA)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlMA)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(FsMA,true);
   ArraySetAsSeries(SlMA,true);
//--- main calculation loop of the indicator
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      Ind1Buffer[bar]=FsMA[bar]-SlMA[bar];
      double diff=FsMA[bar+1]-SlMA[bar+1];
      Ind2Buffer[bar]=Ind1Buffer[bar]-diff;
      Ind3Buffer[bar]=Ind2Buffer[bar]-diff-(FsMA[bar+2]-SlMA[bar+2]);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
