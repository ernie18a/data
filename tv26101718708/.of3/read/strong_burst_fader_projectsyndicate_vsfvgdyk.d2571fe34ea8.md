Calculation: Upper band = selected EMA, SMA, HMA, WMA, VWMA, or RMA(source, basis lookback) + band width × ATR(ATR lookback)
Calculation: Lower band = selected EMA, SMA, HMA, WMA, VWMA, or RMA(source, basis lookback) − band width × ATR(ATR lookback)
Calculation: Up burst magnitude = (high − upper band) / ATR(ATR lookback) when ATR(ATR lookback) > 0, high > upper band, and close > upper band if closing bursts are required; otherwise 0
Calculation: Down burst magnitude = (lower band − low) / ATR(ATR lookback) when ATR(ATR lookback) > 0, low < lower band, and close < lower band if closing bursts are required; otherwise 0
Calculation: Up burst peak = Up burst magnitude[1] > 0 AND Up burst magnitude[1] >= Up burst magnitude[2] AND Up burst magnitude[1] > Up burst magnitude AND (bar-close confirmation is disabled OR the current bar is confirmed)
Calculation: Down burst peak = Down burst magnitude[1] > 0 AND Down burst magnitude[1] >= Down burst magnitude[2] AND Down burst magnitude[1] > Down burst magnitude AND (bar-close confirmation is disabled OR the current bar is confirmed)
Calculation: Up peak stack height = min(maximum stack height, 1 + floor(Up burst magnitude[1] / ATR per stack step))
Calculation: Down peak stack height = min(maximum stack height, 1 + floor(Down burst magnitude[1] / ATR per stack step))
Short: Up burst peak
Short: Up burst peak AND Up peak stack height >= minimum fade stack height
Long: Down burst peak
Long: Down burst peak AND Down peak stack height >= minimum fade stack height