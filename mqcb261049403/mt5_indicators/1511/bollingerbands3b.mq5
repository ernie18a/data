//+------------------------------------------------------------------+
//|                                             BollingerBands%b.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                                    Modified by Alejandro Galindo |
//|                                                                  |
//|                                           You are free to use it |
//|                                                                  |
//|      If you want and if this work/modification is helpful to you |
//|             you can send me a PayPal donation to ag@elcactus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- clrMediumSlateBlue color is used as the color of the bullish line of the indicator
#property indicator_color1 clrMediumSlateBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1 1
//---- displaying the indicator label
#property indicator_label1  "Bollinger Bands% b"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint BBPeriod=20;                              //middle line calculation period
input double StdDeviation=2;                         //deviation
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; //price type
input int Shift=0;                                   //horizontal shift of the indicator in bars
//+-----------------------------------+
//---- Declaration of integer variables for the indicator handles
int Ind_Handle;
//---- indicator buffer
double IndBuffer[];
//---- Declaration of global variables
int min_rates_total;
//+------------------------------------------------------------------+    
//| Bollinger Bands% b indicator initialization function             | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(BBPeriod);
   
//---- getting handle of the iBands indicator
   Ind_Handle=iBands(NULL,0,BBPeriod,0,StdDeviation,applied_price);
   if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of iBands indicator");
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);
   
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Bollinger Bands% b",BBPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Bollinger Bands% b iteration function                            | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double UpBB[],DnBB[];

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(close[bar]-UpBB[bar])/(DnBB[bar]-UpBB[bar]);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
