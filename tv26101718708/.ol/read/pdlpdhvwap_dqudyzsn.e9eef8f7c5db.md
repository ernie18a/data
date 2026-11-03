Calculation: PDH = high of the last completed daily bar (higher timeframe)
Calculation: PDL = low of the last completed daily bar (higher timeframe)
Calculation: VWAP slope = percentage change in session VWAP from its value a longer lookback ago; rising if above a positive threshold, falling if below its negative, otherwise flat
Calculation: Bars since level break = number of chart-timeframe bars since the most recent close crossed beyond PDH or PDL
Long: Close > PDH AND previous close <= PDH
Long: Close > PDL AND previous close <= PDL
Long: Close > PDL AND previous close <= PDL AND bars since PDL break <= sweep window
Long: All of the preceding setup bars closed below VWAP AND close > VWAP AND close > open AND close < PDH
Short: High >= PDH AND close < PDH AND previous high < PDH
Short: Close < PDL AND previous close >= PDL
Short: Close < PDH AND previous close > PDH AND bars since PDH break <= sweep window
Short: All of the preceding setup bars closed above VWAP AND close < VWAP AND close < open AND close > PDL