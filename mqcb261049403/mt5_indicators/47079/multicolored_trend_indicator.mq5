//+------------------------------------------------------------------+
//|                                Multi-colored_trend_indicator.mq5 |
//|                                Copyright 2023, Sakhawat Hossain. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Questions about the code? DM me"
#property description "Contact me on https://www.mql5.com/en/users/sakhawatdhrubo"


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot Line property
#property indicator_label1  "Trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      InpFastMAPeriod = 10; // Fast moving average period
input ENUM_MA_METHOD InpFastMAMethod = MODE_SMA;//Fast moving average method
input ENUM_APPLIED_PRICE InpFastMAAppliedPrice = PRICE_CLOSE; //Fast moving average applyed price

input int      InpSlowMAPeriod = 50; // Slow moving average period
input ENUM_MA_METHOD InpSlowMAMethod = MODE_SMA;//Slow moving average method
input ENUM_APPLIED_PRICE InpSlowMAAppliedPrice = PRICE_CLOSE; //Slow moving average applyed price
//--- indicator buffers
double         MainBuffer[];
double         ColorsBuffer[];
// Indicator Handles
int HandleFastMA;
int HandleSlowMA;
double FastMAValues[];
double SlowMAValues[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorsBuffer,INDICATOR_COLOR_INDEX);
//--ArraySet Series
   ArraySetAsSeries(MainBuffer, true);
   ArraySetAsSeries(ColorsBuffer, true);
   ArraySetAsSeries(FastMAValues, true);
   ArraySetAsSeries(SlowMAValues, true);
//---Create Internal Indicators and Check If it has been Created
   HandleFastMA = iMA(Symbol(), Period(), InpFastMAPeriod, 0, InpFastMAMethod, InpFastMAAppliedPrice);
   HandleSlowMA = iMA(Symbol(), Period(), InpSlowMAPeriod, 0, InpSlowMAMethod, InpSlowMAAppliedPrice);
   if(HandleFastMA == INVALID_HANDLE || HandleSlowMA == INVALID_HANDLE)
     {
      printf("Error Creating Moving Average Handle: [%d]", GetLastError());
      return INIT_FAILED;
     }
//---Nameing for Data Window
//IndicatorSetString(INDICATOR_SHORTNAME,"Trend Indicator");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Release indicators handle when removing from chart                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(HandleFastMA);
   IndicatorRelease(HandleSlowMA);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
// How many bars to calculated
   int count = rates_total - prev_calculated; // totla bar - already calculated
   if(prev_calculated>0)
      count++; // force to caluate latest bar

   if(CopyBuffer(HandleFastMA,0,0,count,FastMAValues) < count)
      return (0);
   if(CopyBuffer(HandleSlowMA,0,0,count,SlowMAValues)< count)
      return (0);

// calculate from left to right, not necessary for this indicator
// but some indicatos current value depends on previous value;
   for(int i=count-1; i>=0; i--)
     {
      double fast = FastMAValues[i];
      double slow = SlowMAValues[i];
      double main = (fast+slow)/2;
      MainBuffer[i] = main;
      if(fast > slow)
        {
         ColorsBuffer[i] = 0; //First color aka uptrend color
        }
      else
        {
         ColorsBuffer[i] = 1; // Second color aka downtrend color
        }

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
