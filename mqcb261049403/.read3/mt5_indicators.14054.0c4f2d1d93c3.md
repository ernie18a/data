Calculation: Weighted DeMarker = weight1 × DeMarker(high, low, lookback1) + weight2 × DeMarker(high, low, lookback2) + weight2 × DeMarker(high, low, lookback3) + weight4 × DeMarker(high, low, lookback4) + weight5 × DeMarker(high, low, lookback5)
Calculation: Smoothed weighted DeMarker = Weighted DeMarker / smoothing lookback + prior Smoothed weighted DeMarker × (smoothing lookback − 1) / smoothing lookback; initialize as Weighted DeMarker / smoothing lookback
Long: Weighted DeMarker > Smoothed weighted DeMarker
Short: Weighted DeMarker < Smoothed weighted DeMarker
Long: On chart bars, using values calculated on T1 bars for the bar still forming, Weighted DeMarker > Smoothed weighted DeMarker
Short: On chart bars, using values calculated on T1 bars for the bar still forming, Weighted DeMarker < Smoothed weighted DeMarker