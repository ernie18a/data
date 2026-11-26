Calculation: ShortestTf = shortest of T1, T2, T3, T4
Calculation: BlendedRsi = RMA(RMA((w1 * RSI(close, RSI length, T1, last completed bar) + w2 * RSI(close, RSI length, T2, last completed bar) + w3 * RSI(close, RSI length, T3, last completed bar) + w4 * RSI(close, RSI length, T4, last completed bar)) / (w1 + w2 + w3 + w4), combined smoothing length), extra smoothing length)
Calculation: LookbackBars = clamp(int(lookback days * seconds per day / duration in seconds of ShortestTf), min lookback bars, max lookback bars)
Calculation: Percentile = RMA(PercentRank(BlendedRsi, LookbackBars), percentile smoothing length)
Calculation: FeatureScore = percentile weight * Percentile + percentile slope weight * abs(Percentile - Percentile[slope length]) + compression weight * STDEV(BlendedRsi, compression length) + midline distance weight * abs(BlendedRsi - RSI midline) + percentile volatility weight * STDEV(Percentile, compression length)
Calculation: SortedCentroids = ascending centroids of k-means with 3 clusters over the last cluster window values of FeatureScore, including current bar; initial centroids are window minimum, midpoint of window minimum and maximum, and window maximum; repeat cluster iterations times: assign each value to its nearest centroid, then set each centroid to the mean of its members (unchanged if none)
Calculation: ClusterIndex = 1 if fewer than minimum window size FeatureScore values are in the cluster window; otherwise 0 if FeatureScore is nearest the lowest of SortedCentroids, 1 if nearest the middle of SortedCentroids, else 2
Calculation: LowerLevel = clamp(lower threshold + cluster influence * S, min lower level, max lower level), where S = minus low-cluster shift if ClusterIndex = 0; high-cluster shift if ClusterIndex = 2; 0 otherwise
Calculation: UpperLevel = clamp(upper threshold + cluster influence * S, min upper level, max upper level), where S = low-cluster shift if ClusterIndex = 0; minus high-cluster shift if ClusterIndex = 2; 0 otherwise
Calculation: LongState = Percentile <= LowerLevel AND BlendedRsi > BlendedRsi[slope length]
Calculation: ShortState = Percentile >= UpperLevel AND BlendedRsi < BlendedRsi[slope length]
Calculation: AdxAboveThreshold = ADX(ADX length, ShortestTf, last completed bar) > ADX threshold
Long: (NOT confirm setups on bar close OR current bar is closed) AND LongState AND (NOT require ADX for setups OR AdxAboveThreshold) AND NOT (LongState AND (NOT require ADX for setups OR AdxAboveThreshold))[1]
Long: LongState
Long: LongState AND AdxAboveThreshold
Short: (NOT confirm setups on bar close OR current bar is closed) AND ShortState AND (NOT require ADX for setups OR AdxAboveThreshold) AND NOT (ShortState AND (NOT require ADX for setups OR AdxAboveThreshold))[1]
Short: ShortState
Short: ShortState AND AdxAboveThreshold