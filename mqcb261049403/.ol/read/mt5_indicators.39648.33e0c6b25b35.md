Calculation: Volatility = moving average of close using the volatility lookback and method minus moving average of median price using the zone lookback and method
Calculation: Smoothed directional volume = moving average of signed volume, where volume is positive when close > open, negative when close < open, and zero when close = open; use the volume lookback and method
Long: Volatility > 0 OR Volatility > its value on the previous bar OR Smoothed directional volume > 0
Short: Volatility < 0 OR Volatility < its value on the previous bar OR Smoothed directional volume < 0