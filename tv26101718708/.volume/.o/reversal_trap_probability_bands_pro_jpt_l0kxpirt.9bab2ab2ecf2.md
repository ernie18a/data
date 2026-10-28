Calculation: Upper ATR probability band = EMA(close, band lookback) + ATR(ATR lookback) × multiplier
Calculation: Lower ATR probability band = EMA(close, band lookback) − ATR(ATR lookback) × multiplier
Long: RSI < oversold threshold AND (close < Lower ATR probability band OR (volume > SMA(volume, lookback) AND close > open))
Short: RSI > overbought threshold AND (close > Upper ATR probability band OR (volume > SMA(volume, lookback) AND close < open))