Calculation: Squeeze fired = the Bollinger Bands are outside the wide Keltner Channel on the current bar and were inside at least one of the narrow, medium, or wide Keltner Channels on the previous bar.
Calculation: Momentum = linear regression, at the current bar, of close minus the average of (highest high and lowest low over a lookback) and the simple moving average of close over that same lookback.
Calculation: Weakening momentum = momentum is positive and below its previous value, or negative and above its previous value.
Calculation: Bullish moving-average stack = the shortest-period moving average is above the next-shortest, continuing in descending order of period through all enabled moving averages; bearish moving-average stack = the reverse order. The moving averages use successively longer lookbacks.
Calculation: Directional movement = smoothed positive and negative directional movement, each divided by smoothed true range, using the same lookback; trend strength = the smoothed directional-movement index using that lookback.
Long: On any configured timeframe, momentum > 0 AND NOT weakening momentum
Long: On any configured timeframe, bullish moving-average stack
Long: On any configured timeframe, trend strength >= its threshold AND positive directional movement > negative directional movement
Long: On any configured timeframe, squeeze fired AND momentum > 0
Short: On any configured timeframe, momentum < 0 AND NOT weakening momentum
Short: On any configured timeframe, bearish moving-average stack
Short: On any configured timeframe, trend strength >= its threshold AND negative directional movement > positive directional movement
Short: On any configured timeframe, squeeze fired AND momentum < 0
Exit: Long, momentum <= 0 OR momentum is below its previous value and its previous value is below the value two bars ago
Exit: Short, momentum >= 0 OR momentum is above its previous value and its previous value is above the value two bars ago