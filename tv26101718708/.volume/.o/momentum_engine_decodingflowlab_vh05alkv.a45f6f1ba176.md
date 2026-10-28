Calculation: ATR expansion score = clamp(100 × (fast ATR / slow ATR − 0.8) / (1.8 − 0.8), 0, 100), using a shorter lookback for fast ATR than slow ATR
Calculation: Candle body score = clamp(100 × (|close − open| / (high − low) − 0.2) / (0.9 − 0.2), 0, 100); use 0 when high = low
Calculation: Volume score = clamp(100 × (volume / volume EMA − 0.8) / (2.0 − 0.8), 0, 100), using the current bar's volume and an EMA of volume
Calculation: Breakout speed score = clamp(100 × (breakout distance / slow ATR) / 1.2, 0, 100); breakout distance is close minus the highest high of the preceding lookback bars if close exceeds that high, or the lowest low of the preceding lookback bars minus close if close is below that low, otherwise 0
Calculation: Pullback score = 100 − clamp(100 × pullback depth / 0.7, 0, 100); in an up direction, depth = (highest high − close) / (highest high − lowest low); in a down direction, depth = (close − lowest low) / (highest high − lowest low); the highs and lows use the same lookback including the current bar. If the range is zero, depth = 1. In a flat direction, score = 50.
Calculation: Momentum score = 0.25 × ATR expansion score + 0.20 × candle body score + 0.20 × volume score + 0.20 × breakout speed score + 0.15 × pullback score
Long: Momentum score ≥ strong threshold AND close > EMA(close)
Short: Momentum score ≥ strong threshold AND close < EMA(close)