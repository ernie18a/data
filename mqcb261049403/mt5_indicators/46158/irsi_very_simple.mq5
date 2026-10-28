//+------------------------------------------------------------------+
//|                                         iRSI Very Simple.mq5.mq5 |
//|                                             Copyright 2023, GwDs |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"

#property version   "1.02" // 1275

#property description "iRSI() very simply.\nA multi timeframe version is available for developers or profitable traders for free under conditions"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input uchar              g_RsiPeriod   = 14;             // Rsi Period
input ENUM_APPLIED_PRICE g_applBar     = PRICE_CLOSE;    // Applied to

// --- Graph placement
#property indicator_separate_window

// --- Graph heigh
#property indicator_minimum 0
#property indicator_maximum 100

// --- Buffer declaration
#property   indicator_buffers    1     // Number of buffer displayed
#property   indicator_plots      1     // Number of plot on the graph

int         g_PtRsi = INVALID_HANDLE;  // Pointer of the iRsi function

double      g_BufferRsi[];             // Data buffer
#define     g_indexRsi           0     // Index of buffer

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//--- Buffer plot characteristics
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
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
int OnInit()

{
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- handle Creation
  g_PtRsi = iRSI( _Symbol, _Period, g_RsiPeriod, g_applBar);
  if( g_PtRsi == INVALID_HANDLE) {
    PrintFormat( "%s. Error %d when creating Rsi pointer", __FUNCTION__, GetLastError());
    return( INIT_FAILED);
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Transforms the array into display buffer
  if( ! SetIndexBuffer( g_indexRsi, g_BufferRsi, INDICATOR_DATA)) {
    PrintFormat("%s: Error retrieving data for Rsi", __FUNCTION__, GetLastError());
    return (0);
  }
  
    IndicatorSetInteger( INDICATOR_DIGITS, Digits());

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
                 const int        &spread[])        // // Array of spreads for each bar

{
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


  int i_Diff = rates_total - prev_calculated + 1;
  if ( CopyBuffer( g_PtRsi, 0, 0, i_Diff, g_BufferRsi) < 0) {
    PrintFormat("%s; Error %d in data recovery", __FUNCTION__, GetLastError());
    return (0);
  }
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
// --- Deleting handle if valid
  if( g_PtRsi != INVALID_HANDLE)

  {
    /* release the indicator resource */
    IndicatorRelease( g_PtRsi);
    g_PtRsi = INVALID_HANDLE;
  }
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
