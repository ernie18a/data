Calculation: B = Bollinger Band %B of close
Calculation: M = negative SMA of B, using a shorter lookback than B
Calculation: K = RMA of (close - lowest low) / (highest high - lowest low); D = RMA of K using the same smoothing length; the high/low lookback matches B's lookback
Calculation: P = percent rank of B divided by its maximum rank
Calculation: Q = nearest-rank percentile of B + M
Calculation: R = (close - highest high) / (highest high - lowest low), using B's lookback
Calculation: F = (average of clamp(K, 0, rank-period) * rank-period / 3, clamp(B, 0, rank-period) * rank-period / 3, and clamp(R, 0, rank-period) * rank-period / 3 - offset) / scale
Calculation: V = volume / highest volume over a lookback; S = SMA of V
Calculation: Y = (M > K AND B < -P AND close < open) OR M > P OR (M > F AND close < open) OR B < lower threshold
Calculation: G = (close >= open AND P > F) OR (K > D AND K < M AND P > F) OR (K > D AND P > K AND P > F)
Long: B crosses above M
Long: F <= lower threshold
Long: V < 1 AND NOT Y AND G
Long: F <= upper threshold AND K < S AND Q < M
Long: F < S AND -P > lower threshold AND P < F AND B < S AND -Q > B AND NOT (B - 1 > -Q OR B - 1 > Q) AND NOT ((F <= upper threshold AND B < F AND K < S AND K < D AND Q < M AND K < -Q) OR (B < M AND F < lower threshold AND Q < M AND K < -Q) OR (M > F AND Q < M AND K < -Q) OR (F <= lower threshold AND Q < M AND K < -Q) OR (B < -Q AND K < -Q))
Short: F >= upper threshold
Short: R > upper threshold OR B - 1 > F
Short: V < 1 AND NOT Y AND NOT G
Short: B - 1 <= Q AND (B < 0 OR B - 1 > F OR B < -Q)
Short: B - 1 > -Q OR B - 1 > Q
Short: F >= lower threshold AND B - 1 > F AND Q > 0