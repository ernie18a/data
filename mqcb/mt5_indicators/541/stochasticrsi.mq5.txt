//+---------------------------------------------------------------------+
//|                                                   StochasticRSI.mq5 |
//|                                                                     |
//| StochasticRSI                                                       |
//|                                                                     |
//| Algorithm taken from book                                           |
//|     "Cybernetics Analysis for Stock and Futures"                    |
//| by John F. Ehlers                                                   |
//|                                                                     |
//|                                                 contact@mqlsoft.com |
//|                                             http://www.mqlsoft.com/ |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Coded by Witold Wozniak"
//---- author of the indicator
#property link      "www.mqlsoft.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  StoRSI indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used for the indicator line
#property indicator_color1  Red
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Stochastic RSI"
//+----------------------------------------------+
//|  Trigger indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator signal line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator signal line label
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.7
#property indicator_level2 0.5
#property indicator_level3 0.3
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator window size limitation             |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 1
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int RSILength=8;
input int StocLength= 8;
input int WMALength = 8;
input int Shift=0;      // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that 
//---- will be used as indicator buffers
double StoRSIBuffer[];
double TriggerBuffer[];
//---- declaration of integer variables for the indicators handles
int RSI_Handle;
//---- declaration of the integer variables for the start of data calculation
int rsi_rates_total,sto_rates_total,min_rates_total;
//+------------------------------------------------------------------+
// CMoving_Average class description                                 | 
//+------------------------------------------------------------------+  
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   rsi_rates_total=RSILength;
   sto_rates_total=rsi_rates_total+StocLength;
   min_rates_total=sto_rates_total+WMALength+1;

//---- getting handle of the RSI indicator
   RSI_Handle=iRSI(NULL,0,RSILength,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RSI indicator");

//---- set StoRSIBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,StoRSIBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(StoRSIBuffer,true);

//---- set TriggerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(TriggerBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Stochastic RSI(",RSILength,", ",StocLength,", ",WMALength,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,to_copy,maxbar,bar;
   double tmp,hh,ll,Value1,Value2,Value3,RSI[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(RSI,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-1-rsi_rates_total; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+min_rates_total+1;
   maxbar=rates_total-1-sto_rates_total;

//---- declaration of variable of the class CMoving_Average from the file MASeries_Cls.mqh
   static CMoving_Average MA;

//--- copy newly appeared data in the array
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(0);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      hh = RSI[bar];
      ll = RSI[bar];

      for(int iii=0; iii<StocLength; iii++)
        {
         tmp= RSI[bar+iii];
         hh = MathMax(hh, tmp);
         ll = MathMin(ll, tmp);
        }

      Value1 = RSI[bar] - ll;
      Value2 = hh - ll;

      if(Value2 != 0.0) Value3= Value1/Value2;
      else Value3= 0.0;

      StoRSIBuffer[bar]=MA.MASeries(maxbar,prev_calculated,rates_total,WMALength,MODE_LWMA,Value3,bar,true);
      TriggerBuffer[bar]=StoRSIBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
