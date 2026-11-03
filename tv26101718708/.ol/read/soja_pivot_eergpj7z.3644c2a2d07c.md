Calculation: TP = multiplier × prior completed chart-bar HLC3 − prior completed chart-bar high
Calculation: TP2 = TP + prior completed chart-bar high − prior completed chart-bar low
Calculation: SL = SMA(close, lookback) − multiplier × ATR(lookback)
Long: CMO(close, lookback) > lower threshold AND CMO(close, lookback) < upper threshold AND close > prior completed chart-bar close AND Bollinger Band Width(close, lookback) < threshold AND rolling sum(volume, lookback) > threshold AND lagged OBV > threshold
Exit: Long, close > TP
Exit: Long, close > TP2
Exit: Long, close < SL