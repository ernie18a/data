//+------------------------------------------------------------------+
//|                                             WidnersOscilator.mq5 |
//|                    Copyright © 2004, http://www.expert-mt4.nm.ru |
//|                                      http://www.expert-mt4.nm.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, http://www.expert-mt4.nm.ru"
#property link      "http://www.expert-mt4.nm.ru"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  WSO drawing parameters                      |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the bearish indicator line
#property indicator_color1  clrRed
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- display of the bearish label of the indicator line
#property indicator_label1  "WSO"
//+----------------------------------------------+
//|  WRO drawing parameters                      |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator bullish line
#property indicator_color2  clrBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- display of the bullish label of the indicator line
#property indicator_label2  "WRO"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 50.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint nPeriod=9;
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double WSOBuffer[];
double WROBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,per;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(nPeriod);
   per=int((nPeriod-1)/2);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,WSOBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,WROBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"WidnersOscilator(",nPeriod,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   int first,bar;
   double r1,r2,r3,r4,r5,r6,s1,s2,s3,s4,s5,s6;
   static double R1,R2,R3,R4,R5,R6,S1,S2,S3,S4,S5,S6;

   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=min_rates_total;     // starting index for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

   s6=S6;
   s5=S5;
   s4=S4;
   s3=S3;
   s2=S2;
   s1=S1;

   r6=R6;
   r5=R5;
   r4=R4;
   r3=R3;
   r2=R2;
   r1=R1;

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- convert bar indexes for timeseries
      int barR=rates_total-1-bar;
      int barX=barR+per;

      double LL=low[ArrayMinimum(low,barR,nPeriod)];
      double HH=high[ArrayMaximum(high,barR,nPeriod)];

      if(low[barX]==LL)
        {
         s6=s5;
         s5=s4;
         s4=s3;
         s3=s2;
         s2=s1;
         s1=low[barX];
        }

      if(high[barX]==HH)
        {
         r6=r5;
         r5=r4;
         r4=r3;
         r3=r2;
         r2=r1;
         r1=high[barX];
        }

      WSOBuffer[bar]=100*(MathFloor(s1/close[bar])+
                          MathFloor(s2/close[bar])+
                          MathFloor(s3/close[bar])+
                          MathFloor(s4/close[bar])+
                          MathFloor(s5/close[bar])+
                          MathFloor(s6/close[bar]))/6;

      if(WSOBuffer[bar]==0) WSOBuffer[bar]+=1;
      if(WSOBuffer[bar]==100) WSOBuffer[bar]-=1;

      WROBuffer[bar]=100*(1-(MathFloor(r1/close[bar])+
                          MathFloor(r2/close[bar])+
                          MathFloor(r3/close[bar])+
                          MathFloor(r4/close[bar])+
                          MathFloor(r5/close[bar])+
                          MathFloor(r6/close[bar]))/6);

      if(WROBuffer[bar]==0) WROBuffer[bar]+=1;
      if(WROBuffer[bar]==100) WROBuffer[bar]-=1;

      if(bar==rates_total-2)
        {
         S6=s6;
         S5=s5;
         S4=s4;
         S3=s3;
         S2=s2;
         S1=s1;

         R6=r6;
         R5=r5;
         R4=r4;
         R3=r3;
         R2=r2;
         R1=r1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
