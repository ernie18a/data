Calculation: Relative-volume Z-score = (current volume − moving average volume) / standard deviation of volume over the same lookback
Calculation: Bullish trend structure = close > shorter-lookback SMA of close > longer-lookback SMA of close
Calculation: Bearish trend structure = close < shorter-lookback SMA of close < longer-lookback SMA of close
Calculation: Adaptive moving average = Kaufman Adaptive Moving Average of close, using a local efficiency ratio
Calculation: Directional score = weighted sum of trend structure, higher-timeframe alignment, relative-volume thresholds, true-range/ATR gate, adaptive moving-average alignment, wick-adjusted bias, and candle direction
Calculation: Bullish divergence = a confirmed price pivot low is lower than the preceding confirmed pivot low while RSI at the pivot is higher
Calculation: Bearish divergence = a confirmed price pivot high is higher than the preceding confirmed pivot high while RSI at the pivot is lower
Long: bullish trend structure AND close > adaptive moving average AND (higher-timeframe filter disabled OR close of last completed higher-timeframe bar > shorter-lookback SMA of that bar series) AND true range >= ATR × volatility threshold AND relative-volume Z-score >= signal threshold AND bullish wick-adjusted bias AND long score > short score AND max(long score, short score) >= trigger floor AND no signal within cooldown lookback AND bar is confirmed
Long: bullish divergence on the pivot confirmation bar
Long: RSI < oversold threshold AND prior MACD histogram < 0 AND current MACD histogram > prior MACD histogram AND bar is confirmed
Short: bearish trend structure AND close < adaptive moving average AND (higher-timeframe filter disabled OR close of last completed higher-timeframe bar < shorter-lookback SMA of that bar series) AND true range >= ATR × volatility threshold AND relative-volume Z-score >= signal threshold AND bearish wick-adjusted bias AND short score > long score AND max(long score, short score) >= trigger floor AND no signal within cooldown lookback AND bar is confirmed
Short: bearish divergence on the pivot confirmation bar
Short: RSI > overbought threshold AND prior MACD histogram > 0 AND current MACD histogram < prior MACD histogram AND bar is confirmed