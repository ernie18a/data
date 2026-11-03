Calculation: Adaptive range = selected moving average of the absolute source change, averaged over a lookback, then averaged again over a longer lookback (roughly twice as long), and multiplied by a range multiplier.
Calculation: Range filter = source minus adaptive range if that value is above the previous filter; source plus adaptive range if that value is below the previous filter; otherwise the previous filter. Initialize the previous filter from the source; use the source while the adaptive range is unavailable.
Calculation: Trend state = bullish on an upward filter step, bearish on a downward filter step, otherwise retain the prior state; if neutral mode is enabled, change an active state to neutral after the filter stays flat for the configured consecutive-bar count. Update on completed chart bars.
Long: Range filter > previous range filter AND prior trend state is not bullish
Short: Range filter < previous range filter AND prior trend state is not bearish
Exit: Long, range filter < previous range filter OR neutral mode is enabled AND trend state changes to neutral
Exit: Short, range filter > previous range filter OR neutral mode is enabled AND trend state changes to neutral