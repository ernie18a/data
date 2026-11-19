Calculation: Decayed Session Volume Flow = reset to 0 at each session start; otherwise previous flow * volume-flow decay + (volume if close > open, -volume if close < open, 0 otherwise)
Calculation: Momentum Component = ATR(ATR lookback) > 0 ? clamp((close - close[momentum lookback]) / (ATR(ATR lookback) * momentum scale), -1, 1) : 0
Calculation: Volatility Component = clamp(-(chart-bar volatility-index close - chart-bar volatility-index close[volatility lookback]) / volatility scale, -1, 1)
Calculation: Volume Flow Component = SMA(volume, volume-average lookback) > 0 ? clamp(Decayed Session Volume Flow / (SMA(volume, volume-average lookback) * flow normalization scale), -1, 1) : 0
Calculation: Trend Agreement Component = (clamp((EMA(close, shorter trend lookback) - EMA(close, shorter trend lookback)[trend slope lookback]) / (trend slope lookback * ATR(ATR lookback) * trend ATR scale), -1, 1) + clamp((EMA(close, longer trend lookback) - EMA(close, longer trend lookback)[trend slope lookback]) / (trend slope lookback * ATR(ATR lookback) * trend ATR scale), -1, 1)) / 2
Calculation: Dollar Component = clamp(-(chart-bar dollar-index close - chart-bar dollar-index close[dollar lookback]) / dollar scale, -1, 1)
Calculation: Candle Conviction Component = clamp((high > low ? (close - open) / (high - low) : 0) * (SMA(volume, volume-average lookback) > 0 ? min(volume / SMA(volume, volume-average lookback), relative-volume cap) : 1), -1, 1)
Calculation: Gamma Pressure = pressure scale * EMA((momentum weight * Momentum Component + volatility weight * Volatility Component + volume-flow weight * Volume Flow Component + trend weight * Trend Agreement Component + dollar weight * Dollar Component + candle weight * Candle Conviction Component) / (sum of the six weights) when the sum of the six weights is nonzero, otherwise 0, pressure smoothing lookback)
Calculation: Pressure Slope = (Gamma Pressure - Gamma Pressure[pressure-slope lookback]) / pressure-slope lookback
Long: Gamma Pressure >= zero-pressure threshold
Short: Gamma Pressure < zero-pressure threshold
Long: Pressure Slope > 0
Short: Pressure Slope < 0
Long: Gamma Pressure crosses above zero-pressure threshold
Short: Gamma Pressure crosses below zero-pressure threshold
Long: Gamma Pressure crosses above strong-pressure level
Short: Gamma Pressure crosses below negative strong-pressure level
Long: Gamma Pressure > extreme-pressure level
Short: Gamma Pressure < negative extreme-pressure level