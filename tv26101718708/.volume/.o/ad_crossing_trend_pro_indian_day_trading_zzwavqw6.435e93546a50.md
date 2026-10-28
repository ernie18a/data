Calculation: A/D flow = rolling sum over a lookback of per-bar ((2 × close − low − high) / (high − low)) × volume; use 0 when high = low, optionally EMA-smooth each per-bar value first, and optionally divide the sum by the lookback.
Calculation: Fast trend = shorter-lookback EMA of A/D flow
Calculation: Slow trend = longer-lookback EMA of A/D flow
Calculation: Trend strength = absolute difference between fast and slow trends > SMA of that absolute difference × a multiplier
Long: fast trend crosses above slow trend AND trend strength
Short: fast trend crosses below slow trend AND trend strength