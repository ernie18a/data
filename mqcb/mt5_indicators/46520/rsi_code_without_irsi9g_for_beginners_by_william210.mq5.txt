//+------------------------------------------------------------------+
//|          Rsi code without irsi() for beginners by William210.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.02"  // 968
#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
/*--- Indicator preference */
input group "Rsi without IRsi() beginner tutorial to learn" // Rsi settings
input uchar              g_RsiPeriod = 14;                  // Rsi Period


/*--- Graph placement */
#property indicator_separate_window

/*--- Graph heigh */
#property indicator_minimum 0
#property indicator_maximum 100

/* Buffer declaration */
#property   indicator_buffers    1     // Number of buffer displayed
double      g_BufferRsi[];             // Data buffer
#define     g_indexRsi           0     // Index for this buffer

#property   indicator_plots      1     // Number of plot on the graph

/*--- Buffer plot characteristics */
#property indicator_label1  "Rsi"
#property indicator_type1   DRAW_LINE        // Plot type
#property indicator_color1  clrGreen         // Color
#property indicator_style1  STYLE_SOLID      // Plot style 
#property indicator_width1  1                // Plot width

#property indicator_levelcolor   clrRed      // Oversold and overBuy color thresholds
#property indicator_levelstyle   STYLE_DASH  // Oversold and OverBuy Style thresholds
#property indicator_levelwidth   1           // Oversold and OverBuy Thickness Thresholds
#property indicator_level2       70          // Hard-coded value
#property indicator_level3       30

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
  return( rates_total);
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
