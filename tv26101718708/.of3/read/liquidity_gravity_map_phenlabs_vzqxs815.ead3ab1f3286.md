Calculation: BarSpan = high - low
Long: PivotLow(low, PivotBars, PivotBars) is not NA
Long: low < Highest(low[1], SweepLookback) AND close > low + CloseFraction * BarSpan AND min(open, close) - low >= WickMin * BarSpan
Short: PivotHigh(high, PivotBars, PivotBars) is not NA
Short: high > Highest(high[1], SweepLookback) AND close < high - CloseFraction * BarSpan AND high - max(open, close) >= WickMin * BarSpan