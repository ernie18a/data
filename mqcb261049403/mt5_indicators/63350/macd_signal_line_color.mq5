//+------------------------------------------------------------------+
//|                                       MACD_Signal_Line_color.mq5 |
//|                               Copyright 2025, Ryan Johnson (RJo) |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Ryan L. Johnson (RJo)"
#property link      "https://www.mql5.com/en/users/rjo"
#property version   "1.00"

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue, clrLimeGreen, clrRed
#property indicator_width1  1
#property indicator_level1  0.0
#property indicator_label1  "Signal"

//--- input parameters
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price

//--- indicator buffers
double   ExtSignalBuffer[];
double   ExtColorBuffer[];

int      ExtMacdHandle;      // handle to the iMACD indicator
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- map indicator buffers
   SetIndexBuffer(0,ExtSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//--- signal SMA period determines the first drawn bar
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpSignalSMA-1);
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);

//--- label
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("MACD(%d,%d,%d)",InpFastEMA,InpSlowEMA,InpSignalSMA));

//--- create the MACD indicator handle
   ExtMacdHandle=iMACD(NULL,0,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
   if(ExtMacdHandle==INVALID_HANDLE)
      Print("Failed to create iMACD handle. Error ",GetLastError());
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<InpSignalSMA)
      return(0);

//--- check if the MACD handle is ready
   if(BarsCalculated(ExtMacdHandle)<rates_total)
      return(0);

//--- copy the signal line (iMACD buffer 1 = signal line)
   int copied=CopyBuffer(ExtMacdHandle,1,0,rates_total,ExtSignalBuffer);
   if(copied!=rates_total)
      return(0);

//--- assign colors based on slope and zero-level
   ExtColorBuffer[0]=0;
   for(int i=1; i<rates_total; i++)
     {
      //--- upward slope above zero level -> green (color index 1)
      if(ExtSignalBuffer[i]>ExtSignalBuffer[i-1] && ExtSignalBuffer[i]>0.0)
         ExtColorBuffer[i]=1;
      //--- downward slope below zero level -> red (color index 2)
      else if(ExtSignalBuffer[i]<ExtSignalBuffer[i-1] && ExtSignalBuffer[i]<0.0)
         ExtColorBuffer[i]=2;
      //--- all other cases -> default blue (color index 0)
      else
         ExtColorBuffer[i]=0;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
