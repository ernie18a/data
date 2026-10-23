//+---------------------------------------------------------------------------------------+
#define   _NAME_      "Dōteki Heikin Ashi"
//+---------------------------------------------------------------------------------------+

#property version     "1.001"
#property description _NAME_
#property description "MetaTrader 4/5 Indicator (Build 2018-10-16 08:51)"
#property copyright   "Copyright \x00A9 2018, Fernando M. I. Carreiro, All rights reserved"
#property link        "https://www.mql5.com/en/users/FMIC"
#property strict


//+---------------------------------------------------------------------------------------+
//  Indicator Setup
//+---------------------------------------------------------------------------------------+

#property indicator_chart_window

#ifdef __MQL5__
   #property indicator_buffers   8
   #property indicator_plots     1
   #property indicator_label1    "dhaOpen;dhaHigh;dhaLow;dhaClose"
   #property indicator_type1     DRAW_COLOR_CANDLES
   #property indicator_color1    clrLimeGreen, clrFireBrick, clrGold
#else
   #property indicator_buffers   4

   #property indicator_label1    "dhaOpen"
   #property indicator_label2    "dhaClose"
   #property indicator_label3    "dhaLowHigh"
   #property indicator_label4    "dhaHighLow"

   #property indicator_color1    clrFireBrick
   #property indicator_color2    clrLimeGreen
   #property indicator_color3    clrFireBrick
   #property indicator_color4    clrLimeGreen

   #property indicator_width1    3
   #property indicator_width2    3
   #property indicator_width3    1
   #property indicator_width4    1

   #property indicator_style1    STYLE_SOLID
   #property indicator_style2    STYLE_SOLID
   #property indicator_style3    STYLE_SOLID
   #property indicator_style4    STYLE_SOLID

   #property indicator_type1     DRAW_HISTOGRAM
   #property indicator_type2     DRAW_HISTOGRAM
   #property indicator_type3     DRAW_HISTOGRAM
   #property indicator_type4     DRAW_HISTOGRAM
#endif


//+---------------------------------------------------------------------------------------+
// Special Macro Definitions & Enumerations
//+---------------------------------------------------------------------------------------+

#ifdef __MQL4__    // for Compatibility with MQL5
   #define ENUM_DRAW_TYPE int
#endif


//+---------------------------------------------------------------------------------------+
//  Indicator Settings
//+---------------------------------------------------------------------------------------+

//--- Indicator Settings

   //---- Define Averaging Parameters
   input double
      dblPeriod      = 3.0;      // Averaging Period for Heikin Ashi (Original = 3.0)
   input bool
      boolZeroLag    = false,    // Use a Zero-Lag Exponential Averaging
      boolLineGraph  = true,     // Set Chart Mode to Line Graph
      boolHideLine   = false;    // Hide Close Line in Line Graph mode


//--- Define Global Variables
ENUM_CHART_MODE
   enumChartMode     = WRONG_VALUE; // Save the Initial Chart Mode for Deinitialisation
color
   clrChartLine      = WRONG_VALUE; // Save Colour of Line Graph for Deinitialisation
double
   dblEMAWeight,     // Weight to be used for EMA
   dblEMAComplement; // Complement of the Weight to be used for EMA

//---- Define Indicator Buffers
double
   dblBufferOpen[],  // Buffer Array for Opening Price
   dblBufferHigh[],  // Buffer Array for High Price (or Low)
   dblBufferLow[],   // Buffer Array for Low  Price (or High)
   dblBufferClose[], // Buffer Array for Closing Price
   dblBufferEMA[],   // Buffer Array for Exponential Moving Average of Total Price
   dblBufferDEMA[],  // Buffer Array for Double Exponential Moving Average
   dblBufferZEMA[];  // Buffer Array for Zero-Lag Exponential Moving Average

#ifdef __MQL5__
   double dblBufferColour[];  // Buffer Array for Candle Colour
#endif

//+---------------------------------------------------------------------------------------+
//  Indicator Functions
//+---------------------------------------------------------------------------------------+

