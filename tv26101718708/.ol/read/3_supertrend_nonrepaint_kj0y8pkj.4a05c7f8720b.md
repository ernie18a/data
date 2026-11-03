Calculation: Fast/mid Supertrend directions = Supertrend directions using a shorter ATR lookback and smaller multiplier for fast than for mid
Calculation: ATR-normalized EMA distance = abs(close − EMA(close, shorter lookback)) / ATR(longer lookback)
Long: Fast Supertrend direction < 0 AND mid Supertrend direction < 0
Long: Fast Supertrend direction < 0 AND mid Supertrend direction < 0 AND previous bar did not have both directions < 0 AND ATR-normalized EMA distance > trend threshold AND bar is confirmed
Long: Bar is confirmed AND low > high two bars ago
Short: Fast Supertrend direction > 0 AND mid Supertrend direction > 0
Short: Fast Supertrend direction > 0 AND mid Supertrend direction > 0 AND previous bar did not have both directions > 0 AND ATR-normalized EMA distance > trend threshold AND bar is confirmed
Short: Bar is confirmed AND high < low two bars ago