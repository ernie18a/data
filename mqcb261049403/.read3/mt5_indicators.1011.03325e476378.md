Calculation: MACD = moving average(close, shorter lookback, histogram smoothing method, histogram smoothing parameter) - moving average(close, longer lookback, histogram smoothing method, histogram smoothing parameter)
Calculation: Signal = smooth(MACD, signal lookback, signal smoothing method, signal smoothing parameter)
Long: MACD > 0 AND MACD != MACD[1]
Short: MACD < 0 AND MACD != MACD[1]
Long: MACD > Signal[1]
Short: MACD < Signal[1]
Long: on chart bars, MACD(T1, forming bar) > 0 AND MACD(T1, forming bar) != MACD(T1, preceding bar)
Short: on chart bars, MACD(T1, forming bar) < 0 AND MACD(T1, forming bar) != MACD(T1, preceding bar)
Long: on chart bars, MACD(T1, forming bar) > Signal(T1, forming bar)
Short: on chart bars, MACD(T1, forming bar) < Signal(T1, forming bar)