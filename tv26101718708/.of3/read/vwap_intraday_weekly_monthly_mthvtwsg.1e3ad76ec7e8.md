Calculation: Intraday volume-weighted standard deviation(source, anchor) = sqrt(max(sum(source² × volume, anchor) / sum(volume, anchor) − VWAP(source, anchor)², 0))
Long: close > VWAP(source, anchor) + Band 1 multiplier × Intraday volume-weighted standard deviation(source, anchor)
Short: close < VWAP(source, anchor) − Band 1 multiplier × Intraday volume-weighted standard deviation(source, anchor)