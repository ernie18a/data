Calculation: Trend = For each bar, let upper be the highest high over a lookback including the current bar, and lower be the minimum of the current close and the lowest low over the same lookback. Let the lower threshold be lower + (upper - lower) × a risk parameter, and the upper threshold be upper - (upper - lower) × the same risk parameter. Initialize trend to 0. Set trend to -1 if close < lower threshold; then set it to +1 if close > upper threshold; otherwise retain the preceding value.
Calculation: Higher-timeframe trend = Trend calculated on the higher timeframe using its still-forming bar at the open of each higher-timeframe bar, held constant until the next higher-timeframe bar opens.
Long: Trend > 0
Short: Trend < 0
Long: Higher-timeframe trend > 0
Short: Higher-timeframe trend <= 0