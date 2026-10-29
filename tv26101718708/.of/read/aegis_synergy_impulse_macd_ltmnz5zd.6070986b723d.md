Calculation: MACD line = VWMA(close, shorter lookback) − VWMA(close, longer lookback)
Calculation: MACD signal = EMA(MACD line, signal lookback)
Calculation: Impulse value = close − highest(high, impulse lookback) when close > EMA(close, impulse lookback); close − lowest(low, impulse lookback) when close < that EMA; otherwise 0
Calculation: Impulse MACD = EMA(Impulse value, signal lookback)
Calculation: Impulse signal = SMA(Impulse MACD, signal lookback)
Calculation: Impulse histogram = Impulse MACD − Impulse signal
Calculation: Trend baseline = EMA(close, long-term lookback)
Long: MACD line crosses above MACD signal AND MACD line > MACD signal AND Impulse histogram > 0 AND Impulse MACD > 0 AND close > Trend baseline
Short: MACD line crosses below MACD signal AND MACD line < MACD signal AND Impulse histogram < 0 AND Impulse MACD < 0 AND close < Trend baseline