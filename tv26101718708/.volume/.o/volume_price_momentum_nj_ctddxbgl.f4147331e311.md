Calculation: Volume percentile rank = current volume’s percentile rank within the volume lookback
Calculation: Price percentile rank = current close’s percentile rank within the price lookback
Calculation: Capped score = the average of the volume and price percentile ranks, smoothed with an SMA, then limited to 35–60
Long: Capped score >= buy threshold AND capped score >= sell threshold AND no active range
Short: Capped score < sell threshold