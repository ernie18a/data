Calculation: Adaptive lookback = rounded, EMA-smoothed Ehlers Homodyne cycle period of (high + low) / 2, clamped to minimum and maximum lookbacks
Calculation: Bollinger Bands = SMA(close, adaptive lookback) ± a multiplier × standard deviation(close, adaptive lookback)
Calculation: Keltner Channels = SMA(close, adaptive lookback) ± a multiplier × SMA(true range, adaptive lookback)
Calculation: Squeeze = percentile rank of Bollinger width / Keltner width over a longer lookback is at or below the light-compression threshold
Calculation: Momentum = linear regression with zero offset of close minus the average of the adaptive-lookback Donchian midpoint and adaptive-lookback SMA(close)
Calculation: Squeeze duration = consecutive chart-timeframe bars with Squeeze true
Long: previous completed chart-timeframe bar was in a Squeeze AND current bar is not in a Squeeze AND Momentum > 0 AND close > open AND absolute Momentum ≥ threshold AND previous Squeeze duration ≥ minimum duration AND close > the highest high of the squeeze bars
Short: previous completed chart-timeframe bar was in a Squeeze AND current bar is not in a Squeeze AND Momentum < 0 AND close < open AND absolute Momentum ≥ threshold AND previous Squeeze duration ≥ minimum duration AND close < the lowest low of the squeeze bars