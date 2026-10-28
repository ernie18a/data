Calculation: demand share = if high > low, then (high - low) / (2 × (high - low) - abs(close - open)) when close >= open, otherwise ((high - low) - abs(close - open)) / (2 × (high - low) - abs(close - open)); otherwise 0.5
Calculation: demand volume = apply WMA with a longer lookback, then a shorter smoothing lookback, to volume × demand share
Calculation: supply volume = apply the same WMAs to volume × (1 - demand share)
Calculation: net volume = demand volume - supply volume
Long: net volume >= 0
Short: net volume < 0