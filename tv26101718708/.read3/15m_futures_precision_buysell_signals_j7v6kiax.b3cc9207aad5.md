Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: Higher-timeframe EMA = EMA(close, higher-timeframe lookback) on T1 bars, mapped to chart bars using lookahead off (most recently available completed T1 bar historically; still-forming T1 bar in realtime)
Calculation: RSI = RSI(close, lookback)
Calculation: MACD line, MACD signal line, MACD histogram = MACD(close, fast lookback, slow lookback, signal lookback)
Calculation: ATR percentage = ATR(lookback) / close * 100
Long: chart bar is confirmed AND session filter is disabled OR chart-bar time is within the configured session AND ATR percentage >= volatility threshold AND Fast EMA > Slow EMA AND close > Higher-timeframe EMA AND RSI > long RSI threshold AND MACD line > MACD signal line AND MACD histogram > MACD histogram[1] AND close crosses above Fast EMA
Short: chart bar is confirmed AND session filter is disabled OR chart-bar time is within the configured session AND ATR percentage >= volatility threshold AND Fast EMA < Slow EMA AND close < Higher-timeframe EMA AND RSI < short RSI threshold AND MACD line < MACD signal line AND MACD histogram < MACD histogram[1] AND close crosses below Fast EMA