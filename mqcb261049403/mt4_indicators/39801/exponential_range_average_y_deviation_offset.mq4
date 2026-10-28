//---------------------------------------------------------------------------------------------------------------------
#define     MName          "Exponential Range Average & Deviation Offset"
#define     MVersion       "1.0"
#define     MBuild         "2022-06-25 14:58 WEST"
#define     MCopyright     "Copyright \x00A9 2022, Fernando M. I. Carreiro, All rights reserved"
#define     MProfile       "https://www.mql5.com/en/users/FMIC"
//---------------------------------------------------------------------------------------------------------------------
#property   strict
#property   version        MVersion
#property   description    MName
#property   description    "MetaTrader Indicator (Build "MBuild")"
#property   copyright      MCopyright
#property   link           MProfile
//---------------------------------------------------------------------------------------------------------------------

//--- Setup

   #property indicator_separate_window

   // Define number of buffers and plots
      #define MPlots    2
      #define MBuffers  3
      #ifdef __MQL4__
         #property indicator_buffers   MPlots
      #else
         #property indicator_buffers   MBuffers
         #property indicator_plots     MPlots
      #endif

   // Display properties for plots
      #property indicator_label1 "Range Average"
      #property indicator_label2 "Deviation Offset"
      #property indicator_color1 C'38,166,154'
      #property indicator_color2 C'239,83,80'
      #property indicator_width1 1
      #property indicator_width2 1
      #property indicator_style1 STYLE_SOLID
      #property indicator_style2 STYLE_DOT
      #property indicator_type1  DRAW_LINE
      #property indicator_type2  DRAW_LINE

//--- Parameter settings

   input double   i_dbPeriod  = 13.0;   // Averaging period

//--- Macro definitions

   // Define OnCalculate loop sequencing macros
      #define MOnCalcPrevTest ( prev_calculated < 1 || prev_calculated > rates_total )
      #ifdef __MQL4__   // for MQL4 (as series)
         #define MOnCalcNext(  _index          ) ( _index--             )
         #define MOnCalcBack(  _index, _offset ) ( _index + _offset     )
         #define MOnCalcCheck( _index          ) ( _index >= 0          )
         #define MOnCalcValid( _index          ) ( _index < rates_total )
         #define MOnCalcStart \
            ( rates_total - ( MOnCalcPrevTest ? 1 : prev_calculated ) )
      #else             // for MQL5 (as non-series)
         #define MOnCalcNext(  _index          ) ( _index++             )
         #define MOnCalcBack(  _index, _offset ) ( _index - _offset     )
         #define MOnCalcCheck( _index          ) ( _index < rates_total )
         #define MOnCalcValid( _index          ) ( _index >= 0          )
         #define MOnCalcStart \
            ( MOnCalcPrevTest ? 0 : prev_calculated - 1 )
      #endif

   // Define macro for invalid parameter values
      #define MCheckParameter( _condition, _text ) if( _condition ) \
         { Print( "Error: Invalid ", _text ); return INIT_PARAMETERS_INCORRECT; }

   // Define macro for calculating and assigning exponential moving average
      #define MCalcEma( _var, _value, _weight ) \
         _var = _var##Prev + ( _value - _var##Prev ) * _weight

//--- Global variable declarations

   // Indicator buffers
      double
         g_adbRangeAverage[],    // Buffer for range average
         g_adbDeltaAverage[],    // Buffer for delta average
         g_adbDeviation[];       // Buffer for deviation offset

   // Miscellaneous global variables
      double
         g_dbEmaWeight;    // Weight to be used for exponential moving averages

//--- Event handling functions

   // Initialisation event handler
      int OnInit(void)
      {
         // Validate input parameters
            MCheckParameter( i_dbPeriod < DBL_EPSILON, "Averaging period!" );

         // Calculate parameter variables
            g_dbEmaWeight = 2.0 / ( i_dbPeriod + 1.0 );

         // Set number of significant digits (precision)
            IndicatorSetInteger( INDICATOR_DIGITS, _Digits );

         // Set buffers
            int iBuffer = 0;
            #ifdef __MQL4__
               IndicatorBuffers( MBuffers );   // Set total number of buffers (MQL4 Only)
            #endif
            SetIndexBuffer( iBuffer++, g_adbRangeAverage, INDICATOR_DATA         );
            SetIndexBuffer( iBuffer++, g_adbDeviation,    INDICATOR_DATA         );
            SetIndexBuffer( iBuffer++, g_adbDeltaAverage, INDICATOR_CALCULATIONS );

         // Set indicator name
            IndicatorSetString( INDICATOR_SHORTNAME,
               MName + " (" + DoubleToString( i_dbPeriod, 3 ) + ")" );

         return INIT_SUCCEEDED;  // Successful initialisation of indicator
      };

   // Calculation event handler
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
         // Define local variables
            double
               dbHigh, dbLow, dbClosePrev,
               dbRange, dbRangeAverage, dbRangeAveragePrev,
               dbDelta, dbDeltaAverage, dbDeltaAveragePrev;

         // Main loop — fill in the arrays with data values
            for( int iCur  = MOnCalcStart, iPrev = MOnCalcBack( iCur, 1 );
                 !IsStopped() && MOnCalcCheck( iCur );
                 MOnCalcNext( iCur ), MOnCalcNext( iPrev ) )
            {
               // Get high and low price quotes
                  dbHigh = high[ iCur ];
                  dbLow  = low[  iCur ];

               // Calculate buffer values
                  if( MOnCalcValid( iPrev ) ) // Check if index is within array range
                  {
                     // Adjust for true range
                        dbClosePrev = close[ iPrev ];
                        if( dbClosePrev > dbHigh ) dbHigh = dbClosePrev;
                        if( dbClosePrev < dbLow )  dbLow  = dbClosePrev;

                     // Calculate range exponential moving average
                        dbRangeAveragePrev = g_adbRangeAverage[ iPrev ];
                        dbRange = dbHigh - dbLow;
                        MCalcEma( dbRangeAverage, dbRange, g_dbEmaWeight );

                     // Calculate delta exponential moving average
                        dbDeltaAveragePrev = g_adbDeltaAverage[ iPrev ];
                        dbDelta = dbRange - dbRangeAveragePrev;
                        MCalcEma( dbDeltaAverage, dbDelta, g_dbEmaWeight );
                  }
                  else
                  {
                     dbRangeAverage = dbHigh - dbLow;
                     dbDeltaAverage = 0;
                  };

               // Set buffer values
                  g_adbRangeAverage[ iCur ] = dbRangeAverage;
                  g_adbDeltaAverage[ iCur ] = dbDeltaAverage;
                  g_adbDeviation[    iCur ] = dbRangeAverage
                                            + dbDeltaAverage;
            };

         return rates_total;  // Return value for prev_calculated of next call
      };

//---------------------------------------------------------------------------------------------------------------------
