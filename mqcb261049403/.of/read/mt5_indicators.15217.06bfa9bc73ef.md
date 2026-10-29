Calculation: X2MA = apply a configurable moving average to the selected bar price, then apply a second configurable moving average to that result.
Calculation: X2MA change = current X2MA minus previous X2MA.
Calculation: Change standard deviation = population standard deviation of the current and preceding lookback X2MA changes.
Long: On the chart timeframe, current X2MA change > threshold multiplier × change standard deviation OR on a higher timeframe, current still-forming bar's X2MA change > threshold multiplier × change standard deviation.
Short: On the chart timeframe, current X2MA change < −threshold multiplier × change standard deviation OR on a higher timeframe, current still-forming bar's X2MA change < −threshold multiplier × change standard deviation.