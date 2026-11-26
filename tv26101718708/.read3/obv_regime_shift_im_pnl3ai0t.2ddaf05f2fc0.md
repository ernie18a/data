Calculation: Standardized(x, n) = (x - SMA(x, n)) / STDEV(x, n) if STDEV(x, n) > 0, else 0
Calculation: ZOBV = Standardized(OBV(close, volume), normalization lookback)
Calculation: Slope(x) = (x - x[slope window]) / slope window
Calculation: SlopeGap = Slope(HMA(ZOBV, shorter lookback)) - Slope(DEMA(ZOBV, longer lookback))
Calculation: HullSlope = Slope(HMA(ZOBV, shorter lookback))
Calculation: VolRatio = volume / SMA(volume, normalization lookback) if SMA(volume, normalization lookback) > 0, else 1
Calculation: PrevHigh = (price, obv, bar) of the latest earlier bar where PivotHigh(high, pivot left, pivot right) and PivotHigh(ZOBV, pivot left, pivot right) are both non-na, with price and obv the two pivot values at that bar and bar = that bar's index - pivot right; na if none
Calculation: PrevLow = (price, obv, bar) of the latest earlier bar where PivotLow(low, pivot left, pivot right) and PivotLow(ZOBV, pivot left, pivot right) are both non-na, with price and obv the two pivot values at that bar and bar = that bar's index - pivot right; na if none
Calculation: BearDivergence = PivotHigh(high, pivot left, pivot right) > PrevHigh.price AND PivotHigh(ZOBV, pivot left, pivot right) < PrevHigh.obv AND (current bar index - pivot right - PrevHigh.bar) <= max pivot range AND (slope filter switch off OR SlopeGap < -slope confirmation minimum)
Calculation: BullDivergence = PivotLow(low, pivot left, pivot right) < PrevLow.price AND PivotLow(ZOBV, pivot left, pivot right) > PrevLow.obv AND (current bar index - pivot right - PrevLow.bar) <= max pivot range AND (slope filter switch off OR SlopeGap > slope confirmation minimum)
Calculation: DivergenceTerm = 0 if divergence scoring switch off, else min(strength cap, abs(PivotLow(ZOBV, pivot left, pivot right) - PrevLow.obv) * strength scale) * divergence bias factor if BullDivergence, else -min(strength cap, abs(PivotHigh(ZOBV, pivot left, pivot right) - PrevHigh.obv) * strength scale) * divergence bias factor if BearDivergence, else 0
Calculation: Composite = clamp(0, 100, slope weight * clamp(0, 100, anchor + slope scale * Standardized(SlopeGap, normalization lookback)) + distance weight * clamp(0, 100, anchor + distance scale * (HMA(ZOBV, shorter lookback) - DEMA(ZOBV, longer lookback))) + anchor weight * anchor + DivergenceTerm + volume weight * clamp(-volume boost cap, volume boost cap, (VolRatio - 1) * volume boost factor) * (1 if HullSlope >= 0 else -1))
Calculation: ConfBull = Lowest(Composite, confirmation bars) >= bullish threshold
Calculation: ConfBear = Highest(Composite, confirmation bars) <= bearish threshold
Calculation: Age = 0 if Dir != Dir[1], else Age[1] + 1; infinite before any change of Dir
Calculation: Dir = 1 if ConfBull AND Dir[1] != 1 AND Age[1] + 1 >= minimum bars between shifts; -1 if ConfBear AND Dir[1] != -1 AND Age[1] + 1 >= minimum bars between shifts; else Dir[1]; Dir is 0 before the first bar
Calculation: Phase = 1 if ConfBull; -1 if ConfBear; else Dir[1]
Long: Dir = 1 AND Dir[1] != 1
Short: Dir = -1 AND Dir[1] != -1
Long: BullDivergence = true
Short: BearDivergence = true
Long: HMA(ZOBV, shorter lookback) > DEMA(ZOBV, longer lookback)
Short: HMA(ZOBV, shorter lookback) <= DEMA(ZOBV, longer lookback)
Long: SlopeGap > 0
Short: SlopeGap <= 0
Long: Dir = 1 AND Age < shift window bars AND shift window switch on
Short: Dir = -1 AND Age < shift window bars AND shift window switch on
Long: Phase = 1
Short: Phase = -1
Long: HullSlope > HullSlope[1]
Short: HullSlope < HullSlope[1]
Long: Composite > strong upper threshold AND HullSlope > 0 AND HullSlope > HullSlope[1] AND VolRatio > 1
Short: Composite < strong lower threshold AND HullSlope < 0 AND HullSlope < HullSlope[1] AND VolRatio < 1