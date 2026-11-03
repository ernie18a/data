Calculation: Anchored VWAP = cumulative volume-weighted source price since the selected anchor reset
Calculation: Weighted standard deviation = square root of the volume-weighted mean of squared source price minus Anchored VWAP, floored at zero before taking the square root
Long: warm-up complete AND low <= Anchored VWAP - band-width multiplier × weighted standard deviation
Long: warm-up complete AND close crosses above Anchored VWAP
Short: warm-up complete AND high >= Anchored VWAP + band-width multiplier × weighted standard deviation
Short: warm-up complete AND close crosses below Anchored VWAP