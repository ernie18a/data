Calculation: Market sentiment = (EMA(close - close[1], sentiment lookback) / EMA(volume, sentiment lookback)) × scale 1, or EMA(((close - close[1]) / volume) × scale 2, sentiment lookback), selected by a method parameter
Calculation: Fast EMA = EMA(Market sentiment, faster lookback)
Calculation: Slow EMA = EMA(Market sentiment, slower lookback)
Calculation: MACD = Fast EMA - Slow EMA
Calculation: Signal line = EMA(MACD, signal lookback)
Calculation: Histogram = MACD - Signal line
Long: A series selected from Market sentiment, Fast EMA, Slow EMA, MACD, Signal line, or Histogram crosses above or below as selected by a direction parameter a series selected from the same choices or zero
Long: MACD crosses above Signal line
Short: MACD crosses below Signal line
Exit: Long, a series selected from Market sentiment, Fast EMA, Slow EMA, MACD, Signal line, or Histogram crosses above or below as selected by a direction parameter a series selected from the same choices or zero