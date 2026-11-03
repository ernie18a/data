Long: chart close > 200-period EMA of the higher-timeframe weekly bars (use the last completed bar) AND higher-timeframe daily close (use the last completed bar) > 200-period EMA of the higher-timeframe daily bars (use the last completed bar) AND ADX > threshold AND low <= 21-period EMA AND close > 21-period EMA
Short: chart close < 200-period EMA of the higher-timeframe weekly bars (use the last completed bar) AND higher-timeframe daily close (use the last completed bar) < 200-period EMA of the higher-timeframe daily bars (use the last completed bar) AND ADX > threshold AND high >= 21-period EMA AND close < 21-period EMA
Calculation: Stop distance = current-timeframe ATR × stop multiplier
Calculation: Second target distance = stop distance × second-target risk/reward multiplier
Exit: Long, low <= entry price − stop distance OR high >= entry price + second target distance
Exit: Short, high >= entry price + stop distance OR low <= entry price − second target distance