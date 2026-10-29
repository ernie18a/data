Calculation: Synthetic Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Volume volatility = square root of the EWMA of squared logarithmic period-over-period volume returns
Calculation: High volatility = volume volatility > its moving average + a standard-deviation multiple of volume volatility
Long: Fast EMA of synthetic Heikin-Ashi close crossed above the longer-term Slow EMA on the previous completed chart bar AND High volatility was true on that bar
Short: Fast EMA of synthetic Heikin-Ashi close crossed below the longer-term Slow EMA on the previous completed chart bar AND High volatility was true on that bar