Calculation: QuartileTouch = on each chart bar, low <= Lowest(low, lookback) + q * (Highest(high, lookback) - Lowest(low, lookback)) <= high for any q in {0, 1/4, 1/2, 3/4, 1}
Calculation: Delta = on each chart bar, sum the volume of T1 bars inside it when close >= open minus their volume when close < open, including a still-forming T1 bar when present; if there are no T1 bars, use chart-bar volume when close >= open and its negative otherwise
Long: Delta > 0 AND QuartileTouch
Short: Delta <= 0 AND QuartileTouch