Calculation: Open range high = highest open on chart bars since the selected session start, through the current chart bar
Calculation: Open range low = lowest open on chart bars since the selected session start, through the current chart bar
Calculation: Spread anomaly = high - low > SMA(high - low, lookback) × multiplier
Calculation: Volume pressure = sum(volume of T1 bars within each chart bar where close > open) - sum(volume of T1 bars within each chart bar where close < open), calculated on chart bars from available T1 bars, including any T1 bar still forming
Long: Spread anomaly AND low < open range low AND close >= open range low AND volume pressure > 0
Short: Spread anomaly AND high > open range high AND close <= open range high AND volume pressure < 0
Long: Spread anomaly AND close > open AND volume pressure > 0 AND NOT (low < open range low AND close >= open range low)
Short: Spread anomaly AND close < open AND volume pressure < 0 AND NOT (high > open range high AND close <= open range high)
Long: NOT Spread anomaly AND close > open range high AND volume pressure > 0
Short: NOT Spread anomaly AND close < open range low AND volume pressure < 0