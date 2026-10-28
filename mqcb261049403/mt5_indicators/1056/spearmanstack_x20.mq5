//+------------------------------------------------------------------+
//|                                            SpearmanStack_X20.mq5 | 
//|                                  Copyright © 2010, Ivan Kornilov | 
//|                                                 excelf@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description "SpearmanStack-X8"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- parameters of the minimum and maximum indicator values
#property indicator_minimum -1
#property indicator_maximum +1
//---- parameters of horizontal levels of the indicator
#property indicator_level1  +0.50
#property indicator_level2   0
#property indicator_level3  -0.50
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  declaration of constants              |
//+-----------------------------------+
#define LINES_TOTAL         20 // The constant for the number of the indicator lines
#define RESET               0 // The constant for returning the indicator recalculation command to the terminal
//---- number of indicator buffers
#property indicator_buffers LINES_TOTAL 
//---- total plots used
#property indicator_plots   LINES_TOTAL

//+-----------------------------------+
//|  Indicator drawing parameters  |
//+-----------------------------------+
//---- drawing the oscillators as lines
#property indicator_type1 DRAW_LINE
//---- selecting line colors
#property indicator_color1 clrDodgerBlue
//---- the lines are represented by dash-and-dot curves
#property indicator_style1 STYLE_SOLID
//---- line width is 1
#property indicator_width1  1
//+-----------------------------------+
//| Indicator input parameters      |
//+-----------------------------------+
input uint  rangeN=14;
input uint  step = 6;
input uint  CalculatedBars=0;
uint  Maxrange;
input bool  direction=true;
//+-----------------------------------+

//---- Declaration of integer variables for the indicator handles
int Spear_Handle[LINES_TOTAL];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  Arrays of variables for the indicator buffer creation            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Indicator buffer creation                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=int(rangeN+step*(LINES_TOTAL-1))+1;
   Maxrange=rangeN+LINES_TOTAL*(step-1+1)*2;
//----
   uint period=rangeN;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;

      //---- getting the SpearmanRankCorrelation indicator handle
      Spear_Handle[numb]=iCustom(NULL,0,"SpearmanRankCorrelation",period,CalculatedBars,Maxrange,direction);
      if(Spear_Handle[numb]==INVALID_HANDLE) Print(" Failed to get the SpearmanRankCorrelation indicator handle ",numb);

      string shortname="";
      StringConcatenate(shortname,"SpearmanRankCorrelation X",LINES_TOTAL,"*",period,")");
      //--- creating a name to be displayed in a separate subwindow and in a tooltip
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- setting the indicator values that will be invisible on the chart
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- shifting the starting point of the indicator drawing
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- setting dynamic arrays as indicator buffers
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- indexing buffer elements as time series   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- copying the properties of the first indicator line to the other lines
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,PlotIndexGetInteger(0,PLOT_LINE_COLOR));
     }

//---- initialization of a variable for a short name of the indicator
   string shortname;
   StringConcatenate(shortname,"SpearmanRankCorrelation X",LINES_TOTAL,"*",rangeN,"(",step,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);
   for(int numb=0; numb<LINES_TOTAL; numb++) if(BarsCalculated(Spear_Handle[numb])<min_rates_total) return(RESET);

//---- declaring local variables 
   int to_copy;

//---- calculation of the necessary amount of data to be copied
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      to_copy=rates_total;
   else to_copy=rates_total-prev_calculated+1;

//---- copy new data to the indicator buffers
   for(int numb=0; numb<LINES_TOTAL; numb++) if(CopyBuffer(Spear_Handle[numb],0,0,to_copy,Ind[numb].IndBuffer)<=0) return(RESET);
   
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
