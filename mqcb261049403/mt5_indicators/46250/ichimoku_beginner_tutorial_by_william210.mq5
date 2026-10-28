//+------------------------------------------------------------------+
//|                                   Ichimoku beginner tutorial.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"

#property version   "1.03" // 987

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"


//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input group "Ichimoku beginner tutorial beginner tutorial to learn"

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Indicator preference
input uchar   g_tenkan_sen   = 9;     // Period of Tenkan-sen
input uchar   g_kijun_sen    = 26;    // Period of Kijun-sen
input uchar   g_senkou_span_b = 52;   // Period of Senkou Span B


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_chart_window

// ---  Buffer declaration
#property   indicator_buffers      5      // Number of buffer displayed    
#property indicator_plots          4      // number of plot on the graph      

int      g_ptIshimoku = INVALID_HANDLE;   // Pointer of the Ishimoku function

double   g_BuffTenkan_sen[];              // Buffer TENKANSEN
#define  g_indexBuffTenkan         0      // Index of Tenkan

double   g_BuffKijun_sen[];               // Buffer KIJUNSEN
#define  g_indexBuffKijun          1      // Index of Kinjun

double   g_BuffSenkou_Span_A[];           // Buffer SENKOU
#define  g_indexBuffSenkou_A       2      // Index of Senkou A

double   g_BuffSenkou_Span_B[];           // Buffer SENKOU
#define  g_indexBuffSenkou_B       3      //Index of Senkou B

double   g_BuffChinkou[];                 // Buffer CHIKOU
#define  g_indexBuffChinkou        4      // Index of Chinkou


//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Buffer plot characteristics
#property indicator_label1  "Tenkan_sen"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Kijun_sen"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

// --- two fields will be shown in Data Window
#property indicator_label3  "Senkou Span A;Senkou Span B"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  clrSandyBrown, clrThistle
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Chinkou_Span"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLime
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

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
