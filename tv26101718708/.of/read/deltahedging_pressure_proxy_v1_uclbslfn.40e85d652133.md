Calculation: Realized volatility = standard deviation of log(close / previous close) over a lookback.
Calculation: Synthetic gamma = standard normal probability density at d1 / (close × sigma × sqrt(T)), where T = max(expiry horizon in bars / bars per year, 0.000001), sigma = max(realized volatility × sqrt(bars per year), 0.000001), d1 = (log(close / strike) + (risk-free rate + sigma² / 2) × T) / (sigma × sqrt(T)), and strike is selected as current close, a fixed parameter, or an EMA of close.
Calculation: Raw pressure = synthetic gamma × (close − previous close) × volume factor × volatility factor. When enabled, volume factor is current volume / SMA(volume), or 1 if the average is not positive; volatility factor is realized volatility / SMA(realized volatility), or 1 if that average is not positive. Clamp each enabled factor to [0.5, 2.5]; a disabled factor is 1.
Calculation: Pressure score = the sign of raw pressure multiplied by 100 times the fraction of valid raw-pressure magnitudes in the preceding percentile lookback that are strictly less than the current magnitude; use zero when raw pressure is zero. Optionally apply an EMA to this signed score.
Calculation: Pressure regime = low if absolute pressure score < low threshold; otherwise normal if absolute pressure score < high threshold; otherwise high if absolute pressure score < extreme threshold; otherwise extreme.
Long: Pressure regime = normal AND pressure score >= 0
Short: Pressure regime = normal AND pressure score < 0
Long: Pressure regime = high AND pressure score >= 0
Short: Pressure regime = high AND pressure score < 0
Long: Pressure regime = extreme AND pressure score >= 0
Short: Pressure regime = extreme AND pressure score < 0
Long: Pressure score > 0 AND pressure regime = high AND previous pressure regime != high
Short: Pressure score < 0 AND pressure regime = high AND previous pressure regime != high
Long: Pressure score > 0 AND pressure regime = extreme AND previous pressure regime != extreme
Short: Pressure score < 0 AND pressure regime = extreme AND previous pressure regime != extreme
Long: Pressure score > 0 AND (pressure regime = high OR pressure regime = extreme) AND absolute pressure score > absolute previous pressure score
Short: Pressure score < 0 AND (pressure regime = high OR pressure regime = extreme) AND absolute pressure score > absolute previous pressure score
Long: Pressure score > 0 AND previous pressure score <= 0
Short: Pressure score < 0 AND previous pressure score >= 0