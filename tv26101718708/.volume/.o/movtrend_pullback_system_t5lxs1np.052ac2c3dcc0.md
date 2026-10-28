Calculation: MovTrend = linear regression of close over a lookback of current-timeframe bars, including the current bar
Calculation: Slope = current MovTrend − MovTrend from a shorter lookback ago
Calculation: Upper ATR band = MovTrend + ATR × multiplier; lower ATR band = MovTrend − ATR × multiplier, where ATR is average true range of current-timeframe bars
Long: Slope > 0 AND low ≤ MovTrend AND close > MovTrend
Short: Slope < 0 AND high ≥ MovTrend AND close < MovTrend
Exit: long, close > upper ATR band
Exit: short, close < lower ATR band