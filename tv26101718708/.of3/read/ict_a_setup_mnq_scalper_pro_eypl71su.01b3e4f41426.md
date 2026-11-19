Long: close > the most recent confirmed PivotHigh(high, left lookback, right lookback)
Short: close < the most recent confirmed PivotLow(low, left lookback, right lookback)
Long: low < Lowest(low[1], lookback) AND close > open
Short: high > Highest(high[1], lookback) AND close < open
Long: low > high[2]
Short: high < low[2]
Long: close[1] < open[1] AND close > high[1]
Short: close[1] > open[1] AND close < low[1]
Long: close > the most recent confirmed PivotHigh(high, left lookback, right lookback) AND low < Lowest(low[1], lookback) AND close > open AND low > high[2]
Short: close < the most recent confirmed PivotLow(low, left lookback, right lookback) AND high > Highest(high[1], lookback) AND close < open AND high < low[2]