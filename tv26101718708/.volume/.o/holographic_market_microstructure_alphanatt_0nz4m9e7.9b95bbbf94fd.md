Calculation: Normalized order-flow imbalance = (cumulative sum of [volume × (close − low) / (high − low) − volume × (high − close) / (high − low)] − its simple moving average) / the standard deviation of the difference between that cumulative sum and its simple moving average; use the same lookback for the average and standard deviation.
Calculation: Structure score = for each adjacent pair in the most recent structure-depth confirmed fractal highs and lows, add 1 if the earlier stored pivot price is greater than the next stored pivot price, otherwise subtract 1; a fractal pivot is a high equal to the highest high, or a low equal to the lowest low, across a window centered on the pivot, and is usable only once the window is complete.
Long: Normalized order-flow imbalance > 1
Short: Normalized order-flow imbalance < -1
Long: Structure score > 2
Short: Structure score < -2
Long: Close rate of change over the smart-money lookback > 0 AND volume rate of change over the same lookback > the accumulation threshold
Short: Close rate of change over the smart-money lookback < 0 AND volume rate of change over the same lookback > the accumulation threshold