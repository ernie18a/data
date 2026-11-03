Calculation: volume-weighted MACD = EMA(close × volume, shorter lookback) / EMA(volume, shorter lookback) − EMA(close × volume, longer lookback) / EMA(volume, longer lookback)
Calculation: signal = EMA(volume-weighted MACD, smoothing lookback)
Long: datetime is within the configured backtest window AND volume-weighted MACD crosses above signal
Short: datetime is within the configured backtest window AND volume-weighted MACD crosses below signal
Exit: long, datetime is within the configured backtest window AND volume-weighted MACD crosses below signal
Exit: short, datetime is within the configured backtest window AND volume-weighted MACD crosses above signal