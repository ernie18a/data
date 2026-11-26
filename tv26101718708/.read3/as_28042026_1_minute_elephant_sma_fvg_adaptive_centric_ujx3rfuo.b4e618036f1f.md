Calculation: elephant bar = high - low > ATR(ATR lookback) * range multiplier AND (high - low > 0 ? abs(close - open) / (high - low) : 0) > minimum body fraction
Long: elephant bar AND close > open
Short: elephant bar AND close < open
Long: low > high[2]
Short: high < low[2]
Long: crosses above EMA(source, lookback, T1 bar still forming), sampled on chart bars
Short: crosses below EMA(source, lookback, T1 bar still forming), sampled on chart bars
Long: close > SMA(close, shortest lookback)
Short: close <= SMA(close, shortest lookback)
Long: SMA(close, intermediate lookback) > SMA(close, intermediate lookback)[1]
Short: SMA(close, intermediate lookback) <= SMA(close, intermediate lookback)[1]
Calculation: distance from long SMA = abs(close - SMA(close, longer lookback)) / SMA(close, longer lookback)
Long: SMA(close, intermediate lookback) > SMA(close, longer lookback) AND distance from long SMA >= distance threshold
Short: SMA(close, intermediate lookback) < SMA(close, longer lookback) AND distance from long SMA >= distance threshold
Calculation: adaptive centric MA = previous + ((((abs(Stochastic(SMA(source, lookback), Highest(SMA(high, lookback), lookback), Lowest(SMA(low, lookback), lookback), lookback) - 50) / 100) / attenuation) ^ power) * (midpoint + (SMA(source, lookback) - midpoint) / attenuation - previous), where midpoint = (Highest(SMA(high, lookback), lookback) + Lowest(SMA(low, lookback), lookback)) / 2 and previous is the prior adaptive centric MA, or 0 initially
Long: SMA(source, lookback) > adaptive centric MA
Short: SMA(source, lookback) <= adaptive centric MA