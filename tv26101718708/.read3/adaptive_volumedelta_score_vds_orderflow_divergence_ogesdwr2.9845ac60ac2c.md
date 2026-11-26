Calculation: WickDelta = (close - open) / max(high - low, minimum tick) * volume
Calculation: BarsPerT1 = floor(T1 seconds / chart timeframe seconds)
Calculation: DeltaSum = if chart timeframe < T1 then sum of WickDelta over the last BarsPerT1 chart bars including the current bar else sum of WickDelta computed on T2 bars within the current chart bar
Calculation: VolumeRank = if chart timeframe < T1 then PercentRank(sum of volume over the last BarsPerT1 chart bars including the current bar, lookback * BarsPerT1) else PercentRank(volume, lookback)
Calculation: DeltaRank = sign(DeltaSum) * PercentRank(abs(DeltaSum), lookback)
Calculation: OpenRef = if chart timeframe < T1 then open[BarsPerT1] else open
Long: VolumeRank > volume threshold AND DeltaRank > dominance threshold
Short: VolumeRank > volume threshold AND DeltaRank < -dominance threshold
Long: VolumeRank > volume threshold AND DeltaRank > 0 AND OpenRef >= close
Short: VolumeRank > volume threshold AND DeltaRank < 0 AND OpenRef < close