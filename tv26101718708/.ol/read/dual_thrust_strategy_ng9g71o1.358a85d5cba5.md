Calculation: Range = maximum of (highest high over the lookback on the higher timeframe minus lowest close over the same lookback) and (highest close over the same lookback minus lowest low over the same lookback), using the last completed higher-timeframe bar
Calculation: Upper threshold = current daily bar open + long-side multiplier × Range
Calculation: Lower threshold = current daily bar open − short-side multiplier × Range
Long: current close > current upper threshold AND previous close ≤ previous upper threshold
Short: current close < current lower threshold AND previous close ≥ previous lower threshold
Exit: Short, current close > current upper threshold AND previous close ≤ previous upper threshold
Exit: Long, current close < current lower threshold AND previous close ≥ previous lower threshold