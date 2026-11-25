Calculation: Direction balance(close, lookback) = 100 × (count(close[k] > close[k+1], k=0..lookback−1) − count(close[k] ≤ close[k+1], k=0..lookback−1)) / lookback
Long: Direction balance(close, chart lookback) > 0
Short: Direction balance(close, chart lookback) ≤ 0
Long: Direction balance(close, T1 lookback, T1, bar still forming, sampled on chart bars) > 0
Short: Direction balance(close, T1 lookback, T1, bar still forming, sampled on chart bars) ≤ 0