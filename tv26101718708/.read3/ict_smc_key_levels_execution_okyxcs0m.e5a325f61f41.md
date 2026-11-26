Long: low > high[2]
Short: high < low[2]
Long: PivotLow(low, order-block lookback, order-block lookback) is confirmed
Short: PivotHigh(high, order-block lookback, order-block lookback) is confirmed
Calculation: tracked sweep high = latest confirmed PivotHigh(high, sweep lookback, sweep lookback), replaced by each newer confirmed pivot and cleared after a bearish sweep
Calculation: tracked sweep low = latest confirmed PivotLow(low, sweep lookback, sweep lookback), replaced by each newer confirmed pivot and cleared after a bullish sweep
Long: tracked sweep low exists AND low < tracked sweep low AND close > tracked sweep low
Short: tracked sweep high exists AND high > tracked sweep high AND close < tracked sweep high
Calculation: tracked MSS high = latest confirmed PivotHigh(high, MSS lookback, MSS lookback), replaced by each newer confirmed pivot and cleared after close > its value
Calculation: tracked MSS low = latest confirmed PivotLow(low, MSS lookback, MSS lookback), replaced by each newer confirmed pivot and cleared after close < its value
Long: tracked MSS high exists AND close > tracked MSS high
Short: tracked MSS low exists AND close < tracked MSS low