Calculation: Compression = Bollinger Bands(close, BB lookback, BB multiplier) are strictly inside Keltner Channels(SMA(close, KC lookback), SMA(true range, KC lookback), KC multiplier) on T1 bars
Calculation: CompressionDuration = consecutive number of T1 bars ending on the current bar where Compression is true, or 0 otherwise
Calculation: NormalizedMomentum = LinearRegression(close - Average(Average(Highest(high, KC lookback), Lowest(low, KC lookback)), SMA(close, KC lookback)), KC lookback, offset 0) / close * 100 on T1 bars
Long: Compression AND CompressionDuration[1] >= minimum squeeze duration AND close > EMA(close, trend EMA lookback)
Long: Compression AND CompressionDuration = minimum squeeze duration
Long: Compression AND NormalizedMomentum crosses above 0 AND close > EMA(close, trend EMA lookback)
Long: (Compression[1] AND NOT Compression) OR (Compression[2] AND NOT Compression[1]) AND CompressionDuration[1] >= minimum squeeze duration AND NormalizedMomentum > 0 AND NormalizedMomentum > NormalizedMomentum[1] AND close > EMA(close, trend EMA lookback) AND volume > SMA(volume, volume-average lookback) * volume surge multiplier