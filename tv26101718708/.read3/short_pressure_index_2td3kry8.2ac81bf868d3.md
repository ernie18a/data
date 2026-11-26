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
Calculation: Short-pressure index = EMA((short-sale-volume pressure + normalized ATR-scaled moving-average deviation + percentage of down bars) / 3, smoothing length), where short-sale-volume pressure is 100 × reported short-sale volume on T1 / total traded volume on T1, clamped to 0–100, when enabled and available for stocks or funds; otherwise it is 100 × rolling qualifying down-bar volume / rolling qualifying up- and down-bar volume, or 50 when that denominator is zero. A bar qualifies when its volume is at least its average volume × either of two separate multipliers. Normalized ATR-scaled moving-average deviation is the rolling min-max normalization to 0–100 of (selected moving average of close − close) / ATR, or 50 when the rolling maximum equals the minimum. Percentage of down bars is 100 × down bars / bars in the lookback. Use separate parameters for the moving-average type and length, ATR length, normalization window, smoothing length, volume-average length, each volume multiplier, volume roll length, and down-bar lookback.
Short: short-pressure index crosses above the high-pressure threshold
Long: short-pressure index crosses below the high-pressure threshold
Long: short-pressure index crosses below the low-pressure threshold
Short: short-pressure index crosses above its EMA signal line
Long: short-pressure index crosses below its EMA signal line