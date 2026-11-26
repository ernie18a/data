Calculation: T1-period running body high = highest max(open, close) over chart bars from the start of the current, still-forming T1 period through the current chart bar
Calculation: T1-period running body low = lowest min(open, close) over chart bars from the start of the current, still-forming T1 period through the current chart bar
Calculation: Bull zone = T1-period running body low[1] exists AND low <= T1-period running body low[1]
Calculation: Bear zone = T1-period running body high[1] exists AND high >= T1-period running body high[1]
Long: Turtle Soup model enabled AND current chart bar is not the first in a T1 period AND elapsed chart bars from the current T1 period start >= round(time-window fraction × chart-bar count of the previous completed T1 period) AND low < T1-period running body low[1] AND min(open, close) >= T1-period running body low[1]
Short: Turtle Soup model enabled AND current chart bar is not the first in a T1 period AND elapsed chart bars from the current T1 period start >= round(time-window fraction × chart-bar count of the previous completed T1 period) AND high > T1-period running body high[1] AND max(open, close) <= T1-period running body high[1]
Long: rejection blocks enabled AND Pivot Low(low, pivot lookback, pivot lookback) is not na AND min(open, close) - low > wick-to-range fraction × (high - low)
Short: rejection blocks enabled AND Pivot High(high, pivot lookback, pivot lookback) is not na AND high - max(open, close) > wick-to-range fraction × (high - low)
Long: candle structure enabled AND close[2] < open[2] AND Bull zone[2] AND low[1] < low[2] AND close[1] > low[2] AND close > open AND close > high[1]
Short: candle structure enabled AND close[2] > open[2] AND Bear zone[2] AND high[1] > high[2] AND close[1] < high[2] AND close < open AND close < low[1]
Short: candle structure enabled AND close[1] < open[1] AND Bull zone[1] AND close < low[1]
Long: candle structure enabled AND close[1] > open[1] AND Bear zone[1] AND close > high[1]
Long: candle structure enabled AND close[1] < open[1] AND Bull zone[1] AND low >= low[1] AND close > open AND close > high[1]
Short: candle structure enabled AND close[1] > open[1] AND Bear zone[1] AND high <= high[1] AND close < open AND close < low[1]