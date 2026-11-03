Calculation: Bullish score = sum of component weights for: VWAP rising versus prior bar; OBV above its moving average; A/D line above its moving average; volume above its moving average AND close > open; close change over the lookback > 0 AND close > VWAP
Calculation: Bearish score = sum of component weights for: VWAP not rising versus prior bar; OBV not above its moving average; A/D line not above its moving average; volume above its moving average AND close < open; close change over the lookback <= 0 AND close < VWAP
Calculation: Shift score = (bullish score - bearish score) × sensitivity
Long: Shift score > neutral threshold
Short: Shift score < -neutral threshold