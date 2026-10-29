Calculation: Fast and slow EMA = exponential moving averages of close, with the fast EMA using the shorter lookback
Calculation: Prior high = highest high over the lookback bars before the current bar
Calculation: Prior low = lowest low over the lookback bars before the current bar
Calculation: Lower-wick percentage = 100 × (min(open, close) − low) / (high − low)
Calculation: Upper-wick percentage = 100 × (high − max(open, close)) / (high − low)
Long: Fast EMA < slow EMA AND low < prior low AND close < prior low on a downside continuation-attempt bar within the failure window AND close > that attempt’s prior-low level AND lower-wick percentage ≥ the wick threshold
Short: Fast EMA > slow EMA AND high > prior high AND close > prior high on an upside continuation-attempt bar within the failure window AND close < that attempt’s prior-high level AND upper-wick percentage ≥ the wick threshold