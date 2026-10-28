Calculation: SSL high boundary = selected moving average of high; SSL low boundary = same selected moving average of low, using the same lookback and method
Calculation: RSI = relative strength index of close
Calculation: DMI = plus DI, minus DI, and ADX from directional movement
Calculation: ATR = average true range
Calculation: normalized channel width = absolute difference between SSL boundaries / ATR
Long: completed bar changes SSL state from bearish to bullish OR (completed bar changes SSL state from bearish to bullish AND RSI > 50 AND ADX > threshold AND +DI > -DI AND normalized channel width ≥ threshold AND (higher-timeframe confirmation disabled OR last completed higher-timeframe SSL state is bullish) AND buy quality score ≥ threshold)
Short: completed bar changes SSL state from bullish to bearish OR (completed bar changes SSL state from bullish to bearish AND RSI < 50 AND ADX > threshold AND -DI > +DI AND normalized channel width ≥ threshold AND (higher-timeframe confirmation disabled OR last completed higher-timeframe SSL state is bearish) AND sell quality score ≥ threshold)