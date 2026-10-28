//+------------------------------------------------------------------+ 
//|                                                    TDI2_BARS.mq5 | 
//|                                          Copyright © 2005, Perky | 
//|                                                Perky_z@yahoo.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Perky"
#property link "Perky_z@yahoo.com" 
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Parameters of indicator drawing   |
//+-----------------------------------+
//--- drawing indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM2
//--- the following colors are used in the four color histogram
#property indicator_color1 clrMagenta,clrBrown,clrGray,clrTeal,clrLime
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "TDI2_BARS"
//+-----------------------------------+
//| Declaration of constants          |
//+-----------------------------------+
#define RESET  0 // a constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//| CXMA class description            |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//| Declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price
   PRICE_DEMARK_         // Demark Price 
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method TdiMethod=MODE_SMA; // Method of averaging
input int TdiPeriod=20;                 // Smoothing depth                    
input int TdiPhase=15;                  // Smoothing parameter
//--- TdiPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- TdiPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;   // Price constant
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double UpIndBuffer[],DnIndBuffer[],ColorIndBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int TDI2_Handle;
//+------------------------------------------------------------------+    
//| TDI2_BARS indicator initialization function                      | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of data calculation start
   int min_rates_1=TdiPeriod;
   int min_rates_2=min_rates_1+GetStartBars(TdiMethod,TdiPeriod,TdiPhase);
   min_rates_total=min_rates_1+min_rates_2+2*GetStartBars(TdiMethod,TdiPeriod,TdiPhase);
//--- getting the handle of the iTDI-2 indicator
   TDI2_Handle=iCustom(NULL,0,"TDI-2",TdiMethod,TdiPeriod,TdiPhase,IPC,0);
   if(TDI2_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iTDI-2 indicator");
      return(INIT_FAILED);
     }
//--- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,DnIndBuffer,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnIndBuffer,true);
//--- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,UpIndBuffer,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpIndBuffer,true);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"TDI2_BARS");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| TDI2_BARS iteration function                                     | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
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
   if(BarsCalculated(TDI2_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables
   int to_copy,limit,bar;
   double TDI2P[],TDI2M[];
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//---
   to_copy=limit+1;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(TDI2P,true);
   ArraySetAsSeries(TDI2M,true);
//--- copy newly appeared data in the arrays
   if(CopyBuffer(TDI2_Handle,1,0,to_copy,TDI2P)<=0) return(RESET);
   if(CopyBuffer(TDI2_Handle,0,0,to_copy,TDI2M)<=0) return(RESET);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpIndBuffer[bar]=High[bar];
      DnIndBuffer[bar]=Low[bar];
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- main cycle of the indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;

      if(TDI2P[bar]>TDI2M[bar])
        {
         if(Open[bar]<Close[bar]) clr=4;
         if(Open[bar]>Close[bar]) clr=3;
        }

      if(TDI2P[bar]<TDI2M[bar])
        {
         if(Open[bar]>Close[bar]) clr=0;
         if(Open[bar]<Close[bar]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
