Calculation: RVOL = volume / SMA(volume, rolling length) if RVOL method is rolling; otherwise volume / average of the volume at the same offset within each earlier T2 bar, where offset is bars since the first chart bar of the T2 bar containing the current bar (still forming), zero volumes excluded
Calculation: PivotHigh = pivothigh(pivot source, pivot length, confirmation length)
Calculation: PivotLow = pivotlow(pivot source, pivot length, confirmation length)
Calculation: LastPivotHigh = most recent non-NA PivotHigh before the current bar, NA if none
Calculation: LastPivotLow = most recent non-NA PivotLow before the current bar, NA if none
Calculation: PivotPrice = if pivot source is LTF, volume-weighted average of HLC3 over the T1 bars inside the completed pivot bar (HLC3 of that chart bar if those T1 bars have zero total volume); otherwise the confirmed PivotHigh or PivotLow value
Calculation: Pool = the most recent pool size validated pivots, oldest dropped beyond that size; a pivot is validated when RVOL at its pivot bar >= RVOL threshold; each entry keeps PivotPrice, RVOL and pivot bar; each bar, entries are removed when bars since pivot bar > staleness bars AND abs(close - PivotPrice) > ATR(atr length) * staleness distance multiplier
Calculation: Zones = rebuilt on each bar where Pool changes: entries are visited oldest to newest, each joins the zone with the nearest centroid if that distance is less than ATR(atr length) * cluster multiplier (ATR of that bar), otherwise starts a new zone; zone centroid = RVOL-weighted running average of member PivotPrice
Calculation: ResistanceLevel = lowest Zones centroid above close with abs(centroid - close) <= ATR(atr length) * activation multiplier, NA if none
Calculation: SupportLevel = highest Zones centroid below close with abs(centroid - close) <= ATR(atr length) * activation multiplier, NA if none
Calculation: ClosestLevel = SupportLevel if SupportLevel is not NA and (ResistanceLevel is NA or close - SupportLevel <= ResistanceLevel - close); otherwise ResistanceLevel
Calculation: Density(level) = [above, below], where R = ATR(atr length) * radius multiplier and the bins are density bins equal bins spanning [level - R, level + R]; over the last density lookback bars, the bar k bars back (k = 0 is current) has weight decay factor^k and its volume times weight is split evenly across the bins its low-to-high range overlaps; each bin total is divided by the largest bin total; above = mean of normalized totals over bins with index greater than floor(density bins / 2), below = mean over bins with index less than floor(density bins / 2); NA if level is NA or the largest bin total is 0
Calculation: DensityBias = if Density(ResistanceLevel) and Density(SupportLevel) are both not NA: Density(SupportLevel).below - Density(ResistanceLevel).above; else if Density(SupportLevel) is not NA: Density(SupportLevel).below - Density(SupportLevel).above; else if Density(ResistanceLevel) is not NA: Density(ResistanceLevel).below - Density(ResistanceLevel).above; else NA
Calculation: Slope = NA if reaction metrics are disabled; otherwise (LinReg(close, slope length, 0) - LinReg(close, slope length, 1)) / ATR(atr length) if slope method is LinReg, else (close - ClosestLevel) / ATR(atr length)
Calculation: Accel = EMA(Slope - nz(Slope[1]), acceleration smoothing length)
Calculation: Rejection = (close - low) / (high - low), or 0.5 if high equals low, when reaction metrics and rejection quality are enabled and abs(close - ClosestLevel) <= ATR(atr length) * activation multiplier * rejection proximity multiplier; otherwise NA
Calculation: CompositeScore = SMA(Blend, composite smoothing length), where Blend = (density weight * clamp(nz(DensityBias)) + slope weight * clamp(nz(Slope)) + acceleration weight * clamp(nz(Accel) * acceleration scale) + rejection weight * nz((Rejection - 0.5) * 2)) / (density weight + slope weight + acceleration weight + rejection weight), and clamp(x) = min(1, max(-1, x))
Calculation: StructureBias = on each bar where PivotHigh or PivotLow is confirmed, neutral if fewer than two PivotHigh or fewer than two PivotLow values exist, else bullish if the latest PivotHigh > the previous PivotHigh AND the latest PivotLow > the previous PivotLow, bearish if the latest PivotHigh < the previous PivotHigh AND the latest PivotLow < the previous PivotLow, otherwise neutral; on other bars it carries forward, except that it becomes neutral, and stays neutral until the next such confirmation, when bars since the latest pivot bar (either type) > structure staleness length, or when price override is enabled and (bullish and close < latest PivotLow, or bearish and close > latest PivotHigh)
Calculation: FVGPercentile = value at index floor(0.75 * n) of the ascending sort of the most recent FVG lookback gap sizes, where n is the number stored and the value is 0 when n < 10; a bar stores its gap size as low - high[2] if that is positive, else low[2] - high if that is positive, and stores nothing if neither is positive
Calculation: AnchoredVWAP = volume-weighted average of HLC3 from the latest pivot confirmation through the current bar
Long: PivotHigh is not NA AND RVOL[confirmation length] >= RVOL threshold AND (LastPivotHigh is NA OR PivotHigh > LastPivotHigh)
Long: PivotLow is not NA AND RVOL[confirmation length] >= RVOL threshold AND LastPivotLow is not NA AND PivotLow > LastPivotLow
Short: PivotHigh is not NA AND RVOL[confirmation length] >= RVOL threshold AND LastPivotHigh is not NA AND PivotHigh <= LastPivotHigh
Short: PivotLow is not NA AND RVOL[confirmation length] >= RVOL threshold AND (LastPivotLow is NA OR PivotLow <= LastPivotLow)
Long: StructureBias = bullish
Short: StructureBias = bearish
Long: DensityBias >= density neutral threshold
Short: DensityBias <= -density neutral threshold
Long: CompositeScore > composite neutral threshold
Long: CompositeScore >= composite neutral threshold
Short: CompositeScore < -composite neutral threshold
Short: CompositeScore <= -composite neutral threshold
Long: (low - high[2]) >= FVGPercentile AND FVGPercentile > 0
Short: (low[2] - high) >= FVGPercentile AND FVGPercentile > 0
Long: AnchoredVWAP > nz(AnchoredVWAP[1])
Short: AnchoredVWAP < nz(AnchoredVWAP[1])