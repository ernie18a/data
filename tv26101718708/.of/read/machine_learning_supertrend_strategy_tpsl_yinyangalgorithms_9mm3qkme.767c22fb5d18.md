Calculation: SuperTrend = ATR bands around HL2, trailed using the prior bands and close; the active band is the upper band in a bearish trend and the lower band in a bullish trend.
Calculation: ML SuperTrend = KNN average of the midpoints of the fast and slow moving averages of SuperTrend; retain observations whose slow-minus-fast distance is between the minimum and maximum of the first K historical distances, filtering to the current trend direction. The fast lookback is shorter than the slow lookback.
Calculation: Trend = bullish when close > the stop line; bearish otherwise.
Calculation: Stop line = ML SuperTrend adjusted by the stop-loss multiplier, below the line when bullish and above it when bearish.
Calculation: Take-profit level = ML SuperTrend adjusted by the take-profit multiplier, above the line when bullish and below it when bearish.
Long: Trend is bullish AND prior trend was bearish; place a stop entry at the stop line.
Short: Trend is bearish AND prior trend was bullish; place a stop entry at the stop line.
Exit: Long, Trend is bearish AND prior trend was bullish OR close > take-profit level OR same-bar entry and exit is enabled AND stop-loss is enabled AND prior trend was bullish AND close < prior stop line.
Exit: Short, Trend is bullish AND prior trend was bearish OR close < take-profit level OR same-bar entry and exit is enabled AND stop-loss is enabled AND prior trend was bearish AND close > prior stop line.