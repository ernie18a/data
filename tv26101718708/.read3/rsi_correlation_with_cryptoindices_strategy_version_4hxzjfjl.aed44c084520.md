Calculation: relative = RSI(selected index close from T1's last completed bar, lookback), calculated on chart bars using T1 values / RSI(close, lookback)
Long: relative crosses above threshold AND datetime is within the configured backtest period
Short: relative crosses below threshold AND datetime is within the configured backtest period
Calculation: RSI ratio = RSI(selected crypto index prior close on T1, RSI-length parameter) / RSI(traded instrument close, RSI-length parameter)
Long: RSI ratio crosses over comparison-threshold parameter AND time is within the configured test period
Short: RSI ratio crosses under comparison-threshold parameter AND time is within the configured test period