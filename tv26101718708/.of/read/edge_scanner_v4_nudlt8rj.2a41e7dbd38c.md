Calculation: Rolling range high = highest high over the lookback on the higher scan timeframe, using its last completed bar
Calculation: Rolling range low = lowest low over the same lookback on the higher scan timeframe, using its last completed bar
Calculation: Lower edge = rolling range low + (rolling range high − rolling range low) × edge-zone percentage
Calculation: Upper edge = rolling range high − (rolling range high − rolling range low) × edge-zone percentage
Long: scan-timeframe close ≤ lower edge AND scan-timeframe close > (rolling range high + rolling range low) / 2
Short: scan-timeframe close ≥ upper edge AND scan-timeframe close < (rolling range high + rolling range low) / 2