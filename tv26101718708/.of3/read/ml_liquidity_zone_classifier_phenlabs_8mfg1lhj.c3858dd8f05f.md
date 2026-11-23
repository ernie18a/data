Calculation: NormVolume = min(R / volume feature cap, 1), where R = volume / SMA(volume, volume average length) if that SMA is positive, else 1
Calculation: HtfAlignment = 1 - min(nearest / ATR(atr length) / distance feature cap, 1), where nearest = min of abs(close - x) over x in {open, high, low, close}[1] of T1 bars, last completed bar; neutral alignment if ATR(atr length) is not positive or those values are unavailable
Calculation: NormDisplacement = min(abs(close - open) / ATR(atr length) / displacement feature cap, 1), or 0 if ATR(atr length) is not positive
Calculation: TrainingSet = the most recent training window samples, where each bar records (NormVolume[eval window], HtfAlignment[eval window], NormDisplacement[eval window], label) if ATR(atr length)[eval window] is positive, and label = 1 if abs(close - close[eval window]) > eval move multiple * ATR(atr length)[eval window], else 0
Calculation: KnnScore = 100 * (number of label-1 samples among the min(k, n) TrainingSet samples nearest to (NormVolume, HtfAlignment, NormDisplacement) by Euclidean distance) / min(k, n), where n = size of TrainingSet; neutral score if n = 0
Calculation: Eligible = (no zone drawn yet OR bars since last drawn zone >= min gap) AND KnnScore >= min confidence
Calculation: PriceTolerance = equal tolerance * ATR(atr length)
Calculation: HighPivot = PivotHigh(high, pivot length, pivot length)
Calculation: LowPivot = PivotLow(low, pivot length, pivot length)
Calculation: BullishOrderBlock = close - open > order block body multiple * ATR(atr length) AND close[1] < open[1]
Calculation: BearishOrderBlock = open - close > order block body multiple * ATR(atr length) AND close[1] > open[1]
Calculation: Free(top, bottom) = true when no existing zone overlaps [top, bottom] after clamping it to max zone height * ATR(atr length) around its midpoint if taller; overlap means zone top >= bottom - merge distance * ATR(atr length) AND zone bottom <= top + merge distance * ATR(atr length); existing zones are zones drawn on earlier bars that are not removed by mitigation (if mitigation enabled, a bullish zone is removed once close < its bottom and a bearish zone once close > its top) and are among the newest max visible zones
Calculation: OrderBlockZone = (BullishOrderBlock OR BearishOrderBlock) AND Free(high[1], low[1])
Calculation: EqualHighZone = HighPivot is not na AND a previous non-na HighPivot exists AND abs(HighPivot - previous non-na HighPivot) <= PriceTolerance AND Free(HighPivot + PriceTolerance / 2, HighPivot - PriceTolerance / 2)
Calculation: EqualLowZone = LowPivot is not na AND a previous non-na LowPivot exists AND abs(LowPivot - previous non-na LowPivot) <= PriceTolerance AND Free(LowPivot + PriceTolerance / 2, LowPivot - PriceTolerance / 2)
Calculation: HighVolumeZone = volume > volume spike multiple * SMA(volume, volume average length) AND volume >= Highest(volume, volume peak window) AND Free(high, low)
Long: Eligible AND BullishOrderBlock AND Free(high[1], low[1])
Long: Eligible AND EqualLowZone AND NOT OrderBlockZone AND NOT EqualHighZone
Long: Eligible AND HighVolumeZone AND close >= open AND NOT OrderBlockZone AND NOT EqualHighZone AND NOT EqualLowZone
Short: Eligible AND BearishOrderBlock AND Free(high[1], low[1])
Short: Eligible AND EqualHighZone AND NOT OrderBlockZone
Short: Eligible AND HighVolumeZone AND close < open AND NOT OrderBlockZone AND NOT EqualHighZone AND NOT EqualLowZone
Long: close[1] of T1 bars, last completed bar > open[1] of T1 bars, last completed bar
Short: close[1] of T1 bars, last completed bar < open[1] of T1 bars, last completed bar