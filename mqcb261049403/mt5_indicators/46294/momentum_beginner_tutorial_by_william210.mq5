//+------------------------------------------------------------------+
//|                                   Momentum beginner tutorial.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.01"

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input group "Momentum beginner tutorial beginner tutorial to learn" // // Group title

input uchar                g_MomentumPerid = 14;           // Momentum Period
input ENUM_APPLIED_PRICE   g_applBar       = PRICE_CLOSE;  // Applied to


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_separate_window

// ---  Buffer declaration
#property   indicator_buffers      1      // Number of buffer displayed    

int      g_ptMomentum = INVALID_HANDLE;   // Pointer of the Momentum

double   g_BuffMomentum[];                // Buffer Momentum
#define  g_indexBuffTMomentum      0      // Index of Momentum

#property indicator_plots          1      // number of plot on the graph      

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Buffer plot characteristics

#property indicator_label1  "Momentum"      // Plot Label
#property indicator_type1   DRAW_LINE       // Plot Type
#property indicator_color1  clrDodgerBlue   // Plot color
#property indicator_style1  STYLE_SOLID     // Plot Style
#property indicator_width1  1               // Plot width 

#property indicator_levelcolor   clrRed     // Plot Color Baseline
#property indicator_levelstyle   STYLE_DASH // Plot style Baseline  
#property indicator_levelwidth   1          // Plot width baseline  
#property indicator_level2       100        // Baseline value

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
