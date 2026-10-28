#property copyright "Copyright \x00A9 2022, Fernando M. I. Carreiro, All rights reserved"
#property link      "https://www.mql5.com/en/users/FMIC"
#property version   "1.001"
#property strict

// Default tick event handler
   void OnTick()
   {
      // Check for new bar (compatible with both MQL4 and MQL5).
         static datetime dtBarCurrent  = WRONG_VALUE;
                datetime dtBarPrevious = dtBarCurrent;
                         dtBarCurrent  = iTime( _Symbol, _Period, 0 );
                bool     bNewBarEvent  = ( dtBarCurrent != dtBarPrevious );

      // React to a new bar event and handle it.
         if( bNewBarEvent )
         {
            // Detect if this is the first tick received and handle it.
               /* For example, when it is first attached to a chart and
                  the bar is somewhere in the middle of its progress and
                  it's not actually the start of a new bar. */
               if( dtBarPrevious == WRONG_VALUE )
               {
                  // Do something on first tick or middle of bar ...
               }
               else
               {
                  // Do something when a normal bar starts ...
               };

            // Do something irrespective of the above condition ...
         }
         else
         {
            // Do something else ...
         };

      // Do other things ...
   };
