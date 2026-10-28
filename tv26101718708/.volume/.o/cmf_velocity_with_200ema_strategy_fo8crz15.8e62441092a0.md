Calculation: Chaikin Money Flow = SMA((((close − low) − (high − close)) / (high − low)) × volume, lookback) / SMA(volume, same lookback)
Calculation: CMF Velocity = SMA(change in Chaikin Money Flow, shorter lookback)
Calculation: Stop distance = ATR × stop multiplier; target distance = stop distance × profit/loss multiplier
Long: CMF Velocity crosses above 0 AND close > EMA(close, longer lookback)
Short: CMF Velocity crosses below 0 AND close < EMA(close, longer lookback)
Exit: Long, low ≤ entry price − stop distance OR high ≥ entry price + target distance
Exit: Short, high ≥ entry price + stop distance OR low ≤ entry price − target distance