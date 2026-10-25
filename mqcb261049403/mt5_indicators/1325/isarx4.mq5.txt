//+------------------------------------------------------------------+
//|                                                       iSarX4.mq5 |
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 1 as a label
#property indicator_type1   DRAW_ARROW
//---- blue color is used for the indicator line
#property indicator_color1  clrBlue
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "iSar 1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- magenta color is used for the indicator line
#property indicator_color2  clrMagenta
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "iSar 2"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color3  clrLime
//---- indicator 3 width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "iSar 3"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color4  clrRed
//---- indicator 4 width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "iSar 4"
//+----------------------------------------------+ 
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0  // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input double Start_Step=0.002;    // Step for the lowest indicator
input double Step_Shift=0.002;    // Step changing size
input double Maximum=0.2;        // Maximum for all indicators
input int    Shift=0;            // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int Sar1_Handle,Sar2_Handle,Sar3_Handle,Sar4_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables    
   min_rates_total=3;

//---- getting the Sar1 indicator handle
   Sar1_Handle=iSAR(NULL,PERIOD_CURRENT,Start_Step,Maximum);
   if(Sar1_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Sar1 indicator");
      return(1);
     }
     
//---- getting the Sar2 indicator handle
   Sar2_Handle=iSAR(NULL,PERIOD_CURRENT,Start_Step+1*Step_Shift,Maximum);
   if(Sar2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Sar2 indicator");
      return(1);
     }
     
//---- getting the Sar3 indicator handle
   Sar3_Handle=iSAR(NULL,PERIOD_CURRENT,Start_Step+2*Step_Shift,Maximum);
   if(Sar3_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Sar3 indicator");
      return(1);
     }
     
//---- getting the Sar4 indicator handle
   Sar4_Handle=iSAR(NULL,PERIOD_CURRENT,Start_Step+3*Step_Shift,Maximum);
   if(Sar4_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Sar4 indicator");
      return(1);
     }

//---- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBuffer3,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer3,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBuffer4,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer4,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"iSarX4(",DoubleToString(Start_Step,3),", ",
            DoubleToString(Step_Shift,3),", ",DoubleToString(Maximum,3),", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(Sar1_Handle)<rates_total
      || BarsCalculated(Sar2_Handle)<rates_total
      || BarsCalculated(Sar3_Handle)<rates_total
      || BarsCalculated(Sar4_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      to_copy=rates_total;                    // number of copied data for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+1;  // number of copied data for calculation of all bars
     }
     
//---- copy newly appeared data into the arrays
   if(CopyBuffer(Sar1_Handle,0,0,to_copy,ExtMapBuffer1)<=0) return(RESET);
   if(CopyBuffer(Sar2_Handle,0,0,to_copy,ExtMapBuffer2)<=0) return(RESET);
   if(CopyBuffer(Sar3_Handle,0,0,to_copy,ExtMapBuffer3)<=0) return(RESET);
   if(CopyBuffer(Sar4_Handle,0,0,to_copy,ExtMapBuffer4)<=0) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
