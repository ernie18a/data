Calculation: Midline = average of the enabled moving averages
Calculation: Smoothed ribbon width = EMA of the maximum, across enabled moving averages, of 2 × the absolute difference between each moving average and its configured source
Calculation: Volume boost = 1 + max(0, current volume / SMA(volume) − 1) × volume sensitivity
Calculation: Upper/lower wick factor = 1 + asymmetry strength × RMA(upper/lower candle wick, 14) / ATR(14)
Calculation: Core upper/lower = EMA(midline ± smoothed ribbon width × 0.5 × core multiplier × volume boost × corresponding wick factor, edge smoothing length)
Calculation: Expansion envelope upper/lower = EMA(core upper/lower ± smoothed ribbon width × 0.5 × envelope multiplier × volume boost × corresponding wick factor, edge smoothing length)
Long: close > expansion envelope upper AND previous close ≤ previous expansion envelope upper
Short: close < expansion envelope lower AND previous close ≥ previous expansion envelope lower