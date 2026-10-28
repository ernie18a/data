//+------------------------------------------------------------------+
//|                                            Ima() Very Simple.mq5 |
//|                                             Copyright 2024, GwDs |
//|                                Join our dev team for winning EAs |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


#property copyright "Copyright 2024, GwDs"
#property link      "https://www.mql5.com/fr/users/william210"
#property version   "1.04" // 1269

#property description "Ima() very simply.\nA multi timeframe version is available for developers or profitable traders for free under conditions"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input uchar                g_MAPeriod  = 20;           // Averaging period
input uchar                g_MAShift   = 0;            // Horizontal shift
input ENUM_MA_METHOD       g_MAMethod  = MODE_SMA;     // Smoothing type
input ENUM_APPLIED_PRICE   g_MAApplied = PRICE_CLOSE;  // Type of price

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Graph placement
#property indicator_chart_window

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// ---  Buffer declaration
int         g_PtMA = INVALID_HANDLE;  // Pointer of the iMA function
#property   indicator_buffers    1    // Number of buffer displayed    
#property   indicator_plots      1    // number of plot on the graph

double      g_BufferMA[];             // Data buffer
#define     g_indexiMA           0    // Index of buffer

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Buffer plot characteristics
#property indicator_label1  "Moving average"
#property indicator_type1   DRAW_LINE        // Plot type
#property indicator_color1  clrRed           // Plot Color
#property indicator_style1  STYLE_SOLID      // Plot style
#property indicator_width1  1                // Plot width


//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()

{
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Handle Creation
  g_PtMA = iMA( _Symbol, _Period, g_MAPeriod, g_MAShift, g_MAMethod, g_MAApplied);
  if( g_PtMA == INVALID_HANDLE) {
    PrintFormat( "%s: Error %d when creating iMA pointer", __FUNCTION__, GetLastError());
    return( INIT_FAILED);
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Transforms the array into display buffer and horizontal shift
  if ( ! SetIndexBuffer( g_indexiMA, g_BufferMA, INDICATOR_DATA)) {
    PrintFormat( "%s: Error %d SetIndexBuffer( g_BufferMA)", __FUNCTION__, GetLastError());
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// Shiift
  if ( ! PlotIndexSetInteger( g_indexiMA, PLOT_SHIFT, g_MAShift)) {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)", __FUNCTION__, GetLastError());
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// Initialization
  if( ArrayInitialize( g_BufferMA, EMPTY_VALUE) == -1) {
    PrintFormat("%s: Error %d ArrayInitialize(g_BufferMA)", __FUNCTION__, GetLastError());
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
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
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
  int i_Diff = rates_total - prev_calculated + 1;
  if( CopyBuffer( g_PtMA, g_indexiMA, - g_MAShift, i_Diff, g_BufferMA) < 0)

  {
    PrintFormat( "%s: Error %n in data recovery", __FUNCTION__, GetLastError());
    return (0);
  }

  //+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
  return( rates_total);
}

//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)

{
  Comment( "");
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Deleting handle if valid
  if( g_PtMA != INVALID_HANDLE)

  {
    Comment( "");
    // --- release the indicator resource
    IndicatorRelease( g_PtMA);
    g_PtMA = INVALID_HANDLE;
  }
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
