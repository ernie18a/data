//+------------------------------------------------------------------+
//|                                                    Asymmetry.mq5 |
//|                                  Copyright © 2008, Fedor Igumnov |
//|                                           igumnovfedor@yandex.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008,Fedor Igumnov"
//---- link to the website of the author
#property link      "igumnovfedor@yandex.ru"
#property description "The asymmetry indicator"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 1
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- MediumSlateBlue color is used as the color of the line
#property indicator_color1 clrMediumSlateBlue
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying label of the signal line
#property indicator_label1  "Asymmetry"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint AsPeriod=30; //indicator period
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double ExtLineBuffer[];
//----Declaration of variables for storing the indicators handles
int RSI_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- getting the ATR indicator handle
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,AsPeriod,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRSI indicator");

//---- Initialization of variables of the start of data calculation
   min_rates_total=int(AsPeriod);
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Asymmetry(",AsPeriod," ",Shift,")");
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtLineBuffer,true);
//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,i;
   double RSI[],M,D,MD,stdDev;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=int(limit+1+AsPeriod);

//--- copy newly appeared data in the array
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);

//---- indexing elements in the array as timeseries  
   ArraySetAsSeries(RSI,true);
   
//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      M=0.0;
      D=0.0;
      MD=0.0;
      
      for(i=0; i<int(AsPeriod); i++) M+=RSI[bar+i];

      M/=AsPeriod;
      for(i=0; i<int(AsPeriod); i++) D+=MathPow(RSI[bar+i]-M,2);

      D/=AsPeriod;
      stdDev=MathSqrt(D);
      for(i=0; i<int(AsPeriod); i++) MD+=MathPow(RSI[bar+i]-D,2);

      MD/=AsPeriod;
      ExtLineBuffer[bar]=MathAbs(MD/(D*stdDev));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
