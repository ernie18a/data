Calculation: MS = EMA(close - previous close, N) / EMA(volume, N), on chart timeframe
Calculation: MACD = EMA(MS, short lookback) - EMA(MS, longer lookback)
Calculation: Signal = EMA(MACD, signal lookback)
Long: MACD crosses above Signal (equivalently MACD - Signal crosses above 0)
Short: MACD crosses below Signal (equivalently MACD - Signal crosses below 0)
Exit: long, MACD crosses below 0