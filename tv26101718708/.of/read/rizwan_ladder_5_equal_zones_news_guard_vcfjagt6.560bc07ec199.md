Calculation: range high = highest daily high over the lookback, including the still-forming daily bar
Calculation: range low = lowest daily low over the lookback, including the still-forming daily bar
Calculation: zone half-width = max(ATR on the configured ATR timeframe × configured zone-width multiplier ÷ 2, five minimum price increments)
Calculation: ladder levels = range low, range low + (range high − range low) ÷ 4, range low + (range high − range low) × 3 ÷ 4, and range high
Long: close is within zone half-width of the range low OR within zone half-width of range low + (range high − range low) ÷ 4
Short: close is within zone half-width of range high OR within zone half-width of range low + (range high − range low) × 3 ÷ 4