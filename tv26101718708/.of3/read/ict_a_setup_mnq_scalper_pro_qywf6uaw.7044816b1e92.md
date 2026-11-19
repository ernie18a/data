Calculation: Bullish MSS = close > latest confirmed PivotHigh(high, left pivot lookback, right pivot lookback)
Calculation: Bearish MSS = close < latest confirmed PivotLow(low, left pivot lookback, right pivot lookback)
Calculation: Bullish liquidity sweep = low < Lowest(low[1], sweep lookback) AND close > open
Calculation: Bearish liquidity sweep = high > Highest(high[1], sweep lookback) AND close < open
Calculation: Bullish FVG = low > high[gap lookback]
Calculation: Bearish FVG = high < low[gap lookback]
Long: Bullish MSS
Short: Bearish MSS
Long: Bullish liquidity sweep
Short: Bearish liquidity sweep
Long: Bullish FVG
Short: Bearish FVG
Long: close[1] < open[1] AND close > high[1]
Short: close[1] > open[1] AND close < low[1]
Long: Bullish MSS AND Bullish liquidity sweep AND Bullish FVG
Short: Bearish MSS AND Bearish liquidity sweep AND Bearish FVG