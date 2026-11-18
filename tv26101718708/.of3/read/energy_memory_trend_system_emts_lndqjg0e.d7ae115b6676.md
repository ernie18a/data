Calculation: DME = EMA(sqrt(ATR(high, low, close, ATR lookback)) * log(volume + 1) * ROC(close, ROC lookback), smoothing lookback)
Calculation: DME memory trend = 1 when DME > upper Bollinger Band(DME, band lookback, multiplier), -1 when DME < lower Bollinger Band(DME, band lookback, multiplier), otherwise its previous value, initially 0
Long: DME memory trend = 1
Short: DME memory trend = -1
Long: DME memory trend = 1 AND prior DME memory trend != 1
Short: DME memory trend = -1 AND prior DME memory trend != -1