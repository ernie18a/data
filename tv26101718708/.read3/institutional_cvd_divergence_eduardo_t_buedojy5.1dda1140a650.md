Calculation: CVD = cumulative sum of (volume when close > open, -volume when close < open, 0 when close = open)
Short: high > Highest(high[1], lookback) AND CVD < Highest(CVD[1], lookback)
Long: low < Lowest(low[1], lookback) AND CVD > Lowest(CVD[1], lookback)