Calculation: MACD histogram value = MACD histogram(MACD source parameter, shorter lookback, longer lookback, signal lookback, oscillator average-type parameter, signal average-type parameter)
Calculation: Trend EMA = EMA(EMA source parameter, EMA lookback)
Calculation: VWAP value = VWAP(hlc3, volume)
Calculation: ADX value = ADX(high, low, close, DI lookback, smoothing lookback)
Long: time on chart bars is within entry-session parameter AND close > VWAP value AND close > Trend EMA AND MACD histogram value[1] > 0 AND MACD histogram value > MACD histogram value[1]
Short: time on chart bars is within entry-session parameter AND close < VWAP value AND close < Trend EMA AND MACD histogram value[1] < 0 AND MACD histogram value < MACD histogram value[1]
Long: time on chart bars is within entry-session parameter AND close > VWAP value AND close > Trend EMA AND MACD histogram value[1] > 0 AND MACD histogram value > MACD histogram value[1] AND close > upper Bollinger Band(BB source parameter, BB lookback, deviation parameter) AND ADX value < long-entry ADX threshold parameter
Short: time on chart bars is within entry-session parameter AND close < VWAP value AND close < Trend EMA AND MACD histogram value[1] < 0 AND MACD histogram value < MACD histogram value[1] AND close < lower Bollinger Band(BB source parameter, BB lookback, deviation parameter) AND ADX value > short-entry ADX threshold parameter
Exit: long, crosses below VWAP value
Exit: short, crosses above VWAP value
Exit: long, time on chart bars is outside exit-session parameter
Exit: short, time on chart bars is outside exit-session parameter