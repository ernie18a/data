Calculation: SMA distance(level) = 100 × (close − level) / level for nonzero level
Calculation: gap threshold = gap deviation parameter / 100 × SMA(high − low, gap range lookback)
Long: PVSRA(source open, source high, source low, source close, source volume, current chart bar) classifies a regular, major, or secondary bullish candle
Short: PVSRA(source open, source high, source low, source close, source volume, current chart bar) classifies a regular, major, or secondary bearish candle
Long: low > high[1] AND low − high[1] >= gap threshold
Short: high < low[1] AND low[1] − high >= gap threshold
Long: SMA distance(SMA(close, one of the separate short, medium, or long SMA lookback parameters, T1, current T1 bar sampled on chart bars)) > 0
Short: SMA distance(SMA(close, one of the separate short, medium, or long SMA lookback parameters, T1, current T1 bar sampled on chart bars)) < 0
Long: SMA distance(SMA(close, one of the separate short, medium, or long SMA lookback parameters multiplied by one of the separate increasing annual scale parameters, T1, current T1 bar sampled on chart bars)) > 0
Short: SMA distance(SMA(close, one of the separate short, medium, or long SMA lookback parameters multiplied by one of the separate increasing annual scale parameters, T1, current T1 bar sampled on chart bars)) < 0