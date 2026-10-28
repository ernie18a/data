//+------------------------------------------------------------------+
//|                                                           FP.mq5 | 
//|                                 Copyright © 2006, Nick A. Zhilin |
//|                                              rebus@dialup.etr.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick A. Zhilin"
#property link      "rebus@dialup.etr.ru"
#property description "FP channel"
//---- indicator version
#property version   "1.00"
//----  drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+--------------------------------------------+ 
//|  Declaration of constants                  |
//+--------------------------------------------+
#define RESET 0  // the constant for getting the command for the indicator recalculation back to the terminal
//+--------------------------------------------+
//|  Indicator drawing parameters              |
//+--------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- MediumBlue color is used for the indicator line
#property indicator_color1 MediumBlue
//----  the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "FP"
//+--------------------------------------------+
//|  Channel drawing parameters                |
//+--------------------------------------------+
//----  drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- levels colors selection
#property indicator_color2  LightSeaGreen
#property indicator_color3  FireBrick
//---- the levels are continuous curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- levels width is equal to 2
#property indicator_width2  2
#property indicator_width3  2
//---- displaying the levels labels 
#property indicator_label2  "+FP"
#property indicator_label3  "-FP"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint IPeriod=100;  // Indicator period
input int  Shift=0;      // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double FPBuffer[],UpFPBuffer[],DnFPBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(IPeriod);

//---- set FPBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,FPBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will not be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(FPBuffer,true);

//---- set UpFPBuffer[] and DnFPBuffer[] dynamic arrays as indicator buffers
   SetIndexBuffer(1,UpFPBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnFPBuffer,INDICATOR_DATA);
//---- shifting the indicators horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- setting the position, from which the indicator drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- forbidding drawing the empty values by the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(UpFPBuffer,true);
   ArraySetAsSeries(DnFPBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"FP channel");

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int limit;
   double max,min,pivot,middle;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      max=high[ArrayMaximum(high,bar,IPeriod)];
      min=low [ArrayMinimum(low, bar,IPeriod)];
      pivot=(close[bar+1]+close[bar+2]+close[bar+3])/3;
      middle=(max+min+pivot)/3;
      FPBuffer[bar]=middle;
      UpFPBuffer[bar]=(3*middle-min)/2;
      DnFPBuffer[bar]=(3*middle-max)/2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
