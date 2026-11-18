Calculation: Green cloud = EMA(close, shorter lookback, T1, still-forming bar) > EMA(close, longer lookback, T1, still-forming bar) AND (chart close < EMA(close, longer lookback, T1, still-forming bar) OR chart close > EMA(close, shorter lookback, T1, still-forming bar)); sampled on chart bars
Calculation: Red cloud = EMA(close, shorter lookback, T1, still-forming bar) < EMA(close, longer lookback, T1, still-forming bar) AND (chart close < EMA(close, shorter lookback, T1, still-forming bar) OR chart close > EMA(close, longer lookback, T1, still-forming bar)); sampled on chart bars
Long: Green cloud
Short: Red cloud
Long: chart close > EMA(close, bias lookback, longer than both cloud lookbacks, T1, still-forming bar) AND Green cloud AND NOT Green cloud[1]
Short: chart close < EMA(close, bias lookback, longer than both cloud lookbacks, T1, still-forming bar) AND Red cloud AND NOT Red cloud[1]