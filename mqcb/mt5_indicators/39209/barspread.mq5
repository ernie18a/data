//---------------------------------------------------------------------------------------------------------------------
#define     MName          "Bar Spread"
#define     MVersion       "1.000"
#define     MBuild         "2022-05-01 12:31 WEST"
#define     MCopyright     "Copyright \x00A9 2022, Fernando M. I. Carreiro, All rights reserved"
#define     MProfile       "https://www.mql5.com/en/users/FMIC"
//---------------------------------------------------------------------------------------------------------------------
#property   version        MVersion
#property   description    MName
#property   description    "MetaTrader Indicator (Build "MBuild")"
#property   copyright      MCopyright
#property   link           MProfile
//---------------------------------------------------------------------------------------------------------------------

//--- Setup

   #property indicator_separate_window

   // Define number of buffers and plots
      #property indicator_buffers   1
      #property indicator_plots     1

   // Define visual appearance of plots
      #property indicator_label1 "Spread (Bar)"
      #property indicator_color1 clrDodgerBlue
      #property indicator_style1 STYLE_SOLID
      #property indicator_type1  DRAW_LINE
      #property indicator_width1 1

//--- Global variable declarations

   // Indicator buffers
      double g_adbSpread[];   // Buffer for bar's spread

//--- Event handling functions

   // Initialisation event handler
      int OnInit(void)
      {
         IndicatorSetString( INDICATOR_SHORTNAME, MName );  // Set indicator name
         IndicatorSetInteger( INDICATOR_DIGITS, 0 );        // Set number of significant digits (precision)
         SetIndexBuffer( 0, g_adbSpread, INDICATOR_DATA );  // Set buffer for bar spread
         return INIT_SUCCEEDED;                             // Successful initialisation of indicator
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
         // Main loop — fill in the arrays with data values
            for( int i = prev_calculated < 1 ? 0 : prev_calculated - 1;
                     i < rates_total; i++ )
               g_adbSpread[ i ] = spread[ i ];  // Assign the spread value to the buffer
      
         // Return value of prev_calculated for next call
            return rates_total;
      };

//---------------------------------------------------------------------------------------------------------------------