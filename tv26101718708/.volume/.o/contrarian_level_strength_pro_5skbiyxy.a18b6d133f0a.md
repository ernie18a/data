Calculation: Active level = configured nonzero support/resistance level nearest the current close
Calculation: ATR = current-timeframe average true range
Calculation: Arrival strength = max(1, round(min(0.4 × min(abs(close − close[N]) / ATR × 25, 100) + 0.3 × min(SMA(high − low, N) / ATR × 100, 100) + 0.3 × min((volume / SMA(volume, V)) × 50, 100), 100)))
Calculation: Compression = SMA(high − low, 3) < SMA(high − low, N)
Calculation: Not overextended = abs(close − EMA(close, E)) / ATR ≤ extension limit
Calculation: Level is valid = active level exists and the count of closes within touch distance of it over the level-test lookback is ≤ maximum touches
Calculation: Sweep below = low < active level − ATR × sweep distance and close > active level
Calculation: Sweep above = high > active level + ATR × sweep distance and close < active level
Calculation: False break below = previous bar crossed below the active level and current close > active level
Calculation: False break above = previous bar crossed above the active level and current close < active level
Calculation: Rejection = high > active level and close < active level, or low < active level and close > active level
Long: active level exists AND not pre-touch AND (sweep below OR (not sweep above AND (rejection AND close < close[N] AND arrival strength ≤ entry limit AND (compression filter disabled OR Compression) AND (extension filter disabled OR not overextended) AND Level is valid OR false break below AND close ≤ close[N]))
Short: active level exists AND not pre-touch AND (sweep above OR (not sweep below AND (rejection AND close > close[N] AND arrival strength ≤ entry limit AND (compression filter disabled OR Compression) AND (extension filter disabled OR not overextended) AND Level is valid OR false break above AND close ≥ close[N])))
Exit: short, close ≤ EMA(close, exit period)
Exit: long, close ≥ EMA(close, exit period)