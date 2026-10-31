Calculation: Channel boundaries = Apply the SATL digital filter separately to highs and lows, then apply the same Jurik moving average length and phase to each result. Add the same vertical price offset to both and round each to the nearest specified price increment. Use each boundary from a specified number of bars ago.
Long: Close > upper channel boundary AND close >= lower channel boundary
Short: Close < lower channel boundary
Long: Forming higher-timeframe close > upper channel boundary calculated on higher-timeframe bars AND forming higher-timeframe close >= lower channel boundary calculated on higher-timeframe bars
Short: Forming higher-timeframe close < lower channel boundary calculated on higher-timeframe bars