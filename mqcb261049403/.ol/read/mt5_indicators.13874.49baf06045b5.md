Calculation: JCCX = JurX-smoothed (selected OHLC price minus its JJMA) divided by JurX-smoothed absolute deviation from that JJMA, clipped to [-1, 1]. The JJMA and both JurX smoothings use the same JCCX lookback setting; the five JCCX series use progressively longer lookbacks. Calculate on chart bars; in the HTF variant, calculate on the selected higher timeframe and use its bar still forming.
Calculation: Fast trend = weighted sum of the five JCCX series; the third series uses the same weight as the second.
Calculation: Slow trend = current fast trend divided by the smoothing length plus the previous slow trend multiplied by (smoothing length minus one) divided by the smoothing length.
Long: Fast trend > slow trend
Short: Fast trend < slow trend