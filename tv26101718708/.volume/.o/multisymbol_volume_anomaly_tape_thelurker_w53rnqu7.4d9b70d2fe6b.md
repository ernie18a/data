Calculation: Selected volume measure = volume, close × volume, or hlc3 × volume
Calculation: Volume anomaly z-score = (ln(current print’s selected volume measure) − mean of the preceding lower-timeframe prints’ log measures) ÷ their standard deviation; use a rolling reference window
Calculation: Print direction = +1 if close > open, −1 if close < open; otherwise +1 if close is above the range midpoint, −1 if below, and if still unresolved compare close with the previous print’s close (equal or unavailable means 0)
Long: Volume anomaly z-score meets the configured display threshold and print direction > 0
Short: Volume anomaly z-score meets the configured display threshold and print direction < 0