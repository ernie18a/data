Calculation: Net volume = volume when close > previous close, −volume when close < previous close, and 0 when close equals previous close
Long: Net volume crosses above −SMA(volume, lookback) AND datetime is within the configured backtest window
Short: Net volume crosses below SMA(volume, lookback) AND datetime is within the configured backtest window
Exit: long, Net volume crosses above SMA(volume, lookback) AND datetime is within the configured backtest window
Exit: short, Net volume crosses below −SMA(volume, lookback) AND datetime is within the configured backtest window