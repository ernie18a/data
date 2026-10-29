Calculation: XdinMA = 2 × the moving average of the configured OHLC-derived price using a shorter lookback − the moving average of the same price using a longer lookback; both use the same configured smoothing method. In the higher-timeframe variant, use the higher-timeframe bar containing the current chart time, including while it is still forming.
Calculation: XdinMA change = current XdinMA − previous XdinMA.
Calculation: Standard deviation = population standard deviation of the recent one-bar changes in XdinMA.
Long: XdinMA change > the smaller configured volatility multiplier × Standard deviation
Short: XdinMA change < −(the smaller configured volatility multiplier × Standard deviation)