//--- Initialise Buffer Index and other Properties
int intInvalidParameter( string strText )
{
   Print( "Error: ", strText );
   return( INIT_PARAMETERS_INCORRECT );
}
int OnInit(void)
{
   // Validate Input Parameters
   if( dblPeriod <= 1.0 )  return( intInvalidParameter( "Invalid Averaging Period!" ) );

   dblEMAWeight     = 2.0 / ( dblPeriod + 1.0 );
   dblEMAComplement = 1.0 - dblEMAWeight;

   // Set Chart Mode
   enumChartMode = WRONG_VALUE;
   clrChartLine  = WRONG_VALUE;

   if( boolLineGraph )
   {
      enumChartMode = (ENUM_CHART_MODE) ChartGetInteger( 0, CHART_MODE );
      ChartSetInteger( 0, CHART_MODE, CHART_LINE );

      if( boolHideLine )
      {
         clrChartLine = (color) ChartGetInteger( 0, CHART_COLOR_CHART_LINE );
         ChartSetInteger( 0, CHART_COLOR_CHART_LINE, clrNONE );
      }
   }

   // Set Number of Significant Digits (Precision)
   IndicatorSetInteger( INDICATOR_DIGITS, _Digits );

   // Set Buffers
   #ifdef __MQL5__
      SetIndexBuffer( 0, dblBufferOpen  , INDICATOR_DATA         );
      SetIndexBuffer( 1, dblBufferHigh  , INDICATOR_DATA         );
      SetIndexBuffer( 2, dblBufferLow   , INDICATOR_DATA         );
      SetIndexBuffer( 3, dblBufferClose , INDICATOR_DATA         );
      SetIndexBuffer( 4, dblBufferColour, INDICATOR_COLOR_INDEX  );
      SetIndexBuffer( 5, dblBufferEMA   , INDICATOR_CALCULATIONS );
      if( boolZeroLag )
      {
         SetIndexBuffer( 6, dblBufferDEMA, INDICATOR_CALCULATIONS );
         SetIndexBuffer( 7, dblBufferZEMA, INDICATOR_CALCULATIONS );
      }
      ArraySetAsSeries( dblBufferColour, true );
   #else
      IndicatorBuffers( 5 );
      SetIndexBuffer( 0, dblBufferOpen  , INDICATOR_DATA         );
      SetIndexBuffer( 1, dblBufferClose , INDICATOR_DATA         );
      SetIndexBuffer( 2, dblBufferLow   , INDICATOR_DATA         );
      SetIndexBuffer( 3, dblBufferHigh  , INDICATOR_DATA         );
      SetIndexBuffer( 4, dblBufferEMA   , INDICATOR_CALCULATIONS );
      if( boolZeroLag )
      {
         IndicatorBuffers( 7 );
         SetIndexBuffer( 5, dblBufferDEMA, INDICATOR_CALCULATIONS );
         SetIndexBuffer( 6, dblBufferZEMA, INDICATOR_CALCULATIONS );
      }
      else
      SetIndexStyle( 0, DRAW_HISTOGRAM, STYLE_SOLID );
      SetIndexStyle( 1, DRAW_HISTOGRAM, STYLE_SOLID );
      SetIndexStyle( 2, DRAW_HISTOGRAM, STYLE_SOLID );
      SetIndexStyle( 3, DRAW_HISTOGRAM, STYLE_SOLID );
   #endif

   // Set Buffers as Series
   ArraySetAsSeries( dblBufferOpen,  true );
   ArraySetAsSeries( dblBufferHigh,  true );
   ArraySetAsSeries( dblBufferLow,   true );
   ArraySetAsSeries( dblBufferClose, true );
   ArraySetAsSeries( dblBufferEMA,   true );
   if( boolZeroLag )
   {
      ArraySetAsSeries( dblBufferDEMA, true );
      ArraySetAsSeries( dblBufferZEMA, true );
   }

   // Set Indicator Name
   IndicatorSetString( INDICATOR_SHORTNAME,
      _NAME_ + ( boolZeroLag ? "(Z" : "(" ) + DoubleToString( dblPeriod, 3 ) + ")" );

   // Successful Initialisation of Indicator
   return( INIT_SUCCEEDED );
}

//--- Deinitialise Procedure
void OnDeinit(const int reason)
{
   if( boolLineGraph && ( (int) enumChartMode != WRONG_VALUE ) )
     ChartSetInteger( 0, CHART_MODE, enumChartMode );

   if( boolHideLine  && ( (int) clrChartLine  != WRONG_VALUE ) )
      ChartSetInteger( 0, CHART_COLOR_CHART_LINE, clrChartLine );
}

