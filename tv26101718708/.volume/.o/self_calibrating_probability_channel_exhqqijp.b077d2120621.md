Calculation: One-step forecast = previous bar’s forecast path plus drift; by default, the path blends EMA projection, linear-regression projection, session-anchored VWAP projection, and a level-and-velocity tracker, weighted inversely by their exponentially smoothed prior forecast errors.
Calculation: Forecast residuals = (close − one-step forecast) divided by the prior bar’s ATR; retain completed residuals in a rolling window and use a shorter, more recent window for band quantiles.
Calculation: 90% and 95% prediction bands = one-step forecast plus the corresponding lower and upper empirical residual quantiles, scaled by the prior ATR and adjusted by online coverage calibration.
Calculation: Upper breach threshold = upper 95% band + anomaly sensitivity × max(upper 95% band − upper 90% band, 0.05 × ATR).
Calculation: Lower breach threshold = lower 95% band − anomaly sensitivity × max(lower 90% band − lower 95% band, 0.05 × ATR).
Long: warmed up AND close > upper breach threshold AND previous close ≤ previous upper breach threshold.
Short: warmed up AND close < lower breach threshold AND previous close ≥ previous lower breach threshold.