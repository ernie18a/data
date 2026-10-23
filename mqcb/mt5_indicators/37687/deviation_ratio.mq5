//+------------------------------------------------------------------+
//|                                              Deviation Ratio.mq5 |
//|                                  Copyright © 2020, Tadeáš Rusňák |
//|                                      http://www.tadeasrusnak.com |
//+------------------------------------------------------------------+

//---- author of the indicator
#property copyright "Copyright © 2020, Tadeáš Rusňák"
#property link      "http://www.tadeasrusnak.com"
#property description "Deviation Ratio"
#property version   "1.00"

input int Short_StDevPeriod      = 6;            // Fast StDev period
input int Long_StDevPeriod       = 27;           // Slow StDev period
input ENUM_MA_METHOD Short_StDevMode   = MODE_SMA;     // Short StDev Moving Average method
input ENUM_APPLIED_PRICE Short_StDevPrice   = PRICE_CLOSE;     // Short StDev Moving Average price data
input ENUM_MA_METHOD Long_StDevMode   = MODE_SMA;     // Short StDev Moving Average method
input ENUM_APPLIED_PRICE Long_StDevPrice   = PRICE_CLOSE;     // Long StDev Moving Average price data
      int StDevShift             = 0;

//+----------------------------------------------+


#property indicator_separate_window
#property indicator_buffers 1 
#property indicator_plots   1


//+----------------------------------------------+


#property indicator_type1 DRAW_LINE
#property indicator_color1 Snow
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1  "Deviation Ratio"

#property indicator_level1 0.9
#property indicator_levelcolor Red
#property indicator_levelstyle STYLE_DOT


//+----------------------------------------------+

double ExtLineBuffer[];
int Short_STDEV_Handle,Long_STDEV_Handle;
int StartBars;


void OnInit()
  {
   Short_STDEV_Handle=iStdDev(NULL,PERIOD_CURRENT,Short_StDevPeriod, 0, Short_StDevMode, Short_StDevPrice);
   if(Short_STDEV_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Standard Deviation indicator");

   Long_STDEV_Handle=iStdDev(NULL,PERIOD_CURRENT,Long_StDevPeriod, 0, Long_StDevMode, Long_StDevPrice);
   if(Long_STDEV_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Standard Deviation indicator");

   StartBars=MathMax(Short_StDevPeriod, Long_StDevPeriod);
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);

   string shortname;
   StringConcatenate(shortname,"Deviation Ratio (",Short_StDevPeriod," ",Long_StDevPeriod,")");

   PlotIndexSetInteger(0,PLOT_SHIFT,StDevShift);
   PlotIndexSetString(0,PLOT_LABEL,shortname);

   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
 
   ArraySetAsSeries(ExtLineBuffer,true);
   IndicatorSetInteger(INDICATOR_DIGITS,2);

  }
  
  
//+------------------------------------------------------------------+


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double& high[],
                const double& low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
//---- checking the number of bars to be enough for the calculation

   if(BarsCalculated(Short_STDEV_Handle)<rates_total
      || BarsCalculated(Long_STDEV_Handle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- declarations of local variables 

   int to_copy,limit,bar;
   double SRange[],LRange[];

//---- calculations of the necessary amount of data to be copied and
//---- the limit starting index for the loop of bars recalculation

   if(prev_calculated > rates_total || prev_calculated <= 0)   // checking for the first start of the indicator calculation
     {
      to_copy=rates_total;    // calculated number of all bars
      limit=rates_total-1;    // starting index for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+1;   // calculated number of new bars only
      limit=rates_total-prev_calculated;       // starting index for calculation of new bars
     }

//---- copy the newly appeared data into the SRange[] and LRange[] arrays

   if(CopyBuffer(Short_STDEV_Handle,0,0,to_copy,SRange) <= 0) return(0);
   if(CopyBuffer(Long_STDEV_Handle,0,0,to_copy,LRange)  <= 0) return(0);

//---- indexing elements in arrays as timeseries  

   ArraySetAsSeries(SRange,true);
   ArraySetAsSeries(LRange,true);

//---- main indicator calculation loop

   for(bar = limit; bar >= 0; bar--)
     {
      if(LRange[bar]!= 0.0 && LRange[bar] != EMPTY_VALUE) ExtLineBuffer[bar] = SRange[bar] / LRange[bar];
      else ExtLineBuffer[bar] = 0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
