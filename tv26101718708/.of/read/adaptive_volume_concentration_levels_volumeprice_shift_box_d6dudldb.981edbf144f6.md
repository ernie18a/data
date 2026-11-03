Calculation: Shift score = sensitivity × (bullish score − bearish score), where bullish score sums the respective weights for session VWAP of close > previous session VWAP, OBV > its moving average, accumulation/distribution line > its moving average, volume > its moving average AND close > open, and close > close at the lookback AND close > session VWAP; bearish score sums the respective weights for session VWAP <= previous session VWAP, OBV <= its moving average, accumulation/distribution line <= its moving average, volume > its moving average AND close < open, and close <= close at the lookback AND close < session VWAP. Use the same lookback for the moving averages and close comparison, with either EMA or SMA for all moving averages.
Long: Shift score > neutral threshold
Short: Shift score < −neutral threshold
Long: Volume > its moving average AND close > open
Short: Volume > its moving average AND close <= open
Long: Session VWAP of close > previous session VWAP
Short: Session VWAP of close <= previous session VWAP
Long: OBV > its moving average
Short: OBV <= its moving average
Long: OBV > previous OBV
Short: OBV <= previous OBV