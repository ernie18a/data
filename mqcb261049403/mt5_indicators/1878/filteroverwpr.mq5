//+------------------------------------------------------------------+
//|                                                FilterOverWPR.mq5 |
//|                   Copyright © 2006, Indoforex Groups - Primajaya |
//|                                   http://primaforex.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Indoforex Groups"
#property link      "http://primaforex.blogspot.com"
#property description "The indicator of trend power and direction"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a sequence of bars
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used as the indicator colors
#property indicator_color1  clrRed,clrOrange,clrSteelBlue,clrBlue
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying of the the indicator label
#property indicator_label1  "FilterOverWPR"
//+-----------------------------------+
//| Indicator window parameters       |
//+-----------------------------------+
#property indicator_maximum  1.00
#property indicator_minimum  0.00
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint KPeriod=14;                        // Stochastic period
input uint DPeriod=3;                         // Percent
input uint Slowing=5;                         // Smoothing period
input ENUM_MA_METHOD MA_Method=MODE_SMA;      // Method of averaging
input ENUM_STO_PRICE Price_field=STO_LOWHIGH; // Selecting prices
input int  Shift=0;                           // Horizontal shift of the indicator in bars 
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double ExtBuffer[];
double ColorExtBuffer[];
//---- Declaration of integer variables for indicators handles
int STO_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(KPeriod+DPeriod+Slowing);

//---- Getting the handle of the iStochastic indicator
   STO_Handle=iStochastic(Symbol(),PERIOD_CURRENT,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(STO_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iStochastic indicator");
      return(INIT_FAILED);
     }
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBuffer,true);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorExtBuffer,true);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"FilterOverWPR("
                      +string(KPeriod)+","+string(DPeriod)+","+string(Slowing)+","+string(Shift)+")");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(STO_Handle)<rates_total) return(RESET);

//---- declaration of integer variables
   int limit,trend,to_copy;
//---- declaration of variables with a floating point
   double iSto[],iSig[];

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(iSto,true);
   ArraySetAsSeries(iSig,true);

   to_copy=limit+1;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,iSto)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,SIGNAL_LINE,0,to_copy,iSig)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtBuffer[bar]=1.0;

      if(iSto[bar]>20 && iSto[bar]>iSig[bar] && iSto[bar]<40 && iSig[bar]<40) trend=1;
      if(iSto[bar]<=20) trend=0;
      if(iSto[bar]<80 && iSto[bar]<iSig[bar] && iSto[bar]>60 && iSig[bar]>60) trend=2;
      if(iSto[bar]>=80) trend=3;

      ColorExtBuffer[bar]=trend;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
