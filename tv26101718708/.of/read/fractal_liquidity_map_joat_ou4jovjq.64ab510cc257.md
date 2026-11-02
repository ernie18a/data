Calculation: Hann filter of length N = sum over i = 1 through N of close[i-1] × (1 − cos(2πi / (N+1))), divided by the sum of those weights; fast, middle, and slow filters have progressively longer lengths with equal spacing.
Long: The low N bars ago is less than or equal to the lowest low over the current and preceding 2N bars.
Short: The high N bars ago is greater than or equal to the highest high over the current and preceding 2N bars.
Long: Low < lowest low over the preceding sweep lookback bars − ATR × sweep tolerance AND close > lowest low over the preceding sweep lookback bars.
Short: High > highest high over the preceding sweep lookback bars + ATR × sweep tolerance AND close < highest high over the preceding sweep lookback bars.
Long: Fast Hann filter > middle Hann filter AND middle Hann filter > slow Hann filter.
Short: Fast Hann filter < middle Hann filter AND middle Hann filter < slow Hann filter.
Long: Fast Hann filter crosses above middle Hann filter.
Short: Fast Hann filter crosses below middle Hann filter.