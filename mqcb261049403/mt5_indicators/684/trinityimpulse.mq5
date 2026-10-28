//+------------------------------------------------------------------+ 
//|                                              Trinity-Impulse.mq5 | 
//|                           Copyright © 2010, basisforex@gmail.com | 
//|                                             basisforex@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link "basisforex@gmail.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Orchid color is used for the indicator line
#property indicator_color1 Orchid
//---- indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- indicator label display
#property indicator_label1  "Trinity-Impulse"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for returning indicator recalculation command for the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int nPeriod= 5;                           // Indicator period
input int nLevel= 34;                           // Smoothing level
input  ENUM_MA_METHOD nType=MODE_LWMA;          // Averaging type
input ENUM_APPLIED_PRICE nPrice=PRICE_WEIGHTED; // Price
input ENUM_APPLIED_VOLUME nVolume=VOLUME_TICK;  // Volume type
//+-----------------------------------+
//---- declaration of dynamic array that will further
//---- used as the indicator buffer
double ExtLineBuffer[];
//---- declaration of integer variables of the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int CCI_Handle,Force_Handle;
//+------------------------------------------------------------------+    
//| Trinity-Impulse indicator initialization function                | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables for the start of data calculation
   min_rates_total=nPeriod;

//---- getting the handle of iCCI indicator
   CCI_Handle=iCCI(NULL,0,nPeriod,nPrice);
   if(CCI_Handle==INVALID_HANDLE) Print(" Failed to get the handle of iCCI indicator");

//---- getting the handle of iForce handle
   Force_Handle=iForce(NULL,0,nPeriod,nType,nVolume);
   if(Force_Handle==INVALID_HANDLE) Print(" Failed to get the handle of iForce indicator");

//---- set dynamic array as the indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shift of the indicator drawing counting start
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- installation of the indicator values that are not visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffers as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Trinity-Impulse(",nPeriod,")");
//--- creation of the name for displaying in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- declaration of the indicator values display accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Trinity-Impulse iteration function                               | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars in history at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(Force_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables
   int to_copy,limit,bar;
   double CCI[],FORCE[];

//---- calculation of the first starting index for the bars recalculation cycle
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-2; // estimated amount of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing the elements in arrays as timeseries  
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(FORCE,true);

   to_copy=limit+1;

//---- copy newly appeared data in the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(Force_Handle,0,0,to_copy,FORCE)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      if(CCI[bar]*FORCE[bar]>=nLevel)
        {
         if(CCI[bar]>0 && FORCE[bar]>0) ExtLineBuffer[bar]=1;
         if(CCI[bar]<0 && FORCE[bar]<0) ExtLineBuffer[bar]=-1;
        }
      else ExtLineBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
