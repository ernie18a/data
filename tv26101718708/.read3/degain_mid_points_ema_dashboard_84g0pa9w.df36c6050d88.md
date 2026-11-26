Calculation: 200-bar midpoint = (highest(high, 200 bars, T1, last completed bar) + lowest(low, 200 bars, T1, last completed bar)) / 2
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND EMA(close, shorter lookback) is within a proximity parameter of the 200-bar midpoint
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND EMA(close, shorter lookback) is within a proximity parameter of the 200-bar midpoint
Long: low is at or below the 200-bar midpoint AND close is above the 200-bar midpoint
Short: high is at or above the 200-bar midpoint AND close is below the 200-bar midpoint