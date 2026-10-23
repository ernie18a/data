#property copyright "BestForexScript.Com"
#property link      "https://bestforexscript.com"
#property version   "1.02"
#property description "Download Expert Advisors and Indicator for FREE!"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3

//--- Plot MACD Line
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot Signal Line
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Plot Color Histogram (single plot with 4 colors)
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrDarkGreen, clrLimeGreen, clrLightCoral, clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- Input parameters
input int      InpFastEMA     = 12;    // Fast EMA Length
input int      InpSlowEMA     = 26;    // Slow EMA Length
input int      InpSignalSMA   = 9;     // Signal SMA Length
input ENUM_APPLIED_PRICE InpPrice = PRICE_CLOSE;  // Source

//--- Indicator buffers
double         MACDBuffer[];
double         SignalBuffer[];
double         HistogramBuffer[];
double         ColorBuffer[];     // Color index buffer for histogram

//--- Global variables
int            emaFastHandle;
int            emaSlowHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator buffers
   SetIndexBuffer(0, MACDBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ColorBuffer, INDICATOR_COLOR_INDEX);
   
   // Set empty values
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   
   // Set indicator name
   string shortname = "MACD(" + IntegerToString(InpFastEMA) + "," + 
                      IntegerToString(InpSlowEMA) + "," + 
                      IntegerToString(InpSignalSMA) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
   
   // Create EMA handles
   emaFastHandle = iMA(_Symbol, _Period, InpFastEMA, 0, MODE_EMA, InpPrice);
   emaSlowHandle = iMA(_Symbol, _Period, InpSlowEMA, 0, MODE_EMA, InpPrice);
   
   if(emaFastHandle == INVALID_HANDLE || emaSlowHandle == INVALID_HANDLE)
      return(INIT_FAILED);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(emaFastHandle != INVALID_HANDLE)
      IndicatorRelease(emaFastHandle);
   if(emaSlowHandle != INVALID_HANDLE)
      IndicatorRelease(emaSlowHandle);
}

//+------------------------------------------------------------------+
//| Get color index based on histogram value and momentum           |
//+------------------------------------------------------------------+
int GetHistogramColor(double currentHist, double prevHist)
{
   if(currentHist > 0)
   {
      // Bullish territory
      if(currentHist > prevHist)
         return 0;  // Dark Green - rising above zero
      else
         return 1;  // Light Green - falling above zero
   }
   else if(currentHist < 0)
   {
      // Bearish territory
      if(currentHist < prevHist)
         return 3;  // Red - falling below zero
      else
         return 2;  // Light Coral - rising towards zero
   }
   
   return 1; // Default (won't be visible as value is 0)
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   // Check for sufficient data
   if(rates_total < InpSlowEMA + InpSignalSMA + 1)
      return(0);
   
   // Calculate start index
   int start;
   if(prev_calculated == 0)
   {
      start = InpSlowEMA;
      // Initialize arrays
      ArrayInitialize(MACDBuffer, 0);
      ArrayInitialize(SignalBuffer, 0);
      ArrayInitialize(HistogramBuffer, 0);
      ArrayInitialize(ColorBuffer, 0);
   }
   else
   {
      start = prev_calculated - 1;
      if(start < InpSlowEMA)
         start = InpSlowEMA;
   }
   
   // Ensure start is within bounds
   if(start < 0) 
      start = 0;
   if(start >= rates_total) 
      return(rates_total);
   
   // Resize arrays to hold all data
   ArrayResize(MACDBuffer, rates_total);
   ArrayResize(SignalBuffer, rates_total);
   ArrayResize(HistogramBuffer, rates_total);
   ArrayResize(ColorBuffer, rates_total);
   
   // Get EMA values using CopyBuffer
   double FastEMA[], SlowEMA[];
   ArrayResize(FastEMA, rates_total);
   ArrayResize(SlowEMA, rates_total);
   
   // Copy all EMA values at once
   if(CopyBuffer(emaFastHandle, 0, 0, rates_total, FastEMA) < rates_total ||
      CopyBuffer(emaSlowHandle, 0, 0, rates_total, SlowEMA) < rates_total)
   {
      Print("Failed to copy EMA buffers");
      return(prev_calculated);
   }
   
   // Calculate MACD line
   for(int i = start; i < rates_total; i++)
   {
      if(i >= InpSlowEMA && i < rates_total)
         MACDBuffer[i] = FastEMA[i] - SlowEMA[i];
      else
         MACDBuffer[i] = 0;
   }
   
   // Calculate Signal line (SMA of MACD)
   for(int i = start; i < rates_total; i++)
   {
      if(i >= InpSignalSMA - 1)
      {
         double sum = 0;
         int count = 0;
         int smaStart = i - InpSignalSMA + 1;
         if(smaStart < 0) smaStart = 0;
         
         for(int j = smaStart; j <= i; j++)
         {
            if(j >= 0 && j < rates_total)
            {
               sum += MACDBuffer[j];
               count++;
            }
         }
         if(count > 0)
            SignalBuffer[i] = sum / count;
         else
            SignalBuffer[i] = 0;
      }
      else
      {
         SignalBuffer[i] = 0;
      }
   }
   
   // Calculate histogram and assign colors
   for(int i = start; i < rates_total; i++)
   {
      HistogramBuffer[i] = MACDBuffer[i] - SignalBuffer[i];
      
      // Get previous histogram value for momentum
      double prevHist = (i > 0) ? HistogramBuffer[i-1] : HistogramBuffer[i];
      
      // Assign color based on value and momentum
      ColorBuffer[i] = GetHistogramColor(HistogramBuffer[i], prevHist);
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+