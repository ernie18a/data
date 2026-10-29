Calculation: Normalized Williams %R = 100 + Williams %R, calculated with short-, medium-, and long-term lookbacks in increasing order, on the indicator timeframe (which may be higher or lower than the chart timeframe), using the last completed bar
Calculation: Weighted Williams %R = weighted average of normalized Williams %R at the short-, medium-, and long-term lookbacks, on the indicator timeframe using the last completed bar
Calculation: Upper weighted-WPR threshold = 67 + swing adjustment
Calculation: Lower weighted-WPR threshold = 33 − swing adjustment
Calculation: Bullish long-WPR threshold = 50 − average-swing adjustment
Calculation: Bearish long-WPR threshold = 50 + average-swing adjustment
Long: Current weighted Williams %R > upper weighted-WPR threshold AND current long-term normalized Williams %R >= bullish long-WPR threshold AND the most recent earlier non-neutral trend state was bearish
Short: Current weighted Williams %R < lower weighted-WPR threshold AND current long-term normalized Williams %R <= bearish long-WPR threshold AND the most recent earlier non-neutral trend state was bullish
Exit: long, short-entry condition OR (stop loss enabled AND low <= entry price − stop-loss distance) OR (take profit enabled AND high >= entry price + take-profit distance)
Exit: short, long-entry condition OR (stop loss enabled AND high >= entry price + stop-loss distance) OR (take profit enabled AND low <= entry price − take-profit distance)