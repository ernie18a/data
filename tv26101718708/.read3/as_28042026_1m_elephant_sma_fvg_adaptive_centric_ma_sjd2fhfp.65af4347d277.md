Calculation: elephant bar = high - low > ATR(ATR lookback) * range multiplier AND (high - low > 0 ? abs(close - open) / (high - low) : 0) > minimum body fraction
Long: elephant bar AND close > open
Short: elephant bar AND close < open
Long: close > SMA(close, bar-color lookback) AND NOT (elephant bar AND close != open)
Short: close <= SMA(close, bar-color lookback) AND NOT (elephant bar AND close != open)
Long: SMA(close, trend lookback) > SMA(close, trend lookback)[1]
Short: SMA(close, trend lookback) <= SMA(close, trend lookback)[1]
Calculation: SMA distance ratio = abs(close - SMA(close, longer trend lookback)) / SMA(close, longer trend lookback)
Long: SMA(close, shorter trend lookback) > SMA(close, longer trend lookback) AND SMA distance ratio >= range threshold
Short: SMA(close, shorter trend lookback) < SMA(close, longer trend lookback) AND SMA distance ratio >= range threshold
Long: low > high[2]
Short: high < low[2]
Long: close crosses above EMA(source, lookback, T1, bar still forming, sampled on chart bars)
Short: close crosses below EMA(source, lookback, T1, bar still forming, sampled on chart bars)
Long: confirmed Pivot Low(low, pivot lookback, pivot lookback) on chart bars
Short: confirmed Pivot High(high, pivot lookback, pivot lookback) on chart bars
Calculation: adaptive average(source, lookback, attenuation, power) = nz(previous adaptive average, 0) + (((abs(Stochastic(SMA(source, lookback), Highest(SMA(high, lookback), lookback), Lowest(SMA(low, lookback), lookback), lookback) - 50) / 100) / attenuation) ^ power) * ((Highest(SMA(high, lookback), lookback) + Lowest(SMA(low, lookback), lookback)) / 2 + (SMA(source, lookback) - (Highest(SMA(high, lookback), lookback) + Lowest(SMA(low, lookback), lookback)) / 2) / attenuation - nz(previous adaptive average, 0))
Long: SMA(source, lookback) > adaptive average(source, lookback, attenuation, power)
Short: SMA(source, lookback) <= adaptive average(source, lookback, attenuation, power)