Calculation: Fast-slow difference = XMA(applied price, shorter lookback, shared fast/slow smoothing method and phase) − XMA(applied price, longer lookback, same method and phase); calculate on T1 bars and sample at the selected offset, which may be the still-forming current bar
Calculation: Awesome trend = Fast-slow difference − XMA(Fast-slow difference, signal lookback, separate signal smoothing method and phase), retaining its previous value when this result is zero
Long: Awesome trend > 0
Short: Awesome trend < 0