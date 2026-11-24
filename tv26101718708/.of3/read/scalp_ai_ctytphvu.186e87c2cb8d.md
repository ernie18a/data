Long: close > EMA(close, fast EMA lookback)
Short: close < EMA(close, fast EMA lookback)
Long: close > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, long EMA lookback)
Short: close < EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) < EMA(close, long EMA lookback)
Long: RSI(close, RSI lookback) > long RSI threshold
Short: RSI(close, RSI lookback) < short RSI threshold
Long: close > VWAP(close)
Short: close <= VWAP(close)
Long: For each of T1, T2, T3, T4, T5, and T6, close > EMA(close, medium EMA lookback) AND close > EMA(close, long EMA lookback), calculated on the still-forming Tn bar and mapped to chart bars
Short: For each of T1, T2, T3, T4, T5, and T6, NOT(close > EMA(close, medium EMA lookback) AND close > EMA(close, long EMA lookback)), calculated on the still-forming Tn bar and mapped to chart bars
Long: pivotlow(low, swing length, swing length) is not na
Short: pivothigh(high, swing length, swing length) is not na
Calculation: SwingQuality(price, support) = max((min(low[pivot span - 1], low[pivot span + 1]) - price) / normalization parameter, 0); SwingQuality(price, resistance) = max((price - max(high[pivot span - 1], high[pivot span + 1])) / normalization parameter, 0)
Long: pivotlow(low, pivot span, pivot span) is not na AND SwingQuality(pivot low price, support) >= minimum swing quality
Short: pivothigh(high, pivot span, pivot span) is not na AND SwingQuality(pivot high price, resistance) >= minimum swing quality