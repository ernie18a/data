Calculation: Demand level = persistently retain demand levels; on each bar, scan offsets 2 through the swing lookback and prepend each low that is below the lows at offsets i−1, i+1, i−2, and i+2; the latest level is the first retained level.
Calculation: Supply level = persistently retain supply levels; on each bar, scan offsets 2 through the swing lookback and prepend each high that is above the highs at offsets i−1, i+1, i−2, and i+2; the latest level is the first retained level.
Calculation: Volume spike = volume exceeds the longer-lookback SMA of volume multiplied by a threshold.
Calculation: Two-pole smoother of x at length L = c1 × (x + prior x) / 2 + c2 × prior smoother + c3 × smoother from two bars ago, where f = 1.414π/L, a = exp(−f), c2 = 2a cos(f), c3 = −a², and c1 = 1 − c2 − c3.
Calculation: Momentum = (shorter-length two-pole smoother of close − longer-length two-pole smoother of close) × scale; momentum signal = two-pole smoother of momentum at its smoothing length.
Calculation: Bullish order block = the candle at offset periods+1 is bearish, the preceding periods candles are all bullish, and abs(close at offset periods+1 − close[1]) / close at offset periods+1 × 100 exceeds a threshold.
Calculation: Bearish order block = the candle at offset periods+1 is bullish, the preceding periods candles are all bearish, and abs(close at offset periods+1 − close[1]) / close at offset periods+1 × 100 exceeds a threshold.
Long: low ≤ latest demand level AND close > latest demand level AND close > 50-period EMA AND volume spike
Long: momentum crosses above its signal
Long: bullish order block
Short: high ≥ latest supply level AND close < latest supply level AND close < 50-period EMA AND volume spike
Short: momentum crosses below its signal
Short: bearish order block
Exit: long, low ≤ entry price − stop distance
Exit: short, high ≥ entry price + stop distance