Calculation: prior down-candle low = low of the most recent chart bar before the current bar with close < open
Calculation: prior up-candle high = high of the most recent chart bar before the current bar with close > open
Long: low < lowest(low[1], swing lookback) AND close > lowest(low[1], swing lookback)
Short: high > highest(high[1], swing lookback) AND close < highest(high[1], swing lookback)
Long: On chart bars, low < low(T1, last completed bar) AND close > low(T1, last completed bar)
Short: On chart bars, high > high(T1, last completed bar) AND close < high(T1, last completed bar)
Long: close > low[2] from any prior bearish FVG (high < low[2] on its formation bar) that remains uninverted and within the FVG retention lookback
Short: close < high[2] from any prior bullish FVG (low > high[2] on its formation bar) that remains uninverted and within the FVG retention lookback
Long: close > prior down-candle low AND close[1] <= prior down-candle low
Short: close < prior up-candle high AND close[1] >= prior up-candle high