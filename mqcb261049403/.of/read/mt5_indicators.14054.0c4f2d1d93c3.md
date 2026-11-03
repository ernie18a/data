Calculation: Weighted DeMarker = weighted sum of five DeMarker values with progressively longer lookbacks; the second and third values share the same weight, and the other values have separate weights.
Calculation: Smoothed weighted DeMarker = weighted DeMarker / smoothing period + previous smoothed weighted DeMarker × (smoothing period − 1) / smoothing period; initialize it to weighted DeMarker / smoothing period on the bar whose zero-based index is 3 × the longest DeMarker lookback + 2.
Long: Chart-timeframe weighted DeMarker > chart-timeframe smoothed weighted DeMarker.
Short: Chart-timeframe weighted DeMarker < chart-timeframe smoothed weighted DeMarker.
Long: Weighted DeMarker of the still-forming higher-timeframe bar > smoothed weighted DeMarker of the still-forming higher-timeframe bar.
Short: Weighted DeMarker of the still-forming higher-timeframe bar < smoothed weighted DeMarker of the still-forming higher-timeframe bar.