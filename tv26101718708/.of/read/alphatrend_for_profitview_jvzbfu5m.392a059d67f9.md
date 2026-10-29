Calculation: ATR = simple moving average of true range
Calculation: AlphaTrend = if RSI(close) ≥ 50 when no-volume mode is enabled, otherwise MFI(hlc3) ≥ 50: max(low − ATR × multiplier, previous AlphaTrend); otherwise min(high + ATR × multiplier, previous AlphaTrend)
Long: AlphaTrend crosses above its value 2 bars earlier AND position is flat or short AND datetime is within the configured backtest window
Short: AlphaTrend crosses below its value 2 bars earlier AND position is flat or long AND shorting is enabled AND datetime is within the configured backtest window
Exit: long, AlphaTrend crosses below its value 2 bars earlier AND shorting is disabled AND datetime is within the configured backtest window