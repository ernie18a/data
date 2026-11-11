Calculation: VWAP = cumulative sum of typical price times volume divided by cumulative volume, reset at the start of each trading day; typical price is (high + low + close) / 3.
Calculation: Confirmed swing high = a bar's high that is greater than or equal to all highs in an equal-length preceding window and strictly greater than all highs in the following window; it becomes available when the following window completes. Confirmed swing low = a bar's low that is less than or equal to all lows in an equal-length preceding window and strictly less than all lows in the following window; it becomes available when the following window completes.
Calculation: Unbroken swing high and low = the most recently confirmed swing high and low, respectively; replace each when a new corresponding swing is confirmed, and clear it after close exceeds the swing high or falls below the swing low, respectively. Apply confirmations before testing the current bar's close.
Calculation: Structure direction = initially neutral; set to bullish when close exceeds the unbroken swing high and bearish when close falls below the unbroken swing low. If both occur on the same bar, set it to bearish. Retain the direction until another break.
Long: close > VWAP AND close > longer-period EMA of close AND shorter-period EMA of close > longer-period EMA of close
Short: close < VWAP AND close < longer-period EMA of close AND shorter-period EMA of close < longer-period EMA of close
Long: close > unbroken swing high
Short: close < unbroken swing low
Long: structure direction = bullish
Short: structure direction = bearish
Long: low > high two bars ago AND low - high two bars ago >= minimum gap size
Short: high < low two bars ago AND low two bars ago - high >= minimum gap size