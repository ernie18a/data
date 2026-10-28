//+------------------------------------------------------------------+
//|                          CCI beginner tutorial by William210.mq5 |
//|                                             Copyright 2024, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2024, GwDs"

#property version   "1.00" // 1025

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"


//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input group "CCI beginner tutorial to learn"             // Group title
input uchar              g_CCIPeriod   = 14;             // CCI Period

// --- Graph placement
#property indicator_separate_window

// --- Buffer declaration
#property   indicator_buffers    1     // Number of buffer displayed
#property   indicator_plots      1     // Number of plot on the graph

int         g_PtCCI = INVALID_HANDLE;  // Pointer of the iCCI function

double      g_BufferCCI[];             // Data buffer
#define     g_indexCCI           0     // Index of buffer

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//--- Buffer plot characteristics
#property indicator_label1  "CCI"
#property indicator_type1   DRAW_LINE        // Plot type
#property indicator_color1  clrGreen         // Color
#property indicator_style1  STYLE_SOLID      // Plot style 
#property indicator_width1  1                // Plot width

#property indicator_levelcolor   clrRed      // Oversold and overBuy color thresholds
#property indicator_levelstyle   STYLE_DASH  // Oversold and OverBuy Style thresholds
#property indicator_levelwidth   1           // Oversold and OverBuy Thickness Thresholds
#property indicator_level1       -100.0
#property indicator_level2        100.0
#property indicator_level3        0
#property indicator_applied_price PRICE_TYPICAL

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
int OnInit()

{
  Comment( "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase");
  return( INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|   OnCalculate                                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])

{

  return(rates_total);
}

//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
void OnDeinit(const int reason)

{
  Comment("");
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
