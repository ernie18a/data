Calculation: Active level = the configured nonzero support or resistance level nearest to the current close
Calculation: Arrival direction = rising if close > close from the longer arrival lookback; falling if close < that close
Calculation: Arrival strength = round(max(1, min(100, 0.40 × min(abs(close − prior close) / ATR × 25, 100) + 0.30 × min(short-lookback average(high − low) / ATR × 100, 100) + 0.30 × min((volume / longer-lookback average volume) × 50, 100))))
Calculation: Compression = the short-lookback average(high − low) is less than the longer-lookback average(high − low)
Calculation: Level quality = count closes within the ATR-scaled touch band of the active level over the level-test lookback; quality is acceptable when this count does not exceed the maximum touch count
Calculation: Rejection = high > active level and close < active level, or low < active level and close > active level
Calculation: False breakout = the prior bar crossed from at-or-below the active level to above it and the current close is below it, or the prior bar crossed from at-or-above the level to below it and the current close is above it
Calculation: Short sweep = high > active level + ATR-scaled sweep distance and close < active level
Calculation: Long sweep = low < active level − ATR-scaled sweep distance and close > active level
Calculation: Extension = abs(close − EMA) / ATR; it is acceptable when it does not exceed the configured maximum extension
Long: Long sweep OR (false breakout AND arrival direction is not rising) OR (rejection AND not a sweep, false breakout, or level crossing AND arrival strength ≤ entry threshold AND compression is enabled or true AND extension is enabled or acceptable AND level quality is acceptable)
Short: Short sweep OR (false breakout AND arrival direction is rising) OR (rejection AND not a sweep, false breakout, or level crossing AND arrival strength ≤ entry threshold AND compression is enabled or true AND extension is enabled or acceptable AND level quality is acceptable)
Exit: short, close ≤ exit EMA
Exit: long, close ≥ exit EMA