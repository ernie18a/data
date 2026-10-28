Calculation: Short volume-weighted price = EMA(close × volume, shorter lookback) / EMA(volume, shorter lookback)
Calculation: Long volume-weighted price = EMA(close × volume, longer lookback) / EMA(volume, longer lookback)
Calculation: Volume-weighted MACD = short volume-weighted price − long volume-weighted price
Calculation: Signal = EMA(volume-weighted MACD, smoothing lookback)
Long: datetime >= configured start and datetime <= configured end AND volume-weighted MACD crosses above Signal
Short: datetime >= configured start and datetime <= configured end AND volume-weighted MACD crosses below Signal
Exit: long, datetime >= configured start and datetime <= configured end AND volume-weighted MACD crosses below Signal
Exit: short, datetime >= configured start and datetime <= configured end AND volume-weighted MACD crosses above Signal