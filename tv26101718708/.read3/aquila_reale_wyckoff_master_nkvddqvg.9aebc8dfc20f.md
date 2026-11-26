Calculation: PivotTop = maximum of the pivotCount most recent confirmed PivotHigh(high, pivotLeftBars, pivotRightBars)
Calculation: PivotBottom = minimum of the pivotCount most recent confirmed PivotLow(low, pivotLeftBars, pivotRightBars)
Calculation: TopLevel = IF PivotTop - PivotBottom > 0 THEN PivotTop ELSE Highest(high, lookbackBars)
Calculation: BottomLevel = IF PivotTop - PivotBottom > 0 THEN PivotBottom ELSE Lowest(low, lookbackBars)
Calculation: SpanSize = TopLevel - BottomLevel
Calculation: MidLevel = (TopLevel + BottomLevel) / 2
Calculation: PricePosition = (close - BottomLevel) / (SpanSize + 0.0001)
Calculation: LatestPivotLow = value of the most recent confirmed PivotLow(low, pivotLeftBars, pivotRightBars)
Calculation: PreviousPivotLow = value of the second most recent confirmed PivotLow(low, pivotLeftBars, pivotRightBars)
Calculation: LatestPivotHigh = value of the most recent confirmed PivotHigh(high, pivotLeftBars, pivotRightBars)
Calculation: PreviousPivotHigh = value of the second most recent confirmed PivotHigh(high, pivotLeftBars, pivotRightBars)
Calculation: HigherClose = close(T1, last completed bar)
Calculation: HigherEmaShort = EMA(close, emaShortLength, T1, last completed bar)
Calculation: HigherEmaLong = EMA(close, emaLongLength, T1, last completed bar), where emaLongLength > emaShortLength
Calculation: HighVolume = volume > SMA(volume, volAvgLength) * highVolMult
Calculation: LowVolume = volume < SMA(volume, volAvgLength) * lowVolMult, where lowVolMult < highVolMult
Calculation: BodyRatio = abs(close - open) / (high - low + 0.00001)
Calculation: UpDownVolumeRatio = average volume[n] over n from 0 to lookbackBars - 1 where close[n] > open[n], divided by (average volume[n] over the same n where close[n] < open[n], plus 0.0001)
Calculation: EntryLevel = IF SetupShort THEN TopLevel - SpanSize * entryFrac ELSE BottomLevel + SpanSize * entryFrac
Calculation: ShowLevels = alwaysShowLevels OR AccumulationDetected OR DistributionDetected
Calculation: TrendAcc = (HigherClose < HigherEmaShort ? weakPts : 0) + (HigherClose < HigherEmaLong ? weakPts : 0) + (HigherEmaShort < HigherEmaLong ? weakPts : 0)
Calculation: TrendDist = (HigherClose > HigherEmaShort ? weakPts : 0) + (HigherClose > HigherEmaLong ? weakPts : 0) + (HigherEmaShort > HigherEmaLong ? weakPts : 0)
Calculation: StructAcc = (LatestPivotLow > PreviousPivotLow ? strongPts : 0) + (LatestPivotHigh > PreviousPivotHigh ? weakPts : 0)
Calculation: StructDist = (LatestPivotLow < PreviousPivotLow ? weakPts : 0) + (LatestPivotHigh < PreviousPivotHigh ? strongPts : 0)
Calculation: VolAcc = (UpDownVolumeRatio > volRatioStrongUp ? strongPts : UpDownVolumeRatio > volRatioWeakUp ? weakPts : 0) + ((close < BottomLevel + SpanSize * edgeZoneFrac AND (some n from 0 to climaxLookbackBars has volume[n] > SMA(volume, volAvgLength)[n] * climaxVolMult AND close[n] < open[n])) ? strongPts : 0), where volRatioStrongUp > volRatioWeakUp
Calculation: VolDist = (UpDownVolumeRatio < volRatioStrongDown ? strongPts : UpDownVolumeRatio < volRatioWeakDown ? weakPts : 0) + ((close > TopLevel - SpanSize * edgeZoneFrac AND (some n from 0 to climaxLookbackBars has volume[n] > SMA(volume, volAvgLength)[n] * climaxVolMult AND close[n] > open[n])) ? strongPts : 0), where volRatioStrongDown < volRatioWeakDown
Calculation: VsaAcc = ((close < open AND HighVolume AND BodyRatio > bodyStopMin AND close > low + (high - low) * closeStopFrac AND close < MidLevel) ? weakPts : 0) + ((close < open AND BodyRatio < bodyWeakMax AND LowVolume AND close < BottomLevel + SpanSize * edgeZoneFrac) ? weakPts : 0) + ((low < BottomLevel + SpanSize * testZoneFrac AND low > BottomLevel AND LowVolume) ? weakPts : 0) + ((close > open AND BodyRatio > bodyStrongMin AND HighVolume AND close > MidLevel) ? weakPts : 0)
Calculation: VsaDist = ((close > open AND BodyRatio < bodyWeakMax AND LowVolume AND close > TopLevel - SpanSize * edgeZoneFrac) ? weakPts : 0) + ((high > TopLevel - SpanSize * testZoneFrac AND high < TopLevel AND LowVolume) ? weakPts : 0) + ((close < open AND BodyRatio > bodyStrongMin AND HighVolume AND close < MidLevel) ? weakPts : 0)
Calculation: PosAcc = (PricePosition < posStrongLow ? strongPts : PricePosition < posWeakLow ? weakPts : 0), where posStrongLow < posWeakLow
Calculation: PosDist = (PricePosition > posStrongHigh ? strongPts : PricePosition > posWeakHigh ? weakPts : 0), where posStrongHigh > posWeakHigh
Calculation: AccScore = TrendAcc + StructAcc + VolAcc + VsaAcc + PosAcc
Calculation: DistScore = TrendDist + StructDist + VolDist + VsaDist + PosDist
Calculation: AccumulationDetected = AccScore >= tradeThreshold AND AccScore > DistScore + leadMargin
Calculation: DistributionDetected = DistScore >= tradeThreshold AND DistScore > AccScore + leadMargin
Calculation: SetupLong = (setupMode = longOption) OR ((setupMode = autoOption) AND (AccScore > DistScore OR (alwaysShowLevels AND close < MidLevel AND AccScore >= DistScore)))
Calculation: SetupShort = (setupMode = shortOption) OR ((setupMode = autoOption) AND (DistScore > AccScore OR (alwaysShowLevels AND close > MidLevel AND DistScore >= AccScore)))
Long: AccumulationDetected
Long: AccScore >= weakThreshold AND AccScore > DistScore
Long: AccScore > DistScore
Long: TrendAcc > TrendDist
Long: StructAcc > StructDist
Long: VolAcc > VolDist
Long: VsaAcc > VsaDist
Long: PosAcc > PosDist
Long: SetupLong AND ShowLevels
Long: SetupLong AND ShowLevels AND close crosses EntryLevel
Short: DistributionDetected
Short: DistScore >= weakThreshold AND DistScore > AccScore
Short: DistScore > AccScore
Short: TrendDist > TrendAcc
Short: StructDist > StructAcc
Short: VolDist > VolAcc
Short: VsaDist > VsaAcc
Short: PosDist > PosAcc
Short: SetupShort AND ShowLevels
Short: SetupShort AND ShowLevels AND close crosses EntryLevel