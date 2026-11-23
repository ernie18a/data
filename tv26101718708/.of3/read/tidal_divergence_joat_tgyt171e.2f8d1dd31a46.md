Calculation: CVD = running sum of signed volume, where signed volume is volume if close > open, minus volume if close < open, and 0 otherwise, restarted with the current signed volume on the first chart bar of each T1 bar; evaluated on chart bars that take values from T1 (still-forming T1 bar)
Calculation: Blend = min(100, max(-100, 100 * HMA(MFI weight * (MFI(close, MFI lookback) - 50) / 50 + CVD weight * (PercentRank(CVD, percent-rank lookback) - 50) / 50 + OBV weight * min(1, max(-1, (ROC(OBV, ROC lookback) - SMA(ROC(OBV, ROC lookback), z-score lookback)) / max(STDEV(ROC(OBV, ROC lookback), z-score lookback), tiny constant) / z-score scale)), HMA lookback)))
Calculation: Bull zone = band between edge and base, created on each bar where a regular or hidden bull divergence fires, with edge = Lowest(low, zone extreme length) and base = Lowest(min(open, close), zone extreme length), both evaluated at the pivot bar (pivot right lookback bars before creation) and fixed thereafter
Calculation: Bear zone = band between edge and base, created on each bar where a regular or hidden bear divergence fires, with edge = Highest(high, zone extreme length) and base = Highest(max(open, close), zone extreme length), both evaluated at the pivot bar (pivot right lookback bars before creation) and fixed thereafter
Long: PivotLow(Blend, pivot left lookback, pivot right lookback) confirmed on this bar AND low at pivot bar < low at previous PivotLow AND Blend at pivot bar > Blend at previous PivotLow AND bars since previous PivotLow within minimum and maximum pivot spacing AND (FVG confluence switch off OR low > high[2] on any of last FVG lookback bars)
Long: PivotLow(Blend, pivot left lookback, pivot right lookback) confirmed on this bar AND low at pivot bar > low at previous PivotLow AND Blend at pivot bar < Blend at previous PivotLow AND bars since previous PivotLow within minimum and maximum pivot spacing AND hidden detection switch on AND (FVG confluence switch off OR low > high[2] on any of last FVG lookback bars)
Short: PivotHigh(Blend, pivot left lookback, pivot right lookback) confirmed on this bar AND high at pivot bar > high at previous PivotHigh AND Blend at pivot bar < Blend at previous PivotHigh AND bars since previous PivotHigh within minimum and maximum pivot spacing AND (FVG confluence switch off OR high < low[2] on any of last FVG lookback bars)
Short: PivotHigh(Blend, pivot left lookback, pivot right lookback) confirmed on this bar AND high at pivot bar < high at previous PivotHigh AND Blend at pivot bar > Blend at previous PivotHigh AND bars since previous PivotHigh within minimum and maximum pivot spacing AND hidden detection switch on AND (FVG confluence switch off OR high < low[2] on any of last FVG lookback bars)
Long: close > open AND bar range overlaps the edge-to-base band of any existing bull zone not removed on this bar
Short: close < open AND bar range overlaps the edge-to-base band of any existing bear zone not removed on this bar
Short: any existing bull zone satisfies (body mode AND close below its edge AND (rejection switch off OR previous close below its edge)) OR (wick mode AND low below its edge) OR (bars since its pivot bar > max zone age)
Long: any existing bear zone satisfies (body mode AND close above its edge AND (rejection switch off OR previous close above its edge)) OR (wick mode AND high above its edge) OR (bars since its pivot bar > max zone age)
Long: number of existing bull zones after removals on this bar >= stack size AND regular bull divergence fires on this bar
Short: number of existing bear zones after removals on this bar >= stack size AND regular bear divergence fires on this bar
Long: Blend > 0 on each of the last streak length bars AND Blend[streak length] <= 0
Short: Blend < 0 on each of the last streak length bars AND Blend[streak length] >= 0
Long: Blend > tint threshold
Short: Blend < minus tint threshold
Long: Blend >= EMA(Blend, signal lookback)
Short: Blend < EMA(Blend, signal lookback)
Long: Blend >= 0
Short: Blend < 0