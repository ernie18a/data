Calculation: Pair high = maximum high of the first eligible pair of consecutive candles with opposite candle colors in the day; accept the pair only if its high-low range satisfies the enabled maximum-range filter
Calculation: Pair low = minimum low of that same pair
Calculation: Long target = pair high + (pair high - pair low) × configured reward-to-risk ratio
Calculation: Short target = pair low - (pair high - pair low) × configured reward-to-risk ratio
Long: close crosses above pair high AND a pair has been accepted for the day AND position is flat AND daily trade count is below its limit
Short: close crosses below pair low AND a pair has been accepted for the day AND position is flat AND daily trade count is below its limit
Exit: long, low <= pair low OR high >= long target OR time >= configured exit time
Exit: short, high >= pair high OR low <= short target OR time >= configured exit time