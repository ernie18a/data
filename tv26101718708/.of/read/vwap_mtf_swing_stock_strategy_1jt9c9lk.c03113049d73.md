Calculation: Transformed price = sqrt((open² + high² + low² + close²) / 8)
Calculation: Volatility upper band = SMA(Transformed price, lookback) + SMA(high − low, same lookback) × multiplier
Calculation: Volatility lower band = SMA(Transformed price, lookback) − SMA(high − low, same lookback) × multiplier
Long: Transformed price crosses above Volatility upper band AND close > weekly VWAP (higher timeframe, current week still forming) AND datetime is within the configured date range; OR close > chart-timeframe VWAP AND close > weekly VWAP AND datetime is within the configured date range
Short: close < chart-timeframe VWAP AND close < weekly VWAP AND datetime is within the configured date range
Exit: long, Transformed price crosses below Volatility lower band AND close < weekly VWAP (higher timeframe, current week still forming) AND datetime is within the configured date range