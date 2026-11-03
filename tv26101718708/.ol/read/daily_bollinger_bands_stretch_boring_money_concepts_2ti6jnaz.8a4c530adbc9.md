Calculation: Higher-timeframe BB basis = moving average of close over a lookback, using the last completed bar
Calculation: Z stretch = (chart close - higher-timeframe BB basis) / standard deviation of higher-timeframe close over the same lookback, using the last completed bar
Calculation: ATR stretch = (chart close - higher-timeframe BB basis) / higher-timeframe average true range, using the last completed bar
Long: Z stretch <= negative Z threshold AND ATR stretch <= negative ATR threshold
Short: Z stretch >= Z threshold AND ATR stretch >= ATR threshold