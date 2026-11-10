Calculation: Shape ratio = 0 if high equals low; otherwise choose (2 × close − high − low) / (high − low), (close − open) / (high − low), or (min(open, close) − low − high + max(open, close)) / (high − low).
Calculation: Pressure = clamp(100 × sensitivity × smoothed shape ratio, −100, 100). In confirmed mode, use the previous chart bar's shape ratio and volume, replacing missing values with zero; otherwise use the current chart bar. Choose either the EMA of shape ratio or SMA(shape ratio × volume) / max(SMA(volume), 1e−10), using the same smoothing length for both SMAs.
Long: Pressure > neutral threshold.
Short: Pressure < −neutral threshold.
Long: Pressure >= extreme threshold.
Short: Pressure <= −extreme threshold.
Long: Pressure crosses above zero.
Short: Pressure crosses below zero.
Long: EMA of pressure >= 0, when signal line and signal fill are enabled.
Short: EMA of pressure < 0, when signal line and signal fill are enabled.