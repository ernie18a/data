//+------------------------------------------------------------------+
//|                                                       KPrmSt.mq5 |
//|                                         Copyright © 2010, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, LeMan."
#property link      "b-market@mail.ru"
#property description "Stochastic of Cynthia Case"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| KPrmSt indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- MediumVioletRed color is used as the color of the indicator basic line
#property indicator_color1  clrMediumVioletRed
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the indicator line label
#property indicator_label1  "KPrmSt"
//+----------------------------------------------+
//| Signal line drawing parameters               |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- DodgerBlue color is used for the indicator signal line
#property indicator_color2  clrDodgerBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the indicator line label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Indicator window sizes parameters            |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0       // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint  Per1=14;
input uint  Per2=3;
input uint  Per3=3;
input uint  Per4=5;
input uint  Shift=0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double IndBuffer[];
double SignalBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of global variables
int Count[];
double MaxArray[],MinArray[];
//+------------------------------------------------------------------+
// Moving_Average class description                                  | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by the link
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(Per1,Per4))+2;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,Per1);
   ArrayResize(MaxArray,Per1);
   ArrayResize(MinArray,Per1);
   
   ArrayInitialize(Count,0);
   ArrayInitialize(MaxArray,0.0);
   ArrayInitialize(MinArray,0.0);

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- set SignalBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SignalBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"KPrmSt(",Per1,", ",Per2,", ",Per3,", ",Per4,", ",Shift,")");
//---- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- set accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
   return(0);
//----
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,maxbar,sh,sl,start1,start2;
   double res,Range,ind,sig;

   maxbar=int(rates_total-Per1-1);
   start1=int(maxbar-Per4);
   start2=start1-1;
//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
        limit=int(rates_total-Per4-1); // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   
   //---- declaration of the CMoving_Average class variables from the MASeries_Cls.mqh file
   static CMoving_Average IND,SIG;

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {      
      MaxArray[Count[0]]=high[ArrayMaximum(high,bar,Per4)];
      MinArray[Count[0]]=low [ArrayMinimum(low, bar,Per4)];
      
      if(bar>maxbar){Recount_ArrayZeroPos(Count,Per1); continue;}
      
      sh = ArrayMaximum(MaxArray,0,WHOLE_ARRAY);
      sl = ArrayMinimum(MinArray,0,WHOLE_ARRAY);
      
      Range=MaxArray[sh]-MinArray[sl];
      
      if(Range) res=NormalizeDouble((close[bar]-MinArray[sl])/(Range)*100,0);
      else res=50;
      
      ind=IND.EMASeries(start1,prev_calculated,rates_total,Per2,res,bar,true);
      sig=SIG.EMASeries(start2,prev_calculated,rates_total,Per3,ind,bar,true);

      IndBuffer[bar]=NormalizeDouble(ind,0);
      SignalBuffer[bar]=NormalizeDouble(sig,0);

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,Per1);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
