Calculation: Daily trend = compare the last completed higher-timeframe daily close with daily candles at offsets 2, 1, then 0, using the first candle whose range it is outside; trend is 1 if above that candle’s high, -1 if below its low, and 0 otherwise. Offsets 2 and 1 are completed bars; offset 0 is still forming.
Long: Daily trend = 1 AND last completed lower-timeframe 15-minute close > high of the second-last completed 15-minute bar
Short: Daily trend = -1 AND last completed lower-timeframe 15-minute close < low of the second-last completed 15-minute bar
Exit: long, low <= low of the second-last completed 15-minute bar
Exit: short, high >= high of the second-last completed 15-minute bar