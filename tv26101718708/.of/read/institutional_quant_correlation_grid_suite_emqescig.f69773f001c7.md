Calculation: Close correlation = Pearson correlation between asset close and benchmark close over the lookback window
Calculation: Volume-weighted return = close-to-close return × (current volume / lookback SMA of volume)
Calculation: Volume-weighted correlation = Pearson correlation between asset and benchmark volume-weighted returns over the lookback window
Calculation: Beta = SMA((asset return − SMA(asset return)) × (benchmark return − SMA(benchmark return))) / SMA((benchmark return − SMA(benchmark return))²), using the lookback window
Calculation: Relative-strength momentum = (asset close / benchmark close / SMA(asset close / benchmark close) − 1) × 100, using the lookback window
Calculation: Spread z-score = (ln(asset close / benchmark close) − SMA(ln(asset close / benchmark close))) / stdev(ln(asset close / benchmark close)), using the lookback window
Long: Close correlation ≥ correlation threshold AND relative-strength momentum > 0 AND beta > 0.8
Long: Close correlation ≥ correlation threshold AND volume-weighted correlation ≥ correlation threshold AND relative-strength momentum > 0 AND beta > 0.8 AND spread z-score < z-score threshold
Short: Relative-strength momentum < 0 OR close correlation < 0.20 OR spread z-score ≥ z-score threshold