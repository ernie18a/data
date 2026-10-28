Calculation: Momentum acceleration signal = v − (v − v[n]) / n, where v is the 3-bar simple moving average of (source − source n bars ago) / n, and source is either close or on-balance volume (volume added when close rises, subtracted when it falls, unchanged when equal).
Long: Momentum acceleration signal > 0 AND previous bar’s signal ≤ 0
Short: Momentum acceleration signal < 0 AND previous bar’s signal ≥ 0
Exit: Long, short condition OR low ≤ entry price × (1 − stop-loss fraction)
Exit: Short, long condition OR high ≥ entry price × (1 + stop-loss fraction)