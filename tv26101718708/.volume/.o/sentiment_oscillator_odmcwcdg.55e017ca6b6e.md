Calculation: Market Sentiment = EMA(close − previous close, lookback) / EMA(volume, same lookback), or EMA((close − previous close) / volume, same lookback), according to the selected calculation method
Calculation: Fast EMA = EMA(Market Sentiment, shorter lookback)
Calculation: Slow EMA = EMA(Market Sentiment, longer lookback)
Calculation: MACD = Fast EMA − Slow EMA
Calculation: Signal Line = EMA(MACD, lookback)
Calculation: Histogram = MACD − Signal Line
Long: The configured entry series (Market Sentiment, Fast EMA, Slow EMA, MACD, Signal Line, or Histogram) crosses the configured comparison series (one of those series or zero) in the configured direction (above or below)
Long: MACD crosses above Signal Line
Short: MACD crosses below Signal Line
Exit: Long, the configured exit series (Market Sentiment, Fast EMA, Slow EMA, MACD, Signal Line, or Histogram) crosses the configured comparison series (one of those series or zero) in the configured direction (above or below)