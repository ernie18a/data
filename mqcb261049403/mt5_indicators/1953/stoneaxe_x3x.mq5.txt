//+------------------------------------------------------------------+ 
//|                                                 StoneAxe_x3x.mq5 | 
//|                         Copyright © 2006, from MetaStock by Rosh | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, from MetaStock by Rosh"
#property link "http://www.investo.ru/forum/viewtopic.php?t=125389&postdays=0&postorder=asc&start=75"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                       // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "StoneAxe_x3x" // A constant for the indicator name
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- the color of the indicator
#property indicator_color1  clrLimeGreen
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  INDICATOR_NAME+"1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- the color of the indicator
#property indicator_color2  clrBlue
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  INDICATOR_NAME+"2"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- Drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//---- the color of the indicator
#property indicator_color3  clrMagenta
//---- indicator 3 line width is equal to 2
#property indicator_width3  2
//---- displaying the indicator label
#property indicator_label3  INDICATOR_NAME+"3"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 +75
#property indicator_level2   0
#property indicator_level3 -75
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint N1=9;      // Period of the first oscillator
input uint N2=26;     // Period of the second oscillator
input uint N3=52;     // Period of the third oscillator
input int Shift1=0;   // Shift of the first oscillator
input int Shift2=0;   // Shift of the second oscillator
input int Shift3=0;   // Shift of the third oscillator
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtBuffer1[];
double ExtBuffer2[];
double ExtBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(N1,MathMax(N2,N3)));
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer1,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift1);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer1,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBuffer2,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift2);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer2,true);
   
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtBuffer3,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift3);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer3,true);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME+"("+string(N1)+","+string(N2)+","+string(N3)+")");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//---- declaration of variables with a floating point  
   double HH,LL,CL;
//---- declaration of integer variables
   int limit;
//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
        limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars
//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);  
//---- The main loop of the indicator calculation
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      CL=Close[bar];
      //---- calculation of the first oscillator
      HH=High[ArrayMaximum(High,bar,N1)]; LL=Low[ArrayMinimum(Low,bar,N1)]; ExtBuffer1[bar]=200*(CL-LL)/(HH-LL)-100;
      //---- calculation of the second oscillator
      HH=High[ArrayMaximum(High,bar,N2)]; LL=Low[ArrayMinimum(Low,bar,N2)]; ExtBuffer2[bar]=200*(CL-LL)/(HH-LL)-100;
      //---- calculation of the third oscillator
      HH=High[ArrayMaximum(High,bar,N3)]; LL=Low[ArrayMinimum(Low,bar,N3)]; ExtBuffer3[bar]=200*(CL-LL)/(HH-LL)-100;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
