Calculation: buyVol = volume * (close - low) / (high - low), or 0.5 * volume when high equals low
Calculation: sellVol = volume * (high - close) / (high - low), or 0.5 * volume when high equals low
Calculation: buyVolSm = EMA of buyVol over a short smoothing lookback; sellVolSm = EMA of sellVol over the same lookback
Calculation: imbalance = (buyVolSm - sellVolSm) / (buyVolSm + sellVolSm) * 100, or 0 when the denominator is 0
Long: imbalance > a small positive threshold
Short: imbalance < the negative of the same threshold