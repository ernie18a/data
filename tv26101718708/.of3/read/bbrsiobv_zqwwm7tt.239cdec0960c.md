Long: close > SMA(close, band lookback) AND RSI(close, RSI lookback) > RSI threshold AND OBV(close, volume) > OBV(close, volume)[1]
Short: close < SMA(close, band lookback) AND RSI(close, RSI lookback) < RSI threshold AND OBV(close, volume) < OBV(close, volume)[1]
Exit: long, close < SMA(close, band lookback) - band multiplier * standard deviation(close, band lookback)
Exit: short, close > SMA(close, band lookback) + band multiplier * standard deviation(close, band lookback)