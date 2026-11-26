//+------------------------------------------------------------------+
//|                                               XD-RangeSwitch.mq5 |
//|                                        Copyright © 2009, Vic2008 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Vic2008"
#property link      ""
//--- indicator version
#property version   "1.10"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//--- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- brown color is used for the indicator line
#property indicator_color1  clrBrown
//--- the indicator 1 line is a solid line
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Upper XD-RangeSwitch"
//+----------------------------------------------+
//| Indicator 2 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- teal color is used for the indicator line
#property indicator_color2  clrTeal
//--- the indicator 2 line is a solid line
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "Lower XD-RangeSwitch"
//+----------------------------------------------+
//| Indicator 3 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//--- chocolate color is used for the indicator Sell
#property indicator_color3  clrChocolate
//--- the indicator 3 line is a solid line
#property indicator_style3  STYLE_SOLID
//--- the indicator 3 line width is equal to 1
#property indicator_width3  1
//--- displaying the indicator label
#property indicator_label3  "Sell XD-RangeSwitch"
//+----------------------------------------------+
//| Indicator 4 (bullish) drawing parameters     |
//+----------------------------------------------+
//--- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//--- cadet blue color is used for the indicator Buy
#property indicator_color4  clrCadetBlue
//--- the indicator 4 line is a solid line
#property indicator_style4  STYLE_SOLID
//--- the indicator 4 line width is equal to 1
#property indicator_width4  1
//--- displaying the indicator label
#property indicator_label4  "Buy XD-RangeSwitch"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int N=4;     // Number of peaks
input int Shift=0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays which will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=N;
//--- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries 
   ArraySetAsSeries(ExtMapBufferUp,true);
///--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries
   ArraySetAsSeries(ExtMapBufferDown,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,110);
//--- set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries     
   ArraySetAsSeries(ExtMapBufferDown1,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,110);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"XD-RangeSwitch(",N,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
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
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit,bar;
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//--- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;
      //---
      if(close[bar]>high[ArrayMaximum(high,bar+1,N)]) ExtMapBufferDown[bar]=low[ArrayMinimum(low,bar,N)];
      else
        {
         if(close[bar]<low[ArrayMinimum(low,bar+1,N)]) ExtMapBufferUp[bar]=high[ArrayMaximum(high,bar,N)];
         else
           {
            ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
            ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
           }
        }
      //---
      if(ExtMapBufferUp[bar+1]==EMPTY_VALUE && ExtMapBufferUp[bar]!=EMPTY_VALUE)
         ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
      //---
      if(ExtMapBufferDown[bar+1]==EMPTY_VALUE && ExtMapBufferDown[bar]!=EMPTY_VALUE)
         ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
