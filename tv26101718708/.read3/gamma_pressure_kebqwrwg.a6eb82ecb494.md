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
Calculation: Decayed signed volume flow = prior decayed signed volume flow × P6 + traded-instrument volume × sign(traded-instrument close − traded-instrument open), initialized at zero
Calculation: Composite pressure = P24 × EMA(weighted mean of: P16 × momentum, P17 × volatility-index pressure, P18 × volume-flow pressure, P19 × trend pressure, P20 × dollar pressure, and P21 × body strength, using P16–P21 as weights; use zero if their sum is zero, smoothed over P22 bars), where momentum is clip((traded-instrument close − its value P1 bars ago) ÷ (ATR of traded-instrument high, low, and close over P3 bars × P2), −P23, P23) if ATR > 0, otherwise zero; volatility-index pressure is clip(−(symbol-matched implied-volatility index close − its value P4 bars ago) ÷ P5, −P23, P23); volume-flow pressure is clip(decayed signed volume flow ÷ (SMA of traded-instrument volume over P7 bars × P8), −P23, P23) if that SMA > 0, otherwise zero; trend pressure is the mean of the fast and slow terms, each term being clip(the P11-bar change in the corresponding traded-instrument closing-price EMA, over P9 or P10 bars, divided by P11 and by (ATR over P3 bars × P12), −P23, P23) if ATR > 0, otherwise zero; dollar pressure is clip(−(US Dollar Index close − its value P13 bars ago) ÷ P14, −P23, P23); body strength is clip((traded-instrument close − open) ÷ (high − low) × min(volume ÷ SMA(volume, P7), P15), −P23, P23), using zero for the body ratio if high ≤ low and one for the relative-volume factor if SMA(volume, P7) ≤ 0
Long: Composite pressure crosses above zero
Short: Composite pressure crosses below zero
Long: Composite pressure crosses above P25
Short: Composite pressure crosses below −P25
Long: Composite pressure > P26
Short: Composite pressure < −P26