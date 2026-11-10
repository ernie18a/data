Calculation: Order flow = cumulative sum of volume × (close - low) / (high - low) - volume × (high - close) / (high - low).
Calculation: Normalized order flow = (order flow - SMA of order flow) / standard deviation of (order flow - SMA of order flow), using the same lookback for the SMA and standard deviation.
Calculation: Structure score = sum over adjacent pairs in the latest configured number of confirmed fractal highs and separately in the latest configured number of confirmed fractal lows; add 1 when the older value is greater than the newer value, otherwise subtract 1. A fractal high is a high equal to the highest high in a symmetric window centered on that bar; a fractal low is a low equal to the lowest low in the corresponding window. Confirm each fractal only when the right side of its window has completed; omit pairs with unavailable values.
Long: Normalized order flow > 0.
Short: Normalized order flow <= 0.
Long: Normalized order flow > positive flow threshold.
Short: Normalized order flow < negative flow threshold.
Long: Structure score > positive structure threshold.
Short: Structure score < negative structure threshold.
Long: Close rate of change > 0 AND volume rate of change > positive accumulation threshold, using the same lookback for both rates of change.
Short: Close rate of change < 0 AND volume rate of change > positive accumulation threshold, using the same lookback for both rates of change.