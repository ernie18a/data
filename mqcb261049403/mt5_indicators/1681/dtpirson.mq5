//+------------------------------------------------------------------+ 
//|                                                    DT-Pirson.mq5 | 
//|                                           Copyright © 2007, klot | 
//|                                                     klot@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, klot"
#property link "klot@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Magenta color is used as the color of the indicator line
#property indicator_color1 clrMagenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "DT-Pirson"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 1.00
#property indicator_level2 0.50
#property indicator_level3 0.00
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input  uint N=20; // indicator period
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// be used as an indicator buffer
double ExtLineBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int MA_Handle,StdD_Handle;
//+------------------------------------------------------------------+    
//| DT-Pirson indicator initialization function                      | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(N+1);
   
//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,N,0,MODE_SMA,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");
   
//---- getting handle of the iStdDev indicator
   StdD_Handle=iStdDev(NULL,0,N,0,MODE_SMA,PRICE_CLOSE);
   if(StdD_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iStdDev indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"DT-Pirson( N = ",N,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| DT-Pirson iteration function                                     | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(StdD_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double MA[],StdD[];

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting number for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting number for the calculation of new bars
     }
     
   to_copy=limit+2;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   if(CopyBuffer(StdD_Handle,0,0,to_copy,StdD)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(StdD,true);
   ArraySetAsSeries(close,true);


//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double sum=0;
      for( int iii=0; iii<int(N); iii++) sum+=(close[bar+iii]-MA[bar])*(close[bar+iii+1]-MA[bar+1]);
      double Res=N*StdD[bar]*StdD[bar+1];
      if(Res) ExtLineBuffer[bar]=sum/Res;
      else ExtLineBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
