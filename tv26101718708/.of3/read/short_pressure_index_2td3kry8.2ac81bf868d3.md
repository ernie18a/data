Calculation: VolumePressure = if RollingSum(volume where (volume >= SMA(volume, volume-average lookback) * climax multiplier OR volume >= SMA(volume, volume-average lookback) * above-average multiplier), volume-pressure lookback) > 0, then 100 * RollingSum(volume where (volume >= SMA(volume, volume-average lookback) * climax multiplier OR volume >= SMA(volume, volume-average lookback) * above-average multiplier) AND close < open, volume-pressure lookback) / RollingSum(volume where (volume >= SMA(volume, volume-average lookback) * climax multiplier OR volume >= SMA(volume, volume-average lookback) * above-average multiplier), volume-pressure lookback); otherwise 50
Calculation: Normalize(value, lookback) = if Highest(value, lookback) != Lowest(value, lookback), then clamp(100 * (value - Lowest(value, lookback)) / (Highest(value, lookback) - Lowest(value, lookback)), 0, 100); otherwise 50
Calculation: MADeviationPressure = Normalize(if ATR(ATR lookback) > 0, then (MA(close, MA lookback, MA type) - close) / ATR(ATR lookback), otherwise 0, normalization lookback)
Calculation: BearishMomentumPressure = 100 * count(close < open over momentum lookback) / momentum lookback
Calculation: SPI = EMA((VolumePressure + MADeviationPressure + BearishMomentumPressure) / 3, SPI smoothing lookback)
Calculation: Signal = EMA(SPI, signal lookback)
Short: SPI crosses above high-pressure threshold
Long: SPI crosses below high-pressure threshold
Long: SPI crosses below low-pressure threshold
Short: SPI crosses above Signal
Long: SPI crosses below Signal