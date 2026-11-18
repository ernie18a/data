Calculation: lr = linreg(close, LR length, LR offset)
Calculation: signal = SMA(lr, signal length) if use SMA flag is true, otherwise EMA(lr, signal length)
Long: close crosses above signal
Short: close crosses below signal