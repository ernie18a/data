Calculation: bullish impulse = close[1] > open[1] AND close[1] - open[1] > (high[1] - low[1]) * body-fraction parameter AND high[1] - low[1] > ATR(ATR lookback) on the current bar
Calculation: bearish impulse = close[1] < open[1] AND open[1] - close[1] > (high[1] - low[1]) * the same body-fraction parameter AND high[1] - low[1] > ATR(the same ATR lookback) on the current bar
Calculation: EMA trend(T) = EMA(close, shorter lookback) > EMA(close, longer lookback) on T bars using the current forming T bar in realtime, sampled on chart bars with lookahead off; the same shorter and longer lookbacks apply to T1, T2, T3, and T4
Long: at least one confirmed external pivot high and low exist AND the latest confirmed external PivotHigh(high, external swing lookback, external swing lookback) is unbroken AND (close > its value when close confirmation is selected OR high > its value when wick confirmation is selected)
Short: at least one confirmed external pivot high and low exist AND the latest confirmed external PivotLow(low, external swing lookback, external swing lookback) is unbroken AND (close < its value when close confirmation is selected OR low < its value when wick confirmation is selected)
Long: at least one confirmed internal pivot high and low exist AND the latest confirmed internal PivotHigh(high, internal swing lookback, internal swing lookback) is unbroken AND (close > its value when close confirmation is selected OR high > its value when wick confirmation is selected)
Short: at least one confirmed internal pivot high and low exist AND the latest confirmed internal PivotLow(low, internal swing lookback, internal swing lookback) is unbroken AND (close < its value when close confirmation is selected OR low < its value when wick confirmation is selected)
Long: the second most recently confirmed external pivot low exists and is unbroken AND low < its value AND close > its value
Short: the second most recently confirmed external pivot high exists and is unbroken AND high > its value AND close < its value
Long: low > high[2] AND bullish impulse AND low - high[2] > ATR(ATR lookback) * minimum FVG size multiplier AND volume > SMA(volume, volume SMA lookback) AND the nearest bearish candle within the OB search-depth parameter exists AND (the sweep-only OB filter is disabled OR that candle's low is below the low one bar earlier)
Short: high < low[2] AND bearish impulse AND low[2] - high > ATR(ATR lookback) * minimum FVG size multiplier AND volume > SMA(volume, volume SMA lookback) AND the nearest bullish candle within the OB search-depth parameter exists AND (the sweep-only OB filter is disabled OR that candle's high is above the high one bar earlier)
Long: close > the top of an un-inverted bearish FVG retained within the maximum active FVG count parameter
Short: close < the bottom of an un-inverted bullish FVG retained within the maximum active FVG count parameter
Long: the current external trend state is bullish, meaning the latest external structure break was bullish
Short: the current external trend state is bearish, meaning no external structure break has occurred or the latest external structure break was bearish
Long: EMA trend(T1) is bullish
Short: EMA trend(T1) is bearish
Long: EMA trend(T2) is bullish
Short: EMA trend(T2) is bearish
Long: EMA trend(T3) is bullish
Short: EMA trend(T3) is bearish
Long: EMA trend(T4) is bullish
Short: EMA trend(T4) is bearish