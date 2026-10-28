//+------------------------------------------------------------------+
//|                                       MACD beginner tutorial.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.02"

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input group "MACD beginner tutorial beginner tutorial to learn"
input uchar                g_MACDFast     = 12;          // Period of fast ma
input uchar                g_MACDLow      = 26;          // Period of slow ma
input uchar                g_MACDSignal   = 9;           // Period of averaging of difference
input ENUM_APPLIED_PRICE   g_MACDApplied  = PRICE_CLOSE; // Type of price


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property   indicator_separate_window   // Under the graph
#property   indicator_plots      2    // number of plot on the graph
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// ---  Buffer declaration
#property   indicator_buffers    2    // Number of buffer displayed    

int         g_PtMACD = INVALID_HANDLE;// Pointer of the BB function

double      g_BuffMACD[];             // Data buffer MACD
#define     g_indexBuffMACD      0    // Index of buffer MACD

double      g_BuffMACDSig[];          // Data buffer MACD Signal
#define     g_indexBuffMACDSig   1    // Index of buffer MACD Signal



//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Buffer plot characteristics
#property indicator_label1  "MACD"           // Label
#property indicator_type1   DRAW_HISTOGRAM   // Plot type
#property indicator_color1  clrSilver        // Plot color
#property indicator_style1  STYLE_SOLID      // Plot style
#property indicator_width1  1                // Plot width

#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()

{
Comment( "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase");

  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|   OnCalculate                                                    |
//+------------------------------------------------------------------+
int OnCalculate( const int        rates_total,      // Total number of bars to be processed
                 const int        prev_calculated,  // Number of bars calculated in the previous call
                 const datetime   &time[],          // Array of bar times
                 const double     &open[],          // Array of bar open prices
                 const double     &high[],          // Array of bar high prices
                 const double     &low[],           // Array of bar low prices
                 const double     &close[],         // Array of bar close prices
                 const long       &tick_volume[],   // Array of tick volumes for each bar
                 const long       &volume[],        // Array of real volumes for each bar
                 const int        &spread[])        // Array of spreads for each bar

{

  return(rates_total);

}

//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)

{
Comment( "");
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
