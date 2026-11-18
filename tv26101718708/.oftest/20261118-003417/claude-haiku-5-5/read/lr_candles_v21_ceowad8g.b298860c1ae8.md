Calculation: price = LinReg(close, LR length, LR offset) if LR candles enabled, else close
Calculation: signal = SMA(price, signal length) if SMA signal enabled, else EMA(price, signal length)
Calculation: vwma = VWMA(close, volume, VWMA length)
Long: vwma crosses above signal
Short: vwma crosses below signal