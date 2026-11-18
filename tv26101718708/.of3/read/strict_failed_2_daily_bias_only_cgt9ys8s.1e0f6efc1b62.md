Calculation: Bullish failed 2 = after at least the minimum-consecutive parameter bearish bars, a bullish bar with low < low[1], high <= high[1], and low[1] < close < high[1]
Calculation: Bearish failed 2 = after at least the minimum-consecutive parameter bullish bars, a bearish bar with high > high[1], low >= low[1], and low[1] < close < high[1]
Long: failed-2 signals enabled AND Bullish failed 2 on a chart bar
Short: failed-2 signals enabled AND Bearish failed 2 on a chart bar
Long: daily bias enabled AND Bullish failed 2 calculated on T1 bars and sampled on chart bars from the still-forming T1 bar in real time or the last completed T1 bar historically
Short: daily bias enabled AND Bearish failed 2 calculated on T1 bars and sampled on chart bars from the still-forming T1 bar in real time or the last completed T1 bar historically
Long: failed-2 signals enabled AND (bar-close confirmation disabled OR chart bar confirmed) AND Bullish failed 2 on a chart bar AND (T1 bias not required OR (daily bias enabled AND Bullish failed 2 calculated on T1 bars and sampled on chart bars from the still-forming T1 bar in real time or the last completed T1 bar historically))
Short: failed-2 signals enabled AND (bar-close confirmation disabled OR chart bar confirmed) AND Bearish failed 2 on a chart bar AND (T1 bias not required OR (daily bias enabled AND Bearish failed 2 calculated on T1 bars and sampled on chart bars from the still-forming T1 bar in real time or the last completed T1 bar historically))
Exit: long, low <= signal-bar low - stop-buffer ticks * tick size OR high >= signal-bar high[1]
Exit: short, high >= signal-bar high + stop-buffer ticks * tick size OR low <= signal-bar low[1]