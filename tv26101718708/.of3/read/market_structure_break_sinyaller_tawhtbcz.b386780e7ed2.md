Long: close crosses above high[lookback]
Short: close crosses below low[lookback]
Long: close > EMA(close, long-term lookback) AND RSI(close, lookback) > threshold AND OBV > EMA(OBV, lookback) AND close crosses above EMA(close, shorter lookback)
Short: close < EMA(close, long-term lookback) AND RSI(close, lookback) < threshold AND OBV < EMA(OBV, lookback) AND close crosses below EMA(close, shorter lookback)