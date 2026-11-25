Calculation: bullish volume average = MA(volume if close > close[1] else 0, lookback, method)
Calculation: bearish volume average = MA(volume if close <= close[1] else 0, same lookback and method)
Long: bullish volume average > 0
Short: bearish volume average > 0