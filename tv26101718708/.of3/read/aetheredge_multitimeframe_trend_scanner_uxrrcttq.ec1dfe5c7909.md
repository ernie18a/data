Calculation: rawTrend(T) = (close(T) > EMA(close, bias lookback, T) ? 1 : -1) + (EMA(close, shorter lookback, T) > EMA(close, longer lookback, T) ? 1 : -1); calculated on T bars using the current bar (still forming in real time, last completed historically), with values taken on chart bars
Calculation: trendScore(T) = ADX(high, low, close, ADX lookback, T) < ADX trend threshold ? round(rawTrend(T) / 2) : rawTrend(T); calculated on T bars using the current bar (still forming in real time, last completed historically), with values taken on chart bars
Calculation: consensus = (trendScore(T1) + trendScore(T2) + trendScore(T3) + trendScore(T4)) / 8; calculated on chart bars from the current T1, T2, T3, and T4 values
Long: trendScore(T1) > 0 OR trendScore(T2) > 0 OR trendScore(T3) > 0 OR trendScore(T4) > 0 OR consensus >= weak consensus threshold
Short: trendScore(T1) < 0 OR trendScore(T2) < 0 OR trendScore(T3) < 0 OR trendScore(T4) < 0 OR consensus <= -weak consensus threshold
Long: consensus >= strong consensus threshold
Short: consensus <= -strong consensus threshold
Long: consensus[1] <= 0 AND consensus > weak consensus threshold
Short: consensus[1] >= 0 AND consensus < -weak consensus threshold
Long: trendScore(T1) = 2 AND trendScore(T2) = 2 AND trendScore(T3) = 2 AND trendScore(T4) = 2
Short: trendScore(T1) = -2 AND trendScore(T2) = -2 AND trendScore(T3) = -2 AND trendScore(T4) = -2