//+------------------------------------------------------------------+
//|                                                 R-Squared_v1.mq5 |
//|                                Copyright © 2006, TrendLaboratory | 
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2006, TrendLaboratory"
//---- author of the indicator
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| R-Squared_v1 indicator drawing parameters    |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- MediumVioletRed color is used as the color of the indicator basic line
#property indicator_color1  clrMediumVioletRed
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "R-Squared_v1"
//+----------------------------------------------+
//| Signal line drawing parameter                |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- MediumSlateBlue color is used for the indicator signal line
#property indicator_color2  clrMediumSlateBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 50.0
#property indicator_levelcolor clrLimeGreen
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0       // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint                nLength = 12;             // indicator period
input uint              MA_Period = 5;              // moving average period
input ENUM_MA_METHOD    MA_Method = MODE_SMA;       // moving average smoothing method
input ENUM_APPLIED_PRICE MA_Price = PRICE_WEIGHTED; // price constant
input uint                 Smooth = 14;             // moving period
input int                   Shift = 0;              // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
double SignalBuffer[];
//---- declaration of integer variables for the indicators handles
int MA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_,min_rates_total,Length;
double SumX,SumX2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_=int(MathMax(MathMax(MA_Period,nLength),Smooth));
   Length=int(nLength);
   min_rates_total=int(min_rates_+Length+Smooth);
   
   SumX=0;
   for(int i=0; i<Length; i++) SumX+=i+1;

   SumX2=0;
   for(int i=0; i<Length; i++) SumX2+=MathPow(i+1,2);

//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,MA_Period,0,MA_Method,MA_Price);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return(1);
     }

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(IndBuffer,true);

//---- set SignalBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(SignalBuffer,true);

//---- initializations of variable for indicator short name
   string shortname="R-Squared_v1";
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determine the accuracy of displaying indicator values
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
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double SumY,SumY2,SumXY,Q1,Q2,Q3,res,SumR,MA[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(MA,true);

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_;   // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----   
   to_copy=MathMin(limit+Length,rates_total);
   
//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SumY=0;
      for(int i=0; i<Length; i++) SumY+=MA[bar+i];
 
      SumY2=0;
      for(int i=0; i<Length; i++) SumY2+=MathPow(MA[bar+i],2);

      SumXY=0;
      for(int i=0; i<Length; i++) SumXY+=(i+1)*MA[bar+i];

      Q1=SumXY-SumX*SumY/Length;
      Q2=SumX2-SumX*SumX/Length;
      Q3=SumY2-SumY*SumY/Length;
      res=Q2*Q3;

      if(res) IndBuffer[bar]=100*Q1*Q1/res;
      else IndBuffer[bar]=0.0;

      SumR=0;
      for(int i=0; i<int(Smooth); i++) SumR+=IndBuffer[bar+i];
      SignalBuffer[bar]=SumR/Smooth;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
