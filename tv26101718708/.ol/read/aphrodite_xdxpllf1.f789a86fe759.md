Calculation: Normal-distribution pseudo-random value = Box–Muller transform of two seeded pseudo-random values, using the moving average of OHLC4 as its mean and the standard deviation of OHLC4 as its deviation; both use the same lookback.
Calculation: Scaled-price prime flags = For each OHLC price, apply a price-range-dependent scale factor; its flag is clear if the scaled value is at most 1 or is not exactly divisible by any integer from 2 through 9.
Long: Absolute normal-distribution pseudo-random value <= high OR absolute normal-distribution pseudo-random value < low AND the configured month and day match
Short: Absolute normal-distribution pseudo-random value > high
Exit: Long, open, high, low, and close scaled-price prime flags are all clear