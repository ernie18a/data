Calculation: Smoothed volume ratio = EMA of (short-term SMA of volume / long-term SMA of volume), with the short-term lookback shorter than the long-term lookback
Calculation: Prior rolling high = highest high over the breakout lookback, excluding the current bar
Calculation: Prior rolling low = lowest low over the breakout lookback, excluding the current bar
Calculation: Stop distance = ATR on the entry bar × stop multiplier
Calculation: Long stop = entry price − stop distance
Calculation: Long target = entry price + stop distance × reward-to-risk ratio
Calculation: Short stop = entry price + stop distance
Calculation: Short target = entry price − stop distance × reward-to-risk ratio
Long: close > prior rolling high AND smoothed volume ratio >= normal-volume ceiling
Short: close < prior rolling low AND smoothed volume ratio >= normal-volume ceiling
Exit: Long, low <= long stop OR (low > long stop AND high >= long target)
Exit: Short, high >= short stop OR (high < short stop AND low <= short target)