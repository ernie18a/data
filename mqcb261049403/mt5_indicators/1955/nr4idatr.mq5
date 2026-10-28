//+------------------------------------------------------------------+ 
//|                                                    NR4ID-ATR.mq5 | 
//|                                           Copyright © 2006, Rosh | 
//|                                    http://forexsystems.ru/phpBB/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, Rosh"
#property link "http://forexsystems.ru/phpBB/"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers is 1
#property indicator_buffers 1 
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                       // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "NR4ID-ATR"    // A constant for the indicator name
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 1 as a label
#property indicator_type1   DRAW_ARROW
//--- the color of the indicator
#property indicator_color1  clrLimeGreen
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint PerATR=1;    // Period of ATR
input uint PerNR=4;     // Indicator period
input int  Shift=0;     // Indicator shift
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtBuffer[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(PerATR,PerNR));
//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,PerATR);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME+"("+string(PerATR)+","+string(PerNR)+","+string(Shift)+")");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declaration of variables with a floating point  
   double tempval,ATR[];
//--- declaration of integer variables
   int limit,to_copy;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(ATR,true);
   to_copy=int(limit+PerNR+1);
//--- copy newly appeared data in the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      tempval=0.0;
      if (High[bar]<High[bar+1] && Low[bar]>Low[bar+1] && ATR[bar]==ATR[ArrayMinimum(ATR,bar,PerNR)]) tempval=(High[bar]+Low[bar])/2;
      ExtBuffer[bar]= tempval;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+