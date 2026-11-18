Calculation: Stop price = low of the bullish-engulfing entry bar * (1 - stop buffer / 100)
Calculation: Volume target = close of the oldest bar tied for highest volume among the current and prior volume-lookback bars
Long: RSI(close, RSI lookback) < oversold threshold AND close[1] < open[1] AND close > open AND open <= close[1] AND close >= open[1]
Exit: Long, low <= stop price OR high >= max(volume target, entry price + 2 * (entry price - stop price))