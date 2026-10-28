Calculation: score = (close > short-lookback EMA ? 1 : -1) + (close > long-lookback EMA ? 1 : -1) + (RSI > 70 ? -2 : RSI < 50 ? 1 : -1) + (volume > volume moving average ? 1 : -1)
Calculation: trend = 1 when score >= 2; -1 when score <= -2; otherwise the previous trend
Long: trend = 1 AND previous trend != 1
Exit: long, trend = -1 AND previous trend != -1