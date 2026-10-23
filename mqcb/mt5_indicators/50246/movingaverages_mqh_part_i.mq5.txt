//+------------------------------------------------------------------+
//|                                    MovingAverages.mqh Part I.mq5 |
//|                                             Copyright 2024, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
#property copyright "Copyright 2024, GwDs"
#property version   "1.01" // 1272

#property description "MovingAverages.mqh very simply.\nA multi timeframe version is available for developers or profitable traders for free under conditions"

#include <MovingAverages.mqh>

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
enum g_PriceType {
  PRICE_H,   // High
  PRICE_O,   // Open
  PRICE_L,   // Low
  PRICE_C    // Close
};

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input uchar                g_MAPeriod  = 20;           // Averaging period
input uchar                g_MAShift   = 0;            // Horizontal shift
input ENUM_MA_METHOD       g_MAMethod  = MODE_SMA;     // Smoothing type
input g_PriceType          g_MAApplied = 3;            // Type of price

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


  if ( ! PlotIndexSetInteger( g_indexiMA, PLOT_SHIFT, g_MAShift)) {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)", __FUNCTION__, GetLastError());
  }


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
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

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Variables
  int i = 0;
  int i_Diff = 0;
  double i_Price[];

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
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
    i_Start = prev_calculated - 1;
  }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
  for( int i = i_Start; i < rates_total && !IsStopped(); i++) {
    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == MODE_SMA) {
      switch ( g_MAApplied) {
      case PRICE_H:
        g_BufferMA[ i] = SimpleMA( i, g_MAPeriod, high);
        break;

      case PRICE_O:
        g_BufferMA[ i] = SimpleMA( i, g_MAPeriod, open);
        break;

      case PRICE_L:
        g_BufferMA[ i] = SimpleMA( i, g_MAPeriod, low);
        break;

      case PRICE_C:
      default:
        g_BufferMA[ i] = SimpleMA( i, g_MAPeriod, close);
      }
    }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == MODE_EMA) {
      switch ( g_MAApplied) {
      case PRICE_O:
        if( i == g_MAPeriod - 1)
          // --- // --- First point EMA is an SMA
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, open);
        else
          //  ---- all other EMA points
          g_BufferMA[ i] = ExponentialMA( i, g_MAPeriod, g_BufferMA[ i - 1], open);
        break;

      case PRICE_H:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, high);
        else
          g_BufferMA[ i] = ExponentialMA( i, g_MAPeriod, g_BufferMA[ i - 1], high);
        break;

      case PRICE_L:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, low);
        else
          g_BufferMA[ i] = ExponentialMA( i, g_MAPeriod, g_BufferMA[ i - 1], low);
        break;

      case PRICE_C:
      default:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, close);
        else
          g_BufferMA[ i] = ExponentialMA( i, g_MAPeriod, g_BufferMA[ i - 1], close);
        break;
      }
    }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == MODE_SMMA) {
      switch ( g_MAApplied) {
      case PRICE_O:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, open);
        else
          //  ---- all other EMA points
          g_BufferMA[ i] = SmoothedMA( i, g_MAPeriod, g_BufferMA[ i - 1], open);
        break;

      case PRICE_H:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, high);
        else
          g_BufferMA[ i] = SmoothedMA( i, g_MAPeriod, g_BufferMA[ i - 1], high);
        break;

      case PRICE_L:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, low);
        else
          g_BufferMA[ i] = SmoothedMA( i, g_MAPeriod, g_BufferMA[ i - 1], low);
        break;

      case PRICE_C:
      default:
        if( i == g_MAPeriod - 1)
          g_BufferMA[i] = CalculateFirstSMA( g_MAPeriod, close);
        else
          g_BufferMA[ i] = SmoothedMA( i, g_MAPeriod, g_BufferMA[ i - 1], close);
        break;
      }
    }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    if( g_MAMethod == MODE_LWMA) {
      switch ( g_MAApplied) {
      case PRICE_H:
        g_BufferMA[ i] = LinearWeightedMA( i, g_MAPeriod, high);
        break;

      case PRICE_O:
        g_BufferMA[ i] = LinearWeightedMA( i, g_MAPeriod, open);
        break;

      case PRICE_L:
        g_BufferMA[ i] = LinearWeightedMA( i, g_MAPeriod, low);
        break;

      case PRICE_C:
      default:
        g_BufferMA[ i] = LinearWeightedMA( i, g_MAPeriod, close);
      }
    }
  }

  return( rates_total);
}


//+------------------------------------------------------------------+
//| CalculateFirstSMA                                                |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
double CalculateFirstSMA( const int period,
                          const double & price[]
                        )

{
  double i_SMA = 0.0;
  for( int j = 0; j < period; j++) {
    i_SMA += price[j];
  }
  return i_SMA / period;
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
  if( g_PtMA != INVALID_HANDLE) {
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
