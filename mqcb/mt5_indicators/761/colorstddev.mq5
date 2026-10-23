//+------------------------------------------------------------------+ 
//|                                                  ColorStdDev.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used for the indicator diagram
#property indicator_color1 Gray,Blue,Red,Magenta
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "StdDev"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int period = 12;                              // Smoothing period
input ENUM_MA_METHOD MA_Method=MODE_EMA;            // Histogram smoothing method
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE;// Applied price
input int MaxTrendLevel=100;                        // Maximum trend level
input int MiddLeTrendLevel=40;                      // Middle trend level
input int FlatLevel=10;                             // Flat level
//+-----------------------------------+
//---- indicator buffers
double StdDevBuffer[],ColorBuffer[];
//---- declaration of integer variables for the indicators handles
int StdDev_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total; 
//+------------------------------------------------------------------+    
//| StdDev indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=period;
   
//---- getting handle of the StdDev indicator
   StdDev_Handle=iStdDev(NULL,0,period,0,MA_Method,applied_price);
   if(StdDev_Handle==INVALID_HANDLE) Print(" Failed to get handle of the StdDev indicator");
   
//---- set StdDevBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,StdDevBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(StdDevBuffer,true);

//---- set ColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ColorBuffer,true);
   
//---- initializations of a variable for the indicator short name
   string shortname;  
   StringConcatenate(shortname,"ColorStdDev( ",period," )");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,MaxTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddLeTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,FlatLevel);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Blue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Gray);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| StdDev iteration function                                        | 
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
   if(BarsCalculated(StdDev_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of integer variables
   int limit,to_copy,bar;
//---- declaration of variables with a floating point  
   double StdDev[];

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(StdDev,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
        limit=rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(StdDev_Handle,0,0,to_copy,StdDev)<=0) return(0);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      StdDevBuffer[bar]=StdDev[bar]/_Point;
      ColorBuffer[bar]=0;     
      if(StdDevBuffer[bar]>MaxTrendLevel) ColorBuffer[bar]=3;
      else if(StdDevBuffer[bar]>MiddLeTrendLevel) ColorBuffer[bar]=2;
      else if(StdDevBuffer[bar]>FlatLevel) ColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
