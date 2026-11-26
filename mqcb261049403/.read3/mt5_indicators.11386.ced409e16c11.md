Calculation: Upward candle score = IF(close < open, ((high - low) + (open - close)) / (2 * ((high - low) / volume)), ((high - low) - ABS(close - open)) / (2 * ((high - low) / volume))
Calculation: Downward candle score = IF(close > open, ((high - low) + (close - open)) / (2 * ((high - low) / volume)), ((high - low) - ABS(close - open)) / (2 * ((high - low) / volume))
Calculation: Smoothed upward score = selected smoothing method(upward candle score, lookback, phase)
Calculation: Smoothed downward score = selected smoothing method(downward candle score, lookback, phase)
Long: Smoothed upward score > smoothed downward score
Short: Smoothed upward score < smoothed downward score
Long: On chart bars, the smoothed upward score calculated on the still-forming T1 bar, sampled at the first chart bar within each T1 interval and held until the next T1 interval, > the correspondingly sampled smoothed downward score
Short: On chart bars, the smoothed upward score calculated on the still-forming T1 bar, sampled at the first chart bar within each T1 interval and held until the next T1 interval, < the correspondingly sampled smoothed downward score