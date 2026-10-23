//+------------------------------------------------------------------+ 
//|                                                 ang_AZad_Css.mq5 | 
//|                           Copyright © 2006, ANG3110@latchess.com | 
//|                                             ANG3110@latchess.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, ANG3110@latchess.com"
#property link "ANG3110@latchess.com"
//---- The indicator version
#property version   "1.00"
//---- The indicator is drawn in the main window
#property indicator_chart_window
//---- 2 indicator buffers are used
#property indicator_buffers 2 
//---- One graphical construction is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator is drawn as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- The following colors are used or the indicator
#property indicator_color1  clrPaleGreen,clrSalmon
//---- The indicator label
#property indicator_label1  "ang_AZad_Css"

//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input double ki=2;
input int Shift=0;
input int zShift=0;
//+-----------------------------------+

//---- Declaring integer variables of data calculation start
int  min_rates_total;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double ZaBuffer[];
double Za2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=4;

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ZaBuffer,INDICATOR_DATA);
//---- Shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Shifting the indicator horizontally by InpKijun
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ZaBuffer,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,Za2Buffer,INDICATOR_DATA);
//---- Shifting the beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Shifting the indicator horizontally by -InpKijun
   PlotIndexSetInteger(1,PLOT_SHIFT,zShift);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Za2Buffer,true);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ang_AZad_Css");
//--- Determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaring floating point variables 
   double z,z2;
   static double z_,z2_;
//---- Declaring integer variables
   int limit;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Close,true);

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      for(int bar=rates_total-1; bar>limit && !IsStopped(); bar--) Za2Buffer[bar]=ZaBuffer[bar]=Close[bar];
      z2_=z_=Close[limit+1];
     }
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

   z=z_;
   z2=z2_;

//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Close[bar]>z && Close[bar]>Close[bar+1]) z=ZaBuffer[bar+1]+(Close[bar]-ZaBuffer[bar+1])/ki;
      if(Close[bar]<z && Close[bar]<Close[bar+1]) z=ZaBuffer[bar+1]+(Close[bar]-ZaBuffer[bar+1])/ki;
      if(Close[bar]>z2 && Close[bar]<Close[bar+1]) z2=Za2Buffer[bar+1]+(Close[bar]-Za2Buffer[bar+1])/ki;
      if(Close[bar]<z2 && Close[bar]>Close[bar+1]) z2=Za2Buffer[bar+1]+(Close[bar]-Za2Buffer[bar+1])/ki;

      ZaBuffer[bar]=z;
      Za2Buffer[bar]=z2;

      if(bar)
        {
         z_=z;
         z2_=z2;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
