Calculation: Middle Bollinger band = Bollinger Bands middle line(close, lookback)
Calculation: Shorter EMA = EMA(close, shorter lookback)
Calculation: Longer EMA = EMA(close, longer lookback)
Calculation: Parabolic SAR = Parabolic SAR(high, low, acceleration, maximum)
Calculation: Stochastic main line = Stochastic main line(high, low, %K lookback, %D lookback, slowing, EMA smoothing)
Calculation: Stochastic signal line = Stochastic signal line(high, low, %K lookback, %D lookback, slowing, EMA smoothing)
Calculation: MACD main line = MACD main line(close, shorter lookback, longer lookback)
Calculation: RSI = RSI(close, lookback)
Long: close > Middle Bollinger band AND close > Shorter EMA AND close > Longer EMA AND close > Parabolic SAR AND Stochastic main line > Stochastic signal line AND MACD main line > 0 AND RSI > threshold
Short: close < Middle Bollinger band AND close < Shorter EMA AND close < Longer EMA AND close < Parabolic SAR AND Stochastic main line < Stochastic signal line AND MACD main line < 0 AND RSI < threshold