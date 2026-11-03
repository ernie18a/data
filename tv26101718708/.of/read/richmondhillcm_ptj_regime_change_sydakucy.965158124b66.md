Calculation: Moving averages = either SMA or EMA of close, using the same type for a long-term and a short-term average.
Calculation: ATR ratio = ATR divided by the SMA of ATR; use zero when the SMA is zero.
Calculation: Regime score = sum of seven votes: (1) +1 if close > long-term moving average, otherwise -1; (2) +1 if close > short-term moving average, otherwise -1; (3) +1 if both moving averages > their respective values a specified number of bars ago, otherwise -1; (4) +1 if RSI >= its lower threshold AND RSI < its upper threshold, otherwise -1; (5) +1 if MACD histogram > 0 AND > its previous value, -1 if MACD histogram < 0 AND < its previous value, otherwise 0; (6) +1 if volume > SMA of volume AND close > previous close, -1 if volume > SMA of volume AND close < previous close, otherwise 0; (7) +1 if ATR ratio < its lower threshold, otherwise -1 if ATR ratio > its upper threshold, otherwise 0.
Long: Regime score >= bullish threshold.
Short: Regime score <= bearish threshold.
Long: Close > long-term moving average OR close > short-term moving average.
Short: Close <= long-term moving average OR close <= short-term moving average.
Long: Long-term moving average > its value a specified number of bars ago AND short-term moving average > its value the same number of bars ago.
Short: Long-term moving average <= its value a specified number of bars ago OR short-term moving average <= its value the same number of bars ago.
Long: RSI >= lower threshold AND RSI < upper threshold.
Short: RSI < lower threshold OR RSI >= upper threshold.
Long: MACD histogram > 0 AND MACD histogram > previous MACD histogram.
Short: MACD histogram < 0 AND MACD histogram < previous MACD histogram.
Long: Volume > SMA of volume AND close > previous close.
Short: Volume > SMA of volume AND close < previous close.
Long: ATR ratio < lower threshold.
Short: ATR ratio >= lower threshold AND ATR ratio > upper threshold.
Long: Close > long-term moving average AND previous close <= previous long-term moving average.
Short: Close < long-term moving average AND previous close >= previous long-term moving average.