Calculation: Cumulative up-candle volume = CUM(if close > open then volume else if close = open then volume / 2 else 0)
Calculation: Cumulative down-candle volume = CUM(if close < open then volume else if close = open then volume / 2 else 0)
Long: Cumulative up-candle volume + Cumulative down-candle volume > 0 AND Cumulative up-candle volume > Cumulative down-candle volume
Short: Cumulative up-candle volume + Cumulative down-candle volume > 0 AND Cumulative up-candle volume <= Cumulative down-candle volume