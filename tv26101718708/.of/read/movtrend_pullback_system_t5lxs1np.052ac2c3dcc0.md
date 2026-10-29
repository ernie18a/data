Calculation: MovTrend = linear regression of close over a lookback, evaluated at the current bar
Calculation: Slope = current MovTrend minus MovTrend from a shorter lookback ago
Calculation: ATR bands = MovTrend plus or minus a multiple of ATR
Long: Slope > 0 AND low <= MovTrend AND close > MovTrend
Short: Slope < 0 AND high >= MovTrend AND close < MovTrend
Exit: long, close > upper ATR band AND NOT (Slope > 0 AND low <= MovTrend AND close > MovTrend) AND NOT (Slope < 0 AND high >= MovTrend AND close < MovTrend)
Exit: short, close < lower ATR band AND NOT (Slope > 0 AND low <= MovTrend AND close > MovTrend) AND NOT (Slope < 0 AND high >= MovTrend AND close < MovTrend)