//+------------------------------------------------------------------+
//|                 Donchian Channel for beginners by William210.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.02" // 947

#property description "Donchian Channel beginner tutorial to learn"
#property description "If this code malfunctions for whatever reasons, forgetting or MQL5 upgrades\nlet me know so I can correct it, thank you\n"
#property description "May this code help you\n"
#property description "You can find all my indicator codes in CodeBase or the Marketplace, free or purchasable, by searching for William210"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input group "Doncian Channel beginner tutorial to learn"
input uchar                g_DonPeriod    = 21;           // Period for Donchian Channel

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_chart_window

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// ---  Buffer declaration
#property   indicator_buffers    3    // Number of buffer displayed   
#property   indicator_plots      3    // number of plot on the graph

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Arrays for buffers and index
double g_BuffDonchianMD[];            // Middle band
double g_BuffDonchianUP[];            // Upper band
double g_BuffDonchianDW[];            // lower band

// --- indexesfor buffers
#define g_IndexDonchianMD 0
#define g_IndexDonchianUP 1
#define g_IndexDonchianDW 2

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//--- Buffer plot characteristics
#property indicator_label1  "Donchian Middle"   // Label
#property indicator_type1   DRAW_LINE                   // Plot type   
#property indicator_color1  clrGray                     // Color  
#property indicator_style1  STYLE_DOT                   // Plot style
#property indicator_width3  1                           // Plot width

#property indicator_label2  "Donchian upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Donchian Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

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
                 const int        &spread[])        // // Array of spreads for each bar

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
