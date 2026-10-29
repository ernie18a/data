Calculation: EVWMA = ((sum of volume over the lookback, including the current bar − current-bar volume) × previous EVWMA + current-bar volume × close) / sum of volume over the lookback; initialize the previous EVWMA with close when unavailable
Calculation: Upper band = EVWMA + multiplier × standard deviation of close over the same lookback; Lower band = EVWMA − multiplier × standard deviation of close over the same lookback
Long: high ≥ Upper band
Short: low ≤ Lower band
Exit: Long, low ≤ EVWMA
Exit: Short, high ≥ EVWMA