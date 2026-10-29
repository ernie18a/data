Calculation: Smoothed Stochastic %K = the simple moving average of (close − lowest low) / (highest high − lowest low) × 100 over a lookback.
Calculation: Stochastic %D = the simple moving average of smoothed %K over a shorter lookback; use the same lookbacks on each watched timeframe.
Calculation: Direction on each timeframe = sign of smoothed %K − %D, using that timeframe’s bars; use the last completed bar for higher timeframes.
Calculation: Agreement streak = consecutive chart bars on which all watched timeframes have the same nonzero direction; otherwise it is zero.
Calculation: Continuation threshold = the configured percentile, using linear interpolation, of the rolling history of completed agreement streaks; score only after the required minimum number of completed streaks is available.
Long: all watched timeframe directions > 0 AND agreement streak > continuation threshold AND prior bar’s bullish continuation state = false AND chart bar is confirmed.
Short: all watched timeframe directions < 0 AND agreement streak > continuation threshold AND prior bar’s bearish continuation state = false AND chart bar is confirmed.