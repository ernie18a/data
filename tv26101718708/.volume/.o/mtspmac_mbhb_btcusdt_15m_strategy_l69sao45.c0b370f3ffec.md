Calculation: Momentum-adjusted EMA of source S over lookback N = EMA(S + (M + 0.5 × change(M, Mlookback)) × count of positive one-bar changes in S over round(N/φ²) bars ÷ (N/φ²), N), where M = change(S, round(N/φ)) and φ = (1 + √5)/2
Calculation: Fast MA = momentum-adjusted EMA of high with a shorter lookback than the slow MA
Calculation: Slow MA = momentum-adjusted EMA of close
Long: Fast MA crosses above slow MA
Long: Fast MA crosses above slow MA AND (high + low + close) / 3 < Bollinger basis + inner-band multiplier × standard deviation of close
Long: Low ≤ Bollinger basis − breakout multiplier × standard deviation of close
Short: Slow MA crosses above fast MA
Short: High ≥ Bollinger basis + breakout multiplier × standard deviation of close
Exit: Long, slow MA crosses above fast MA
Exit: Long, high > fast MA