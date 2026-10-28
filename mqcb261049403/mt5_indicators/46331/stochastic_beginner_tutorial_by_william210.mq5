//+------------------------------------------------------------------+
//|                                 Stochastic beginner tutorial.mq5 |
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

// --- Indicator preference
input group "Stochastic beginner tutorial beginner tutorial to learn" // // Group title


//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input uchar          g_StoKPeriod     = 5;           // K-period (number of bars for calculations
input uchar          g_StoDPeriod     = 3;           // D period (the period of primary
input uchar          g_StoSlowing     = 3;           // Period of final smoothing
input ENUM_MA_METHOD g_StoMethod      = MODE_SMA;    // Type of smoothing
input ENUM_STO_PRICE g_StoPrice_field = STO_LOWHIGH; // Method of calculation

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_separate_window

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph heigh
#property indicator_minimum 0
#property indicator_maximum 100

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// ---  Buffer declaration
#property   indicator_buffers      2      // Number of buffer displayed    

int      g_ptStochastic = INVALID_HANDLE; // Pointer of the Stochastic

double   g_BuffSto[];                     // Buffer Stochastic
#define  g_indexBuffSto          0        // Index of Stochastic

double   g_BuffStoSignal[];               // Buffer Stochastic Signal
#define  g_indexBuffStoSign      1        // Index of Stochastic Signal


#property indicator_plots        2      // number of plot on the graph      

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//--- Buffer plot characteristics

#property indicator_label1       "Stochastic"     // Plot Label
#property indicator_type1        DRAW_LINE        // Plot Type
#property indicator_color1       clrGreen         // Plot color
#property indicator_style1       STYLE_SOLID      // Plot Style
#property indicator_width1       1                // Plot width

#property indicator_label2       "Stochastic Signal"
#property indicator_type2        DRAW_LINE
#property indicator_color2       clrRed
#property indicator_style2       STYLE_DOT
#property indicator_width2       1

#property indicator_levelcolor   clrRed      // Oversold and overBuy color thresholds
#property indicator_levelstyle   STYLE_DASH  // Oversold and OverBuy Style thresholds
#property indicator_levelwidth   1           // Oversold and OverBuy Thickness Thresholds
#property indicator_level2       80          // Hard-coded value
#property indicator_level3       20

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
int OnInit()

{
  Comment( "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase");
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|   OnCalculate                                                    |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
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
//+--------------------------------,---------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
void OnDeinit(const int reason)

{
  Comment( "");
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
