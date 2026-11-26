Calculation: Bézier slope = difference between consecutive Bézier-filtered selected-price values using a smoothing lookback and sensitivity parameter
Long: Bézier slope > threshold multiplier × RMS(Bézier slope, volatility lookback)
Short: Bézier slope < −threshold multiplier × RMS(Bézier slope, volatility lookback)
Long: T1 still-forming bar Bézier slope > threshold multiplier × RMS(Bézier slope, volatility lookback), calculated on T1 bars and copied to chart bars
Short: T1 still-forming bar Bézier slope < −threshold multiplier × RMS(Bézier slope, volatility lookback), calculated on T1 bars and copied to chart bars