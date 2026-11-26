Calculation: direction(T) = 1 when MA(close, shorter lookback, T, still-forming bar sampled on chart bars) > MA(close, longer lookback, T, still-forming bar sampled on chart bars), -1 when <, or 0 when equal
Calculation: score = direction(T1) + direction(T2) + direction(T3)
Long: direction(T1) > 0 OR direction(T2) > 0 OR direction(T3) > 0
Short: direction(T1) < 0 OR direction(T2) < 0 OR direction(T3) < 0
Long: score >= 2
Short: score <= -2