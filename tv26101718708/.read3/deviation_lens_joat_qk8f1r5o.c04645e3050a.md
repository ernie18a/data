Calculation: ZScore(x, n) = (x - SMA(x, n)) / sample STDEV(x, n)
Calculation: VolumeRatio(n) = volume / SMA(volume, n) if SMA(volume, n) > 0, else 0
Calculation: Projection(z, momentumFactor, horizonBars, predictionBound) = clamp(z + (z - z[1]) * momentumFactor * horizonBars, -predictionBound, predictionBound)
Calculation: MatchSrc(q, scanDepth, minPivotDistance, maxPivotDistance) = src at the most recent of the scanDepth most recent earlier pivots of q whose bar distance to the current pivot is within [minPivotDistance, maxPivotDistance] and where (src at that pivot - src[pivotLength]) * (ZScore(src, zLookback) at that pivot - ZScore(src, zLookback)[pivotLength]) < 0, undefined if q is not confirmed on this bar or no such pivot exists
Long: ZScore(src, zLookback) < 0 AND Projection(ZScore(src, zLookback), momentumFactor, horizonBars, predictionBound) > ZScore(src, zLookback)
Short: ZScore(src, zLookback) > 0 AND Projection(ZScore(src, zLookback), momentumFactor, horizonBars, predictionBound) < ZScore(src, zLookback)
Long: ZScore(src, zLookback) <= -extremeLevel AND VolumeRatio(volumeLookback) < contractionLevel
Short: ZScore(src, zLookback) >= extremeLevel AND VolumeRatio(volumeLookback) < contractionLevel
Long: ZScore(src, zLookback) <= -extremeLevel AND ZScore(src, zLookback)[1] > -extremeLevel
Short: ZScore(src, zLookback) >= extremeLevel AND ZScore(src, zLookback)[1] < extremeLevel
Long: MatchSrc(PivotLow(ZScore(src, zLookback), pivotLength, pivotLength), scanDepth, minPivotDistance, maxPivotDistance) > src[pivotLength]
Long: MatchSrc(PivotLow(ZScore(src, zLookback), pivotLength, pivotLength), scanDepth, minPivotDistance, maxPivotDistance) < src[pivotLength]
Short: MatchSrc(PivotHigh(ZScore(src, zLookback), pivotLength, pivotLength), scanDepth, minPivotDistance, maxPivotDistance) < src[pivotLength]
Short: MatchSrc(PivotHigh(ZScore(src, zLookback), pivotLength, pivotLength), scanDepth, minPivotDistance, maxPivotDistance) > src[pivotLength]
Long: close > close[divergenceLag] AND ZScore(close, priceLookback) < ZScore(close, priceLookback)[divergenceLag]
Short: close < close[divergenceLag] AND ZScore(close, priceLookback) > ZScore(close, priceLookback)[divergenceLag]