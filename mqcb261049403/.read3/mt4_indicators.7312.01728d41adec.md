Calculation: smoothed EMA spread = EMA(EMA(close, shorter lookback) - EMA(close, longer lookback), smoothing lookback)
Long: smoothed EMA spread on T1 bars, using the bar still forming, crosses above zero
Long: smoothed EMA spread on chart bars crosses above zero AND the most recent T1 zero crossing is upward
Short: smoothed EMA spread on T1 bars, using the bar still forming, crosses below zero
Short: smoothed EMA spread on chart bars crosses below zero AND the most recent T1 zero crossing is downward