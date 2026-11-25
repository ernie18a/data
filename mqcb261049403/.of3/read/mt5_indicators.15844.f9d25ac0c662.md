Calculation: VWMA change = VWMA(close, volume, lookback) - VWMA(close, volume, lookback)[1]
Calculation: rounded VWMA change = round(VWMA change, instrument precision + 2 decimal places)
Calculation: first threshold = round(first filter multiplier × standard deviation(VWMA change, deviation lookback), instrument precision + 2 decimal places)
Calculation: second threshold = round(second filter multiplier × standard deviation(VWMA change, deviation lookback), instrument precision + 2 decimal places)
Long: (rounded VWMA change > first threshold AND rounded VWMA change <= second threshold) OR rounded VWMA change > second threshold
Short: (rounded VWMA change < -first threshold AND rounded VWMA change >= -second threshold) OR rounded VWMA change < -second threshold