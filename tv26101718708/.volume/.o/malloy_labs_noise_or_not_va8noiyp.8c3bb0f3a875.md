Calculation: Flow = cumulative sum of volume when close >= open, otherwise negative volume.
Calculation: Normalized deviation = for a source, let raw deviation = source − SMA(source, shorter lookback); subtract the longer-lookback SMA of raw deviation and divide by its longer-lookback standard deviation. Use the same lookback pair for all sources.
Calculation: Edge = normalized deviation of Flow − normalized deviation of close − normalized deviation of the crowd ticker’s close when crowd positioning is enabled and the ticker is valid; otherwise omit the crowd term. Use bars from the chart timeframe; the crowd ticker uses bars from that same timeframe.
Long: Edge > threshold
Short: Edge < −threshold