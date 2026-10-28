Calculation: Normalized CVD = (percentile rank of EMA(raw delta, longer smoothing lookback) over its normalization lookback − 50) × 2, where raw delta = (close − open) / (high − low) × min(volume / SMA(volume, volume lookback), 3)^volume weight; use 0 for the ratio when high = low and 1 for the volume ratio when its SMA is 0
Calculation: Normalized momentum = (percentile rank of EMA(current normalized CVD − normalized CVD from the momentum lookback bars earlier, smoothing lookback) over its normalization lookback − 50) × 2
Calculation: Composite score = EMA(weighted sum of normalized CVD and normalized momentum, composite smoothing lookback)
Calculation: Trend bias = EMA(composite score, longer lookback)
Calculation: ATR percentile = percentile rank of ATR over its normalization lookback
Long: Composite score crosses above 0 AND trend bias > 0 AND ATR percentile >= low volatility threshold AND ATR percentile <= high volatility threshold
Short: Composite score crosses below 0 AND trend bias <= 0 AND ATR percentile >= low volatility threshold AND ATR percentile <= high volatility threshold