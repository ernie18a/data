//+------------------------------------------------------------------+ 
//|                                      MA_AC_Stochastic_Signal.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator
#property indicator_color1  Purple,Teal
//---- displaying the indicator label
#property indicator_label1  "MA Signal"
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- the following colors are used for the indicator
#property indicator_color2 Gray,Red,Lime
//---- displaying the indicator label
#property indicator_label2  "AC Stochastic Signal"
//---- indicator line width is equal to 5
#property indicator_width2 5
//+-----------------------------------+ 
//|  Declaration of constants         |
//+-----------------------------------+ 
#define AC_DATA_LIMIT 37 // the constant for storing the minimum number of estimated bars for iAC
#define RESET          0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int MA_Period=9;                         // MA period
input ENUM_MA_METHOD MA_Method=MODE_SMA;       // Smoothing method 
input ENUM_APPLIED_PRICE MA_Price=PRICE_CLOSE; // Prices calculation method
input int STO_Period=5;                        // Stochastic period
input int STO_Slowing=3;                       // Stochastic slowing
input ENUM_MA_METHOD STO_Method=MODE_SMA;      // Stochastic smoothing method
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH;    // Stochastic prices calculation method
//+-----------------------------------+
//---- declaration of integer variables for the indicators handles
int MA_Handle,AC_Handle,STO_Handle;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtColorCBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(AC_DATA_LIMIT+1,MathMax(MA_Period,STO_Period+STO_Slowing)));

//---- getting handle of the MA indicator
   MA_Handle=iMA(NULL,0,MA_Period,0,STO_Method,STO_Price);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the MA indicator");

//---- getting handle of the Stochastic indicator
   STO_Handle=iStochastic(NULL,0,STO_Period,3,STO_Slowing,STO_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE) Print(" Failed to get handle of the Stochastic indicator");

//---- getting handle of the AC indicator
   AC_Handle=iAC(NULL,0);
   if(AC_Handle==INVALID_HANDLE) Print(" Failed to get handle of the AC indicator");

//---- set ExtABuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtABuffer,true);

//---- set ExtBBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtBBuffer,true);

//---- set ExtCBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtCBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtCBuffer,true);

//---- set ExtColorCBuffer[] dynamic array as a color index buffer   
   SetIndexBuffer(3,ExtColorCBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtColorCBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname="MA AC Stochastic_Signal";
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(AC_Handle)<rates_total
      || BarsCalculated(STO_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declarations of local variables 
   int to_copy,limit,bar;
   double STO[],AC[],MA[];
   static int trend;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      trend=0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+1;

//---- copy newly appeared data in the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,0,0,to_copy,STO)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(AC_Handle,0,0,to_copy,AC)<=0) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(STO,true);
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(Close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Close[bar] > MA[bar]){ExtBBuffer[bar]=+1; ExtABuffer[bar]=0;}
      if(Close[bar] <=MA[bar]){ExtBBuffer[bar]=-1; ExtABuffer[bar]=0;}

      ExtCBuffer[bar]=0;
      ExtColorCBuffer[bar]=0;

      if(AC[bar]>0 && AC[bar]>AC[bar+1] && STO[bar]>50 && trend!=+1)
        {
         ExtCBuffer[bar]=+1;
         ExtColorCBuffer[bar]=2;
         if(bar) trend=+1;
        }

      if(AC[bar]<0 && AC[bar]<AC[bar+1] && STO[bar]<50 && trend!=-1)
        {
         ExtCBuffer[bar]=-1;
         ExtColorCBuffer[bar]=1;
         if(bar) trend=-1;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
