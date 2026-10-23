//+------------------------------------------------------------------+
//|                                      Instantaneous Trendline.mq5 |
//|                                                                  |
//| Instantaneous Trendline                                          |
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
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  ITrend indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color1  Red
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of the indicator 1 line is equal to 1
#property indicator_width1  1
//---- displaying the bullish label of the indicator
#property indicator_label1  "Instantaneous Trendline"
//+----------------------------------------------+
//|  Trigger indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator bearish line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- thickness of the indicator 2 line is equal to 1
#property indicator_width2  1
//---- displaying the bearish label of the indicator line
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double Alpha=0.07; // Indicator ratio
input int Shift=0;       // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ITrendBuffer[];
double TriggerBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of global variables
double K0,K1,K2,K3,K4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=8+3;

//---- initialization of variables
   double A2=Alpha*Alpha;
   K0=Alpha-A2/4.0;
   K1=0.5*A2;
   K2=Alpha-0.75*A2;
   K3=2.0 *(1.0 - Alpha);
   K4=MathPow((1.0 - Alpha),2);

//---- set ITrendBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ITrendBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 3
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3);

//---- set TriggerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 3
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,3);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Instantaneous Trendline(",Alpha,", ",Shift,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
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
   double price0,price1,price2;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=3; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price0=(high[bar]+low[bar])/2.0;
      price1=(high[bar-1]+low[bar-1])/2.0;
      price2=(high[bar-2]+low[bar-2])/2.0;

      if(bar<min_rates_total) ITrendBuffer[bar]=(price0+2.0*price1+price2)/4.0;
      else ITrendBuffer[bar]=K0*price0+K1*price1-K2*price2+K3*ITrendBuffer[bar-1]-K4*ITrendBuffer[bar-2];

      TriggerBuffer[bar]=2.0*ITrendBuffer[bar]-ITrendBuffer[bar-2];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+