//--- Calculate Indicator Values
int
   OnCalculate(
      const int      rates_total,
      const int      prev_calculated,
      const datetime &time[],
      const double   &open[],
      const double   &high[],
      const double   &low[],
      const double   &close[],
      const long     &tick_volume[],
      const long     &volume[],
      const int      &spread[]
   )
{
   int intPrevCalc = prev_calculated;

   ArraySetAsSeries( open,  true );
   ArraySetAsSeries( high,  true );
   ArraySetAsSeries( low,   true );
   ArraySetAsSeries( close, true );

   // Define Local Variables
   bool
      boolUpCandle, boolDownCandle;
   double
      dblClose, dblEMA, dblDEMA = 0, dblZEMA = 0,
      dblClosePrevious, dblEMAPrevious, dblDEMAPrevious,
      dblOpen = EMPTY_VALUE, dblLow, dblHigh;
   int
      intMax         = rates_total - 1,
      intLimit       = rates_total - ( ( intPrevCalc < 1 ) ? 1 : intPrevCalc ),
      intIndex       = intLimit,
      intIndexPrev   = intIndex + 1;

   // Main Loop, Fill in the arrays with data values
   for( ; intIndex >= 0; intIndex--, intIndexPrev-- )
   {
      // Calculate Total Price for Close
      dblLow                     = low[  intIndex ];
      dblHigh                    = high[ intIndex ];
      dblBufferClose[ intIndex ] =
      dblClose                   = NormalizeDouble(
                                    (   open[  intIndex ]
                                      + dblHigh
                                      + dblLow
                                      + close[ intIndex ]
                                    ) * 0.25,
                                    _Digits );

      // Calculate other Buffer Values
      if( intIndex < intMax )
      {
         // Get Previous Total Price
         dblClosePrevious = dblBufferClose[ intIndexPrev ];

         // Update EMA Values
         dblEMAPrevious = dblBufferEMA[ intIndexPrev ];
         dblOpen        =
         dblEMA         = dblEMAPrevious
                        + ( dblClosePrevious - dblEMAPrevious )
                        * dblEMAWeight;

         // Update DEMA and ZEMA
         if( boolZeroLag )
         {
            dblDEMAPrevious           = dblBufferDEMA[ intIndexPrev ];
            dblBufferDEMA[ intIndex ] =
            dblDEMA                   = dblDEMAPrevious
                                      + ( dblEMA - dblDEMAPrevious )
                                      * dblEMAWeight;
            dblBufferZEMA[ intIndex ] =
            dblOpen                   =
            dblZEMA                   = dblEMA * 2 - dblDEMA;
         }

         dblLow  = fmin( fmin( dblLow,  dblOpen ), dblClose );
         dblHigh = fmax( fmax( dblHigh, dblOpen ), dblClose );
      }
      else
      {
         // Define Initial Values
         dblClosePrevious =
         dblOpen          =
         dblZEMA          =
         dblDEMA          =
         dblEMA           = open[ intIndex ]
                          + ( close[ intIndex ] - open[ intIndex ] )
                          * dblEMAWeight;
      }

      // Set Buffer Values
      dblBufferEMA[ intIndex ] = dblEMA;

      if( boolZeroLag )
      {
         dblBufferDEMA[ intIndex ] = dblDEMA;
         dblBufferZEMA[ intIndex ] = dblZEMA;
      }

      dblBufferOpen[ intIndex ] =
      dblOpen                   = NormalizeDouble( dblOpen, _Digits );

      boolUpCandle   = dblOpen < dblClose;
      boolDownCandle = dblOpen > dblClose;

      #ifdef __MQL5__
         dblBufferLow[    intIndex ] = dblLow;
         dblBufferHigh[   intIndex ] = dblHigh;
         dblBufferColour[ intIndex ] = boolUpCandle ? 0 : ( boolDownCandle ? 1 : 2 );
      #else
         if( !boolUpCandle && !boolDownCandle )
            boolUpCandle = dblClosePrevious < dblClose;
         if( boolUpCandle )
         {
            dblBufferLow[  intIndex ] = dblLow;
            dblBufferHigh[ intIndex ] = dblHigh;
         }
         else
         {
            dblBufferLow[  intIndex ] = dblHigh;
            dblBufferHigh[ intIndex ] = dblLow;
         }
      #endif
   }

   // Return value of prev_calculated for next call
   return( rates_total );
}

//+---------------------------------------------------------------------------------------+