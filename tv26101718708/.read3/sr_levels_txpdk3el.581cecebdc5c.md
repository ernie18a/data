Calculation: Touch(L) = low <= L + close * TouchTolerance AND high >= L - close * TouchTolerance
Calculation: BullRejection(L) = Touch(L) AND close > L AND close > open
Calculation: BearRejection(L) = Touch(L) AND close < L AND close < open
Calculation: NearLevel(L) = abs(close - L) / close < VisibilityRange
Calculation: PrevHigh(T) = high of the last completed T bar, read on chart bars
Calculation: PrevLow(T) = low of the last completed T bar, read on chart bars
Calculation: PrevSessionHigh(S) = highest high of the last completed session S, on chart bars
Calculation: PrevSessionLow(S) = lowest low of the last completed session S, on chart bars
Calculation: HigherTFProximity = NearLevel(PrevHigh(T)) OR NearLevel(PrevLow(T)) for any T among T2, T3, T4
Calculation: SessionProximity = NearLevel(PrevSessionHigh(S)) OR NearLevel(PrevSessionLow(S)) for any S among S1, S2, S3
Calculation: VolumeSpike = volume > SMA(volume, VolumeLookback) * VolumeMultiplier
Calculation: BullTrend = close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) > EMA(close, longer lookback)
Calculation: BearTrend = close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) < EMA(close, longer lookback)
Calculation: BullScore = T1 level weight * BullRejection(PrevLow(T1)) + T2 level weight * BullRejection(PrevLow(T2)) + T3 level weight * BullRejection(PrevLow(T3)) + T4 level weight * BullRejection(PrevLow(T4)) + S1 level weight * BullRejection(PrevSessionLow(S1)) + S2 level weight * BullRejection(PrevSessionLow(S2)) + S3 level weight * BullRejection(PrevSessionLow(S3)) + higher-TF proximity weight * HigherTFProximity + session proximity weight * SessionProximity + volume weight * VolumeSpike
Calculation: BearScore = T1 level weight * BearRejection(PrevHigh(T1)) + T2 level weight * BearRejection(PrevHigh(T2)) + T3 level weight * BearRejection(PrevHigh(T3)) + T4 level weight * BearRejection(PrevHigh(T4)) + S1 level weight * BearRejection(PrevSessionHigh(S1)) + S2 level weight * BearRejection(PrevSessionHigh(S2)) + S3 level weight * BearRejection(PrevSessionHigh(S3)) + higher-TF proximity weight * HigherTFProximity + session proximity weight * SessionProximity + volume weight * VolumeSpike
Calculation: ResistanceBase = close at the pivot bar of the most recent PivotHigh(high, PivotLookback, PivotLookback)
Calculation: ResistanceThrust = average of the positive differences ResistanceBase - PH, where PH ranges over the PivotHigh values at positions PivotDepth to PivotDepth + AverageCount - 1, counting back from the most recent PivotHigh as position 1
Calculation: SupportBase = close at the pivot bar of the most recent PivotLow(low, PivotLookback, PivotLookback)
Calculation: SupportThrust = average of the positive differences PL - SupportBase, where PL ranges over the PivotLow values at positions PivotDepth to PivotDepth + AverageCount - 1, counting back from the most recent PivotLow as position 1
Calculation: ResistanceZoneHigh = ResistanceBase + ResistanceThrust
Calculation: ResistanceZoneLow = ResistanceBase + ResistanceThrust * ZoneFraction
Calculation: SupportZoneLow = SupportBase - SupportThrust
Calculation: SupportZoneHigh = SupportBase - SupportThrust * ZoneFraction
Calculation: NearestTouchedLevel = among enabled levels L with Touch(L) true (PrevHigh(T) and PrevLow(T) for T in T1 to T4, and PrevSessionHigh(S) and PrevSessionLow(S) for S in S1 to S3), the L with minimal abs(close - L); undefined if none
Calculation: AnchorLevel = NearestTouchedLevel on each bar where NearestTouchedLevel is defined AND (AnchorLevel is undefined OR (abs(NearestTouchedLevel - AnchorLevel) / close > TouchTolerance AND bars since AnchorLevel was last set >= MinBarsBeforeReanchor)), otherwise the previous bar's AnchorLevel
Calculation: AnchoredVWAP = VWAP(hlc3, volume) accumulated from the bar where AnchorLevel was last set through the current bar
Long: BullScore >= MinimumScore AND BullTrend AND VolumeSpike AND (no earlier Long marking OR bars since last Long marking > CooldownBars)
Short: BearScore >= MinimumScore AND BearTrend AND VolumeSpike AND (no earlier Short marking OR bars since last Short marking > CooldownBars)
Long: close > PrevHigh(T1) AND close[1] <= PrevHigh(T1) AND VolumeSpike
Short: close < PrevLow(T1) AND close[1] >= PrevLow(T1) AND VolumeSpike
Long: close >= SupportZoneLow AND close <= SupportZoneHigh AND (BullTrend OR BearTrend)
Short: close >= ResistanceZoneLow AND close <= ResistanceZoneHigh AND (BullTrend OR BearTrend)
Long: AnchoredVWAP > AnchorLevel
Short: AnchoredVWAP <= AnchorLevel