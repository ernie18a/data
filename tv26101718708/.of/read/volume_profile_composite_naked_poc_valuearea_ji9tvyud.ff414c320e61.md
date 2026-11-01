Calculation: Estimated cumulative volume delta = cumulative sum of volume × (2 × buy fraction − 1). By default, buy fraction is 1 / (1 + exp(−1.702 × clamp(price change / volatility, −8, 8))), where price change is close minus previous close and volatility is the square root of the volume-weighted mean of squared price changes over a lookback; if that volatility is unavailable or zero, use the standard deviation of price changes. If classification is disabled or volatility is unavailable or zero, buy fraction is 1 when close ≥ open and 0 otherwise.
Calculation: Anchored VWAP = volume-weighted average of (high + low + close) / 3, starting at the selected anchor: the first chart bar of each session, a confirmed swing low, a confirmed swing high, or the most recently confirmed swing of either kind. Swing anchors start on the confirmation bar, subject to a minimum number of bars since the preceding anchor.
Calculation: Higher-timeframe POC proxy = (high + low + close) / 3 of the most recent highest-volume bar in a lookback ending at the last completed higher-timeframe bar.
Calculation: Efficiency ratio = absolute change in close over a lookback divided by the sum of absolute successive close changes over the same lookback; use zero if the denominator is zero.
Long: Close ≤ close at the divergence lookback AND estimated cumulative volume delta > estimated cumulative volume delta at the same lookback.
Short: Close > close at the divergence lookback AND estimated cumulative volume delta ≤ estimated cumulative volume delta at the same lookback.
Long: Close ≥ anchored VWAP.
Short: Close ≤ anchored VWAP.
Long: Close > higher-timeframe POC proxy.
Short: Close < higher-timeframe POC proxy.
Long: ADX > trend threshold AND efficiency ratio > efficiency threshold AND close > exponential moving average of close.
Short: ADX > trend threshold AND efficiency ratio > efficiency threshold AND close ≤ exponential moving average of close.