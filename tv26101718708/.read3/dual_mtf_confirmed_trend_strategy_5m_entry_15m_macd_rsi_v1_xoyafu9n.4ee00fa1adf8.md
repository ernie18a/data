Calculation: Supertrend = Supertrend(high, low, close, ATR lookback, multiplier)
Calculation: Gann HiLo line = Gann HiLo Activator(high, low, close, high lookback, low lookback)
Calculation: shorter EMA = EMA(close, shorter lookback)
Calculation: longer EMA = EMA(close, longer lookback)
Calculation: MACD histogram = MACD histogram(close, fast lookback, slow lookback, signal lookback) on T1 bars, using the still-forming T1 value on chart bars
Calculation: RSI = RSI(close, lookback) on T1 bars, using the still-forming T1 value on chart bars
Long: close > Supertrend AND close > Gann HiLo line AND close > shorter EMA AND close > longer EMA AND MACD histogram > 0 AND RSI > RSI threshold
Short: close < Supertrend AND close < Gann HiLo line AND close < shorter EMA AND close < longer EMA AND MACD histogram < 0 AND RSI < RSI threshold