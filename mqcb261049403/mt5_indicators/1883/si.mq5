//+------------------------------------------------------------------+
//|                                                           SI.mq5 |
//|                                           Copyright © 2008, Raff | 
//|                                          just_raff1410@yahoo.com | 
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2008, Raff"
//---- link to the website of the author
#property link "just_raff1410@yahoo.com"
#property description ""
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculating and drawing the indicator
#property indicator_buffers 1
//---- two plots are used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- medium slate blue color is used as the color of the indicator line
#property indicator_color1  clrMediumSlateBlue
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying of the the indicator label
#property indicator_label1  "SI"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input double T=1;  // Divider
input int Shift=0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;
//---- initialization of the vertical shift
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"SI");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int first,bar;
   double K,R,R1,R2,R3,R4,X,SI;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
      IndBuffer[0]=0;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      R1=MathAbs(high[bar]-close[bar-1]);
      R2=MathAbs(low[bar]-close[bar-1]);
      R3=MathAbs(high[bar]-low[bar]);
      R4=MathAbs(close[bar-1]-open[bar-1]);
      K =MathMax(R1,R2);
      //----      
      if(R1>=MathMax(R2,R3)) R=R1-R2/2+R4/4;
      else if(R2>=MathMax(R1,R3)) R=R2-R1/2+R4/4;
      else R=R3+R4/4;

      if(!R) SI=0;
      else
        {
         X=(close[bar-1]-close[bar])+(close[bar-1]-open[bar-1])/2+(close[bar]-open[bar])/4;
         SI=50 *(X/R) *(K/T);
        }
      IndBuffer[bar]=IndBuffer[bar-1]-SI;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
