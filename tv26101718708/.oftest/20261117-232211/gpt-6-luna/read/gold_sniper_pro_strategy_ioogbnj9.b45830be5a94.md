Calculation: RSI = RSI(close, RSI lookback)
Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: ATR = ATR(ATR lookback)
Calculation: ATR valid = ATR >= SMA(ATR, ATR lookback) * ATR multiplier
Calculation: Volume valid = volume filter disabled OR volume > SMA(volume, volume lookback) * volume threshold
Long: (RSI crosses above RSI oversold AND close > Fast EMA AND ATR valid AND Volume valid) OR (RSI < RSI 40 threshold AND close > Fast EMA AND close crosses above Fast EMA AND ATR valid) OR (Fast EMA crosses above Slow EMA AND RSI < RSI 60 threshold AND ATR valid)
Short: (RSI crosses below RSI overbought AND close < Fast EMA AND ATR valid AND Volume valid) OR (RSI > RSI 60 threshold AND close < Fast EMA AND close crosses below Fast EMA AND ATR valid) OR (Fast EMA crosses below Slow EMA AND RSI > RSI 40 threshold AND ATR valid)