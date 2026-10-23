//+------------------------------------------------------------------+
//|                                              Laguerre Filter.mq5 |
//|                                                                  |
//| Laguerre Filter                                                  |
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
//---- red color is used for the indicator line
#property indicator_color1  Red
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Laguerre Filter"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "FIR"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double Gamma=0.7;  // Indicator ratio 
input int Shift=0;       // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
double LaguerreBuffer[],FirBuffer[];
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
   min_rates_total=4;
//---- set LaguerreBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,LaguerreBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set FirBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,FirBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Laguerre Filter(",DoubleToString(Gamma,4),", ",Shift,")");
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
   double L0,L1,L2,L3,L0A,L1A,L2A,L3A;

//---- declarations of static variables for storing real values of coefficients
   static double L0_,L1_,L2_,L3_,L0A_,L1A_,L2A_,L3A_;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   L0 = L0_;
   L1 = L1_;
   L2 = L2_;
   L3 = L3_;
   L0A = L0A_;
   L1A = L1A_;
   L2A = L2A_;
   L3A = L3A_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         L0_ = L0;
         L1_ = L1;
         L2_ = L2;
         L3_ = L3;
         L0A_ = L0A;
         L1A_ = L1A;
         L2A_ = L2A;
         L3A_ = L3A;
        }

      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      //----
      L0 = (1 - Gamma) * Get_Price(high, low, bar) + Gamma * L0A;
      L1 = - Gamma * L0 + L0A + Gamma * L1A;
      L2 = - Gamma * L1 + L1A + Gamma * L2A;
      L3 = - Gamma * L2 + L2A + Gamma * L3A;
      //----
      if(bar>min_rates_total)
        {
         LaguerreBuffer[bar]=(L0+2.0*L1+2.0*L2+L3)/6.0;
         FirBuffer[bar]=
                        (
                        Get_Price(high,low,bar)
                        +2.0*Get_Price(high,low,bar-1)
                        +2.0*Get_Price(high,low,bar-2)
                        +Get_Price(high,low,bar-3)
                        )
                        /6.0;
        }
      else
        {
         L0_=Get_Price(high,low,bar);
         L1_ = L0_;
         L2_ = L0_;
         L3_ = L0_;
         LaguerreBuffer[bar]=L0_;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
