Calculation: 3-candle fractal high = a bar’s high is greater than the highs of the immediately preceding and following bars; confirmed on the following bar
Calculation: 3-candle fractal low = a bar’s low is lower than the lows of the immediately preceding and following bars; confirmed on the following bar
Calculation: Bullish QM break level = highest high from the latest confirmed 3-candle fractal low through the low-sweep bar
Calculation: Bearish QM break level = lowest low from the latest confirmed 3-candle fractal high through the high-sweep bar
Calculation: Active range high = maximum of the sweep and break levels of the two opposing QMs that form the range
Calculation: Active range low = minimum of the sweep and break levels of the two opposing QMs that form the range
Long: Since the latest confirmed 3-candle fractal low, low < that pivot low and close >= that pivot low, and before the configured setup timeout or invalidation (a close below the pivot low), close > the bullish QM break level OR close > active range high OR low <= the upper bound of an active demand zone created after a bullish range break
Short: Since the latest confirmed 3-candle fractal high, high > that pivot high and close <= that pivot high, and before the configured setup timeout or invalidation (a close above the pivot high), close < the bearish QM break level OR close < active range low OR high >= the lower bound of an active supply zone created after a bearish range break
Exit: none