//+------------------------------------------------------------------+
//|                                                      Leading.mq5 |
//|                                                                  |
//| Leading                                                          |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Coded by Witold Wozniak"
//---- author of the indicator
#property link      "www.mqlsoft.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator
#property indicator_color1  Blue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Lead"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used for the indicator line
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "EMA"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double Alpha1 = 0.25;  // Alpha1 indicator ratio
input double Alpha2 = 0.33;  // Alpha2 indicator ratio 
input int Shift=0;           // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double NetLeadBuffer[],EMABuffer[];
//+------------------------------------------------------------------+
//|  Getting the average from the price time series                  |
//+------------------------------------------------------------------+   
double Get_Price(const double  &High[],const double  &Low[],int bar)
  {
//----
   return((High[bar]+Low[bar])/2);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=2;

//---- set NetLeadBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,NetLeadBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set EMABuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,EMABuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,
                     "Leading(",DoubleToString(Alpha1,4),", ",DoubleToString(Alpha2,4),", ",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int first,bar;
   double Lead;

//---- declarations of static variables for storing real values of coefficients
   static double Lead_;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
    {
      first=0; // starting index for calculation of all bars
    }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   Lead=Lead_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
         Lead_=Lead;

      if(bar>min_rates_total)
        {
         Lead=2.0*Get_Price(high,low,bar)+(Alpha1-2.0)*Get_Price(high,low,bar-1)+(1.0-Alpha1)*Lead;
         NetLeadBuffer[bar] = Alpha2 * Lead + (1 - Alpha2) * NetLeadBuffer[bar-1];
         EMABuffer[bar]=0.5 * Get_Price(high,low,bar) + 0.5 * EMABuffer[bar-1];
        }
      else
        {
         Lead=Get_Price(high,low,bar);
         NetLeadBuffer[bar]=Lead;
         EMABuffer[bar]=Lead;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
