Calculation: Capped score = min(upper cap, max(lower cap, SMA((PercentRank(volume, volume lookback) + PercentRank(close, price lookback)) / 2, smoothing lookback)))
Long: Capped score >= buy threshold AND range is inactive
Short: Capped score < sell threshold