Calculation: CVD = cumulative sum of ((close − open) / (high − low)) × volume; use zero when high = low.
Calculation: Score = clamp the sum of smoothed price-change and CVD-change Z-scores to fixed symmetric bounds; each change uses the longer trend lookback, each Z-score divides that change by its standard deviation over a longer lookback, and both are smoothed with the same shorter lookback. Use zero when a standard deviation is zero.
Calculation: Daily price change = current forming daily close − previous completed daily close.
Calculation: Daily OI change = current forming daily OI close − previous completed daily OI close.
Calculation: Upper/lower band = chart-timeframe EMA of close ± ATR × band-width parameter.
Calculation: Dynamic entry threshold = base threshold × a session multiplier during 08:00–16:00 Asia/Tokyo; otherwise the base threshold.
Calculation: OI Z-score = (current forming daily OI close − mean of daily OI closes) / standard deviation of daily OI closes, using the same lookback for mean and standard deviation; use zero when standard deviation is zero.
Long: Score crosses above the dynamic entry threshold AND close > upper band AND ((daily price change > 0 AND daily OI change > 0) OR (daily price change < 0 AND daily OI change < 0)).
Short: Score crosses below the negative dynamic entry threshold AND close < lower band AND daily price change < 0 AND daily OI change > 0.
Exit: Long, Score crosses below the negative base threshold OR close crosses below the lower band OR (OI Z-score exceeds its threshold AND Score < 0) OR low reaches the entry-signal bar close − ATR × stop multiple.
Exit: Short, Score crosses above the base threshold OR close crosses above the upper band OR (OI Z-score exceeds its threshold AND Score > 0) OR high reaches the entry-signal bar close + ATR × stop multiple.