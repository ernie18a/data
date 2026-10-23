//+---------------------------------------------------------------------------+
//|       Awesome Oscillator without iAO- beginner tutorial by William210.mq5 |
//|                                                      Copyright 2023, GwDs |
//|                                             Need more help? Contact me on |
//|                                  https://www.mql5.com/fr/users/william210 |
//+---------------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.04" // 965

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input group "AO - Awesome Oscillator - beginner tutorial to learn"    // Group title
input uchar g_AOMAPeriodFast  = 5;                                    // Fast Moving Average Period
input ENUM_MA_METHOD            g_AOMaMethodFast;                     // Smoothing type
input ENUM_APPLIED_PRICE        g_AOapplied_priceFast = PRICE_MEDIAN; // Type of price or handle

input group "--- > Parameter for the Slow moving average"             // Title
input uchar g_AOMAPeriodSlow  = 34;                                   // Fast Moving Average Period
input ENUM_MA_METHOD            g_AOMaMethodSlow;                     // Smoothing type
input ENUM_APPLIED_PRICE        g_AOapplied_priceSlow = PRICE_MEDIAN; // Type of price or handle

// ---Graph placement
#property indicator_separate_window

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Buffer declaration
#property   indicator_buffers    4     // Number of buffer displayed

double g_AOBuffer[];                   // Buffer Awesome oscillator
#define g_indexAOBuffer          0     // Index of buffer

double g_AOBufferColor[];              // Buffer for path colors
#define g_indexBufferColor       1     // Index of buffer

int g_PtMAFast = INVALID_HANDLE;       // Pointer for the fast moving average
double g_AOBufferFast[];               // Average calculation buffer
#define g_indexBufferFast        3     // Index of buffer

int g_PtMASlow = INVALID_HANDLE;       // Pointer for slow moving average
double g_AOBufferSlow[];
#define g_indexBufferSlow        2     // Index of buffer

#property   indicator_plots      1     // Number of plot on the graph

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// ---Buffer plot characteristics
#property indicator_label1  "Awesome Oscillator"   // Plot Label
#property indicator_type1   DRAW_COLOR_HISTOGRAM   // Plot Style
#property indicator_color1  Green,Red              // Plot Colors
#property indicator_width1  1                      // Plot Width


//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()

{
  Comment( "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase");
  return( INIT_SUCCEEDED);
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
