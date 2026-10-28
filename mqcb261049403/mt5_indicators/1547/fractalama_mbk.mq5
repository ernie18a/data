//+----------------------------------------------------------------------------------+
//| FractalAMA                                                                       |
//|                                                                                  |
//| Description:  Fractal Adaptive Moving Average - by John Ehlers                   |
//|               Version 1.1 7/17/2006                                              |
//|                                                                                  |
//| Heavily modified and reprogrammed by Matt Kennel (mbkennelfx@gmail.com)          |
//|                                                                                  |
//| Notes:                                                                           |
//|               October 2005 Issue - "FRAMA - Fractal Adaptive Moving Average"     |
//|               Length will be forced to be an even number.                        |
//|               Odd numbers will be bumped up to the                               |
//|               next even number.                                                  |
//| Formula Parameters:     Defaults:                                                |
//| RPeriod                 16                                                       |
//+----------------------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, MrPip"
//---- author of the indicator
#property link      "mbkennelfx@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  FractalAMA indicator drawing parameters     |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DarkOrange color is used as the color of the line of the indicator
#property indicator_color1  clrDarkOrange
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "FractalAMA"
//+----------------------------------------------+
//|  Trigger indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- SlateBlue color is used for indicator line
#property indicator_color2  clrSlateBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RPeriod=16;
input double multiplier=4.6;
input double signal_multiplier=2.5;
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double FrAmaBuffer[];
double TriggerBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total,N;
//+------------------------------------------------------------------+
//|  Range()                                                         |
//+------------------------------------------------------------------+   
double Range(int index,const double &Low[],const double &High[],int period)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   return(High[ArrayMaximum(High,index,period)]-Low[ArrayMinimum(Low,index,period)]);
//----
  }
//+------------------------------------------------------------------+
//|  DEst()                                                          |
//+------------------------------------------------------------------+   
double DEst(int index,const double &Low[],const double &High[],int period)
  {
   double R1,R2,R3;
   int n2=period/2;
//----
   R3=Range(index,Low,High,period)/period;
   R1=Range(index,Low,High,n2)/n2;
   R2=Range(index+n2,Low,High,n2)/n2;
   return((MathLog(R1+R2)-MathLog(R3)) *1.442695);// log_2(e) = 1.442694
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(RPeriod);
   N=int(MathFloor(RPeriod/2)*2);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,FrAmaBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(FrAmaBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(TriggerBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"FractalAMA(",RPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar;
   double dimension_estimate,alpha,alphas;
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);


//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      int start=limit+1;
      FrAmaBuffer[start]=close[start];
      TriggerBuffer[start]=close[start];
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars


//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      dimension_estimate=DEst(bar,low,high,N);
      alpha=MathExp(-multiplier*(dimension_estimate-1.0));
      alphas=MathExp(-signal_multiplier*(dimension_estimate-1.0));
      //----
      alpha=MathMin(alpha,1.0);
      alpha=MathMax(alpha,0.01);
      //----
      FrAmaBuffer[bar]=alpha*close[bar]+(1.0-alpha) *FrAmaBuffer[bar+1];     
      TriggerBuffer[bar]=alphas*FrAmaBuffer[bar]+(1.0-alphas)*TriggerBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
