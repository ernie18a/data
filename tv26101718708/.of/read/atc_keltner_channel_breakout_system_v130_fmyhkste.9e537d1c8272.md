Calculation: HMA basis = Hull moving average of close over a lookback
Calculation: ATR = average true range over a lookback
Calculation: Upper Keltner band = HMA basis + ATR × multiplier
Calculation: Lower Keltner band = HMA basis − ATR × multiplier
Calculation: Volume Z-score = (current volume − trailing volume mean) / trailing volume standard deviation
Long: close > upper Keltner band AND previous bar close ≤ previous bar upper Keltner band AND (volume gate is disabled OR volume Z-score ≥ threshold)
Short: close < lower Keltner band AND previous bar close ≥ previous bar lower Keltner band AND (volume gate is disabled OR volume Z-score ≥ threshold)