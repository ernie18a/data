//+------------------------------------------------------------------+
//|                             Dev - MovingAverages.mqh Part II.mq5 |
//|                                             Copyright 2024, GwDs |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
#property copyright "Copyright 2024, GwDs"
#property version   "1.00" // 1007

#property description "MovingAverages.mqh very simply.\nA multi timeframe version is available for developers or profitable traders for free under conditions"

#include <MovingAverages.mqh>

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Variables and lists
enum g_PriceType

{
  PRICE_H,   // High
  PRICE_O,   // Open
  PRICE_L,   // Low
  PRICE_C    // Close
};

enum ENUM_MA_METHOD_EXTENDED

{
  ExtMODE_SMA,          // Simple Moving Average
  ExtMODE_EMA,          // Exponential Moving Average
  ExtMODE_SMMA,         // Smoothed Moving Average
  ExtMODE_LWMA_CLASSIC, // Linear Weighted Moving Average - Classic
  ExtMODE_LWMA_FAST     // Linear Weighted Moving Average - Fast
};

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Value to use “fast” LWMA
int g_weight_sum = 0;

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input uchar                   g_MAPeriod  = 20;           // Averaging period
input uchar                   g_MAShift   = 0;            // Horizontal shift
input ENUM_MA_METHOD_EXTENDED g_MAMethod  = ExtMODE_SMA;  // Smoothing type
input g_PriceType             g_MAApplied = 3;            // Type of price

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_chart_window

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// ---  Buffer declaration
#property   indicator_buffers    1    // Number of buffer displayed    
#property   indicator_plots      1    // number of plot on the graph

int         g_PtMA = INVALID_HANDLE;  // Pointer of the iMA function

double      g_BufferMA[];             // Data buffer
#define     g_indexiMA           0    // Index of buffer


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
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
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Transforms the array into display buffer and horizontal shift
  if ( ! SetIndexBuffer( g_indexiMA, g_BufferMA, INDICATOR_DATA)) {
    PrintFormat( "%s: Error %d SetIndexBuffer( g_BufferMA)", __FUNCTION__, GetLastError());
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Shift
  if ( ! PlotIndexSetInteger( g_indexiMA, PLOT_SHIFT, g_MAShift)) {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)", __FUNCTION__, GetLastError());
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
// --- Variables
  int i_CalcResult = 0;


//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Determine the starting index for calculations
  int i_Start     = 0;   // Start of patch


  if( prev_calculated == 0) {
    // --- During the first run, we start from an index that ensures
    // there are enough bars behind it for the calculations.
    i_Start = g_MAPeriod - 1;
    ArrayInitialize( g_BufferMA, EMPTY_VALUE);
  } else {
    // ---During subsequent runs, we start from where we left off
    // during the previous calculation (prev_calculated),
    // effectively only considering new bars.
    i_Start = prev_calculated;
  }

    if( g_MAMethod == ExtMODE_SMA) {
      //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
      switch ( g_MAApplied) {
      case PRICE_H:
        i_CalcResult = SimpleMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, high, g_BufferMA);
        break;

      case PRICE_O:
        i_CalcResult = SimpleMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, open, g_BufferMA);
        break;

      case PRICE_L:
        i_CalcResult = SimpleMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, low, g_BufferMA);
        break;

      case PRICE_C:
      default:
        i_CalcResult = SimpleMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, close, g_BufferMA);
      }
      if( i_CalcResult == 0)
        PrintFormat( "%s: The function SimpleMAOnBuffer returned 0", __FUNCTION__);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == ExtMODE_EMA) {
      switch ( g_MAApplied) {
      case PRICE_O:
        i_CalcResult = ExponentialMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, open, g_BufferMA);
        break;

      case PRICE_H:
        i_CalcResult = ExponentialMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, high, g_BufferMA);
        break;

      case PRICE_L:
        i_CalcResult = ExponentialMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, low, g_BufferMA);
        break;

      case PRICE_C:
      default:
        i_CalcResult = ExponentialMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, close, g_BufferMA);
      }

      if( i_CalcResult == 0)
        PrintFormat( "%s: The function ExponentialMAOnBuffer returned 0", __FUNCTION__);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == ExtMODE_SMMA) {
      switch ( g_MAApplied) {
      case PRICE_O:
        i_CalcResult = SmoothedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, open, g_BufferMA);
        break;

      case PRICE_H:
        i_CalcResult = SmoothedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, high, g_BufferMA);
        break;

      case PRICE_L:
        i_CalcResult = SmoothedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, low, g_BufferMA);
        break;

      case PRICE_C:
      default:
        i_CalcResult = SmoothedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, close, g_BufferMA);
      }
      if( i_CalcResult == 0)
        PrintFormat( "%s: The function SmoothedMAOnBuffer returned 0", __FUNCTION__);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == ExtMODE_LWMA_CLASSIC) {
      switch ( g_MAApplied) {
      case PRICE_O:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, open, g_BufferMA);
        break;

      case PRICE_H:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, high, g_BufferMA);
        break;


      case PRICE_L:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, low, g_BufferMA);
        break;

      case PRICE_C:
      default:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, close, g_BufferMA);
      }

      if( i_CalcResult == 0)
        PrintFormat( "%s: The function LinearWeightedMAOnBuffer returned 0", __FUNCTION__);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == ExtMODE_LWMA_FAST) {
      switch ( g_MAApplied) {
      case PRICE_O:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, open, g_BufferMA, g_weight_sum);
        break;

      case PRICE_H:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, high, g_BufferMA, g_weight_sum);
        break;

      case PRICE_L:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, low, g_BufferMA, g_weight_sum);
        break;

      case PRICE_C:
      default:
        i_CalcResult = LinearWeightedMAOnBuffer( rates_total, prev_calculated, 0, g_MAPeriod, close, g_BufferMA, g_weight_sum);
      }

      if( i_CalcResult == 0)
        PrintFormat( "%s: The function LinearWeightedMAOnBuffer returned 0", __FUNCTION__);
    }
  
  return( rates_total);
}

//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
void OnDeinit(const int reason)

{

  Comment( "");
// --- Deleting handle if valid
  if( g_PtMA != INVALID_HANDLE)

  {
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