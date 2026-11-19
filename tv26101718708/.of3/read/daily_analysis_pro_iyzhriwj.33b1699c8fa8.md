Calculation: RSI = selected between Ultimate RSI(source, RSI lookback, smoothing type, smoothing lookback) and RSI(source, RSI lookback) smoothed with selected moving average type over smoothing lookback
Calculation: ATR = ATR(lookback)
Long: RSI crosses above oversold level
Short: RSI crosses below overbought level
Long: low > high[2] AND close[2] < open[2] AND close - open[2] > ATR * move-strength multiplier
Short: high < low[2] AND close[2] > open[2] AND open[2] - close > ATR * move-strength multiplier