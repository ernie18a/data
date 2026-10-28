//+------------------------------------------------------------------+
//|                                          StochasticExpansion.mq5 |
//|                                  Copyright © 2010, Ivan Kornilov |
//|                                     StochasticExpansion_v1.1.mq4 |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| in the directory: MetaTrader\MQL5\Include                        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov."
#property link "excelf@gmail.com"
#property version   "1.10"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- 2 buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used in a three-colored line
#property indicator_color1  Gray,Magenta,DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "StochasticExpansion"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int KPeriod = 13;
input int Slowing = 6;
input int NoiseFilter=6;
input Smooth_Method Filter_Method=MODE_SMA; // Smoothing method                   
input int Filter_Phase=15;                  // Smoothing parameter
input int Shift=0;                          // Horizontal shift in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtLineBuffer[];
double ColorExtLineBuffer[];
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double Lowest[],Highest[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_total_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total_1=KPeriod+Slowing;
   min_rates_total=min_rates_total_1+XMA1.GetStartBars(Filter_Method,NoiseFilter,Filter_Phase)+1;
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("KPeriod", KPeriod);
   XMA1.XMALengthCheck("Slowing", Slowing);
   XMA1.XMALengthCheck("NoiseFilter", NoiseFilter);
   XMA1.XMAPhaseCheck("Filter_Phase", Filter_Phase, Filter_Method);

//---- memory distribution for variables' arrays
   if(ArrayResize(Count,Slowing)<Slowing) Print("Failed to distribute the memory for Count[] array");
   if(ArrayResize(Lowest,Slowing)<Slowing) Print("Failed to distribute the memory for Lowest[] array");
   if(ArrayResize(Highest,Slowing)<Slowing) Print("Failed to distribute the memory for Highest[] array");

//---- set ExtLineBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- set ColorExtLineBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ColorExtLineBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"StochasticExpansion(",KPeriod," ,",Slowing," ,",NoiseFilter," ,",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----
  }
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CountArray[],// return the current value of the price series by the link
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
      CountArray[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,bar,maxbar;
   double KLine1=0,KLine2=0,KLine,value;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total_1-1; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;     // starting index for calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//----  
   maxbar=rates_total-min_rates_total_1-1;

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Lowest[Count[0]]=low[ArrayMinimum(low,bar,KPeriod)];
      Highest[Count[0]]=high[ArrayMaximum(high,bar,KPeriod)];

      if(bar>maxbar)
        {
         ExtLineBuffer[bar]=EMPTY_VALUE;
         ColorExtLineBuffer[bar]=0;
         Recount_ArrayZeroPos(Count,Slowing);
         continue;
        }

      double sumlow=0;
      double sumhigh=0;

      for(int k=0; k<Slowing; k++)
        {
         int bark=bar+k;
         int r=Count[k];
         sumlow += close[bark] - Lowest[r];
         sumhigh+= Highest[r] - close[bark];
        }

      if(sumhigh) KLine1=+sumlow/sumhigh;
      if(sumlow)  KLine2=-sumhigh/sumlow;
      KLine=KLine1+KLine2;
      ExtLineBuffer[bar]=KLine;
      value=XMA1.XMASeries(maxbar,prev_calculated,rates_total,Filter_Method,Filter_Phase,NoiseFilter,KLine,bar,true);

      if(KLine<value) ColorExtLineBuffer[bar]=1;
      else if(KLine>value) ColorExtLineBuffer[bar]=2;
      else ColorExtLineBuffer[bar]=0;

      if(bar) Recount_ArrayZeroPos(Count,Slowing);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
