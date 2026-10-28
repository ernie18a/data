Calculation: Price correlation = Pearson correlation of asset close and benchmark close over the lookback window, using current chart-timeframe bars.
Calculation: Volume-weighted return = (current close − previous close) / previous close × current volume / SMA(volume, lookback window).
Calculation: Volume-weighted correlation = Pearson correlation of the asset and benchmark volume-weighted returns over the lookback window.
Calculation: Beta = covariance of asset and benchmark close-to-close returns divided by the variance of benchmark returns, over the lookback window.
Calculation: Relative-strength momentum = (asset close / benchmark close ÷ SMA(asset close / benchmark close, lookback window) − 1) × 100.
Calculation: Spread Z-score = (ln(asset close / benchmark close) − rolling mean of ln(asset close / benchmark close)) / rolling standard deviation of ln(asset close / benchmark close), over the lookback window.
Long: Price correlation ≥ correlation threshold AND volume-weighted correlation ≥ correlation threshold AND relative-strength momentum > 0 AND beta > 0.8 AND spread Z-score < Z-score threshold
Long: Price correlation ≥ correlation threshold AND relative-strength momentum > 0 AND beta > 0.8
Short: Relative-strength momentum < 0 OR price correlation < 0.20 OR spread Z-score ≥ Z-score threshold