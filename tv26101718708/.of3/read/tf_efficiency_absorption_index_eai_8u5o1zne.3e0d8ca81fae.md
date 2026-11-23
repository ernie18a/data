Calculation: net progress = (close - close[1]) / ATR(ATR length)[1]
Calculation: raw relative volume = volume / MEDIAN(volume[1], relative volume lookback) when volume > 0 and that median > 0, otherwise NA
Calculation: directional efficiency = EMA(net progress / SQRT(MAX(relative volume floor, MIN(relative volume cap, raw relative volume))), smoothing length)
Calculation: prior approach = (close[1] - close[approach lookback + 1]) / ATR(ATR length)[1]
Calculation: context span = HIGHEST(high[1], context lookback) - LOWEST(low[1], context lookback)
Calculation: rejection bias = wick weight * ((MIN(open, close) - low) - (high - MAX(open, close))) / (high - low) + CLV weight * CLV(high, low, close)
Calculation: high-participation limited-progress state = raw relative volume >= minimum relative volume AND ABS(net progress) <= maximum net progress AND (high - low) / ATR(ATR length)[1] >= minimum bar range
Calculation: bullish absorption state = high-participation limited-progress state AND prior approach < -minimum prior approach AND (low - LOWEST(low[1], context lookback)) / context span <= 1 - required range-edge location AND rejection bias > minimum rejection bias
Calculation: bearish absorption state = high-participation limited-progress state AND prior approach > minimum prior approach AND (high - LOWEST(low[1], context lookback)) / context span >= required range-edge location AND rejection bias < -minimum rejection bias
Long: bullish absorption state
Long: bullish absorption state AND (no earlier bullish marker OR bars since the last bullish marker > cooldown bars)
Short: bearish absorption state
Short: bearish absorption state AND (no earlier bearish marker OR bars since the last bearish marker > cooldown bars)
Long: directional efficiency > 0 AND NOT bearish absorption state
Short: directional efficiency < 0 AND NOT bullish absorption state
Long: directional efficiency > Bollinger upper band(directional efficiency[1], band lookback, band multiplier) AND NOT high-participation limited-progress state
Short: directional efficiency < Bollinger lower band(directional efficiency[1], band lookback, band multiplier) AND NOT high-participation limited-progress state