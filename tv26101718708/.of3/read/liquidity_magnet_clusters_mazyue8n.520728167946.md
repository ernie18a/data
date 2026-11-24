Calculation: RollingVolumeProfile = Volume Profile(high, low, volume, profile lookback, bin count, value-area percentage, HVN percentile, LVN percentile) on chart bars, including the still-forming bar.
Calculation: ActiveNakedPOCs = RollingVolumeProfile.POC snapshots at each T1 boundary on chart bars; remove a level when it is tested by the configured wick or close-through mode, when its age exceeds the maximum completed T1 periods, or when it is among the oldest levels beyond the separate tracking cap.
Calculation: SweepConfluenceScore(direction) = 1 if the bullish low or bearish high is within the proximity percentage of VAL or VAH, respectively; plus 1 if that extreme is within an HVN zone expanded by close × proximity percentage; plus 2 if it is within the proximity percentage of an active naked POC; plus 1 if the interval from close[pivot length] to that extreme overlaps an LVN zone. Each category contributes at most once; proximity means abs(price − level) / price × 100 <= proximity percentage.
Long: high > the latest unswept confirmed PivotHigh(high, pivot length, pivot length) AND close < that pivot high AND its age <= sweep lookback AND (volume filter disabled OR volume > Median(volume, min(sweep lookback, separate median-volume cap lookback)))
Short: low < the latest unswept confirmed PivotLow(low, pivot length, pivot length) AND close > that pivot low AND its age <= sweep lookback AND (volume filter disabled OR volume > Median(volume, min(sweep lookback, separate median-volume cap lookback)))
Long: bullish sweep AND SweepConfluenceScore(bullish) >= confluence threshold
Short: bearish sweep AND SweepConfluenceScore(bearish) >= confluence threshold
Long: close > RollingVolumeProfile.VAH
Short: close < RollingVolumeProfile.VAL
Long: close > RollingVolumeProfile.VAH AND close[1] <= RollingVolumeProfile.VAH[1]
Short: close < RollingVolumeProfile.VAL AND close[1] >= RollingVolumeProfile.VAL[1]