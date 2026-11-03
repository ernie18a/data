Calculation: Candle range = high − low
Calculation: Pressure atom = volume × [0.42 × (2 × (close − low) / candle range − 1) + 0.42 × (close − open) / candle range + 0.16 × ((min(open, close) − low) − (high − max(open, close))) / candle range]
Calculation: Normalized pressure = pressure atom / EMA(abs(pressure atom), longer lookback)
Calculation: Pressure tensor = EMA(normalized pressure, shorter lookback)
Calculation: Pressure curvature = pressure tensor − 2 × previous pressure tensor + pressure tensor two bars ago
Calculation: Pressure jerk = current pressure curvature − previous pressure curvature
Calculation: ATR stress rank = percentile rank of ATR / close over a lookback
Calculation: Range stress rank = percentile rank of candle range / close over the same lookback
Calculation: Directional certainty = 100 − normalized binary Shannon entropy of the shares of positive and negative pressure atom over a lookback
Calculation: Impulse score = clamp(abs(pressure tensor) × 34 + 0.25 × range stress rank + 0.35 × directional certainty, 0, 100)
Calculation: Convexity score = clamp(abs(pressure curvature) × 55 + abs(pressure jerk) × 25, 0, 100)
Calculation: Stress composite = clamp(0.38 × ATR stress rank + 0.34 × impulse score + 0.28 × convexity score, 0, 100)
Calculation: Tensor basis = EMA(close, lookback)
Calculation: Tensor skew = EMA(pressure tensor, same lookback as tensor basis)
Calculation: Tensor width = ATR × (0.85 + stress composite / 90)
Calculation: Upper tensor band = tensor basis + tensor width × (1 + 0.12 × max(tensor skew, 0))
Calculation: Lower tensor band = tensor basis − tensor width × (1 + 0.12 × max(−tensor skew, 0))
Long: pressure tensor > 0 AND stress composite >= shock threshold AND pressure curvature > 0 OR close < lower tensor band AND pressure curvature > 0 AND stress composite >= reversion threshold
Short: pressure tensor < 0 AND stress composite >= shock threshold AND pressure curvature < 0 OR close > upper tensor band AND pressure curvature < 0 AND stress composite >= reversion threshold