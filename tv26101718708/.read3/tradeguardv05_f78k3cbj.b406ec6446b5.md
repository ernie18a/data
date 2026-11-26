Calculation: SqueezeState = BollingerBands(close, P_squeezeLength, P_BBwidth).upper < EMA(close, P_squeezeLength) + ATR(P_squeezeLength) * P_KCwidth AND BollingerBands(close, P_squeezeLength, P_BBwidth).lower > EMA(close, P_squeezeLength) - ATR(P_squeezeLength) * P_KCwidth
Calculation: ChoppyState = abs(EMA(close, P_fast) - EMA(close, P_slow)) / EMA(close, P_slow) * 100 < P_chopThreshold OR SqueezeState
Calculation: BullTrend = NOT ChoppyState AND EMA(close, P_fast) > EMA(close, P_slow) AND EMA(close, P_slow) > EMA(close, P_slowest) AND close > EMA(close, P_fast), where P_fast < P_slow < P_slowest
Calculation: BearTrend = NOT ChoppyState AND EMA(close, P_fast) < EMA(close, P_slow) AND EMA(close, P_slow) < EMA(close, P_slowest) AND close < EMA(close, P_fast), where P_fast < P_slow < P_slowest
Calculation: BullT1 = EMA(close, P_fast, T1, still-forming bar) > EMA(close, P_slow, T1, still-forming bar) AND close(T1, still-forming bar) > EMA(close, P_slowest, T1, still-forming bar)
Calculation: BearT1 = EMA(close, P_fast, T1, still-forming bar) < EMA(close, P_slow, T1, still-forming bar) AND close(T1, still-forming bar) < EMA(close, P_slowest, T1, still-forming bar)
Calculation: BullT2 = EMA(close, P_fast, T2, still-forming bar) > EMA(close, P_slow, T2, still-forming bar) AND close(T2, still-forming bar) > EMA(close, P_slowest, T2, still-forming bar)
Calculation: BearT2 = EMA(close, P_fast, T2, still-forming bar) < EMA(close, P_slow, T2, still-forming bar) AND close(T2, still-forming bar) < EMA(close, P_slowest, T2, still-forming bar)
Calculation: VolumeAboveAverage = volume > SMA(volume, P_volumeLength)
Calculation: BuyerDominance = volume * (close - low) / (high - low) >= volume * (high - close) / (high - low)
Calculation: BullVolumeConfirmation = BuyerDominance AND VolumeAboveAverage
Calculation: BearVolumeConfirmation = NOT BuyerDominance AND VolumeAboveAverage
Calculation: EntryTimeWindow = time since regular-session open >= P_entryDelay AND current time <= P_lastEntryTime
Calculation: OpeningRestriction = time since regular-session open >= 0 AND time since regular-session open < P_openingWindow
Calculation: AfterOptionCutoff = current time >= P_0DTECutoff
Calculation: RegimeScore = (BullTrend OR BearTrend) + ((BullTrend AND BullT1) OR (BearTrend AND BearT1)) + ((BullTrend AND BullT2) OR (BearTrend AND BearT2)) + ((BullTrend AND close > VWAP(hlc3, session)) OR (BearTrend AND close < VWAP(hlc3, session))) + NOT SqueezeState + (EntryTimeWindow AND NOT OpeningRestriction)
Calculation: RegimeEligible = RegimeScore >= P_regimeMinimum
Calculation: HighRegime = RegimeScore >= P_regimeHigh
Calculation: PriorTradingDayHigh = highest high of the preceding trading day
Calculation: PriorTradingDayLow = lowest low of the preceding trading day
Calculation: PremarketHigh = highest high during the current trading day's premarket session
Calculation: PremarketLow = lowest low during the current trading day's premarket session
Calculation: OpeningRangeHigh = highest high from regular-session open through P_openingRangeDuration; OpeningRangeLow = lowest low over the same interval; OpeningRangeSet = that interval has ended
Calculation: PriorWeekHigh = high(T4, last completed bar); PriorWeekLow = low(T4, last completed bar)
Calculation: SessionBias(high, low, close) = bullish if (close - low) / (high - low) > P_sessionUpper; bearish if (close - low) / (high - low) < P_sessionLower; otherwise neutral, with neutral for a missing or zero range and P_sessionLower < P_sessionUpper
Calculation: LondonSweepsAsiaHigh = London session high > Asia session high AND London session close < Asia session high
Calculation: LondonSweepsAsiaLow = London session low < Asia session low AND London session close > Asia session low
Calculation: USSessionDirection = CALL if LondonSweepsAsiaLow; otherwise PUT if LondonSweepsAsiaHigh; otherwise CALL if London session close > Asia session high; otherwise PUT if London session close < Asia session low; otherwise CALL if Asia and London SessionBias are both bullish; otherwise PUT if both are bearish; otherwise neutral if both are non-neutral and differ; otherwise CALL if London SessionBias is bullish; otherwise PUT if it is bearish; otherwise neutral
Calculation: BullPDLSweep = low < PriorTradingDayLow * (1 - P_sweepBuffer / 100) AND close > PriorTradingDayLow AND close > open
Calculation: BearPDHSweep = high > PriorTradingDayHigh * (1 + P_sweepBuffer / 100) AND close < PriorTradingDayHigh AND close < open
Calculation: BullPWLSweep = low < PriorWeekLow * (1 - P_sweepBuffer / 100) AND close > PriorWeekLow AND close > open
Calculation: BearPWHSweep = high > PriorWeekHigh * (1 + P_sweepBuffer / 100) AND close < PriorWeekHigh AND close < open
Calculation: BullEMASweep = low < EMA(close, P_fast) * (1 - P_sweepBuffer / 100) AND close > EMA(close, P_fast) AND close > open AND EMA(close, P_fast) > EMA(close, P_slow)
Calculation: BearEMASweep = high > EMA(close, P_fast) * (1 + P_sweepBuffer / 100) AND close < EMA(close, P_fast) AND close < open AND EMA(close, P_fast) < EMA(close, P_slow)
Calculation: EqualHighCluster = abs(high - Highest(high, P_equalLookback)[previous chart bar]) / Highest(high, P_equalLookback)[previous chart bar] * 100 < P_equalThreshold
Calculation: EqualLowCluster = abs(low - Lowest(low, P_equalLookback)[previous chart bar]) / Lowest(low, P_equalLookback)[previous chart bar] * 100 < P_equalThreshold
Calculation: BearEqualHighSweep = high > Highest(high, P_equalLookback)[previous chart bar] * (1 + P_sweepBuffer / 100) AND close < Highest(high, P_equalLookback)[previous chart bar] AND close < open AND EqualHighCluster on the previous chart bar AND volume > SMA(volume, P_equalSweepVolumeLength)
Calculation: BullEqualLowSweep = low < Lowest(low, P_equalLookback)[previous chart bar] * (1 - P_sweepBuffer / 100) AND close > Lowest(low, P_equalLookback)[previous chart bar] AND close > open AND EqualLowCluster on the previous chart bar AND volume > SMA(volume, P_equalSweepVolumeLength)
Calculation: BullSweep = BullPDLSweep OR BullPWLSweep OR BullEMASweep OR BullEqualLowSweep
Calculation: BearSweep = BearPDHSweep OR BearPWHSweep OR BearEMASweep OR BearEqualHighSweep
Calculation: BullPullback = BullTrend AND low <= EMA(close, P_fast) * (1 + P_emaTolerance) AND close > EMA(close, P_fast) AND close > open AND BullVolumeConfirmation AND EntryTimeWindow
Calculation: BearPullback = BearTrend AND high >= EMA(close, P_fast) * (1 - P_emaTolerance) AND close < EMA(close, P_fast) AND close < open AND BearVolumeConfirmation AND EntryTimeWindow
Calculation: BullRetest(level) = a prior close crossed above level from at or below it with VolumeAboveAverage, BullTrend, and EntryTimeWindow; the break remains active for P_retestWindow bars unless close falls below level * (1 - P_levelResetTolerance); within that window, low <= level * (1 + P_levelRetestTolerance) AND close >= level AND close > open AND BullVolumeConfirmation
Calculation: BearRetest(level) = a prior close crossed below level from at or above it with VolumeAboveAverage, BearTrend, and EntryTimeWindow; the break remains active for P_retestWindow bars unless close rises above level * (1 + P_levelResetTolerance); within that window, high >= level * (1 - P_levelRetestTolerance) AND close <= level AND close < open AND BearVolumeConfirmation
Calculation: BullORBRetest = OpeningRangeSet AND close > OpeningRangeHigh AND close on previous chart bar <= OpeningRangeHigh AND VolumeAboveAverage AND BullTrend AND EntryTimeWindow AND low <= OpeningRangeHigh * (1 + P_levelRetestTolerance) AND close >= OpeningRangeHigh AND close > open AND BullVolumeConfirmation
Calculation: BearORBRetest = OpeningRangeSet AND close < OpeningRangeLow AND close on previous chart bar >= OpeningRangeLow AND VolumeAboveAverage AND BearTrend AND EntryTimeWindow AND high >= OpeningRangeLow * (1 - P_levelRetestTolerance) AND close <= OpeningRangeLow AND close < open AND BearVolumeConfirmation
Calculation: BullEMAReclaim = since a close crossed below EMA(close, P_fast) from at or above it, no close has exceeded EMA(close, P_fast) * (1 + P_emaTolerance); currently low <= EMA(close, P_fast) * (1 + P_emaTolerance) AND close > EMA(close, P_fast) AND close > open AND BullTrend AND BullVolumeConfirmation AND EntryTimeWindow
Calculation: BearEMAReclaim = since a close crossed above EMA(close, P_fast) from at or below it, no close has fallen below EMA(close, P_fast) * (1 - P_emaTolerance); currently high >= EMA(close, P_fast) * (1 - P_emaTolerance) AND close < EMA(close, P_fast) AND close < open AND BearTrend AND BearVolumeConfirmation AND EntryTimeWindow
Calculation: BullOptionEntry = (BullPullback OR BullRetest(PremarketHigh) OR BullRetest(PriorTradingDayHigh) OR BullORBRetest OR BullEMAReclaim OR (BullSweep AND BullTrend)) AND NOT (P_0DTEMode AND AfterOptionCutoff) AND RegimeEligible
Calculation: BearOptionEntry = (BearPullback OR BearRetest(PremarketLow) OR BearRetest(PriorTradingDayLow) OR BearORBRetest OR BearEMAReclaim OR (BearSweep AND BearTrend)) AND NOT (P_0DTEMode AND AfterOptionCutoff) AND RegimeEligible
Calculation: FlowAverage = SMA(volume, P_flowAverageLength); RangeAverage = SMA(high - low, P_flowAverageLength)
Calculation: BullLargePrint = volume > FlowAverage * P_largeVolumeMultiplier AND high - low < RangeAverage * P_smallRangeFraction AND close > open
Calculation: BearLargePrint = volume > FlowAverage * P_largeVolumeMultiplier AND high - low < RangeAverage * P_smallRangeFraction AND close < open
Calculation: BullFlip = close on the three preceding chart bars increased in sequence AND close > open AND volume > FlowAverage * P_largeVolumeMultiplier AND high - low > RangeAverage * P_largeRangeMultiplier
Calculation: BearFlip = close on the three preceding chart bars decreased in sequence AND close < open AND volume > FlowAverage * P_largeVolumeMultiplier AND high - low > RangeAverage * P_largeRangeMultiplier
Calculation: SupportWall = Lowest(low, P_wallBars) = Lowest(low, P_wallBars) on the previous chart bar AND low <= Lowest(low, P_wallBars) * (1 + P_wallTolerance) AND close > Lowest(low, P_wallBars) AND each of the most recent P_flowVolumeRun bars has volume > FlowAverage
Calculation: ResistanceWall = Highest(high, P_wallBars) = Highest(high, P_wallBars) on the previous chart bar AND high >= Highest(high, P_wallBars) * (1 - P_wallTolerance) AND close < Highest(high, P_wallBars) AND each of the most recent P_flowVolumeRun bars has volume > FlowAverage
Calculation: HiddenBuyer = PivotLow(low, P_pivotStrength, P_pivotStrength) is present AND its difference from Lowest(low, P_hiddenLookback) is less than P_hiddenTolerance percent AND low <= Lowest(low, P_hiddenLookback) * (1 + P_hiddenTolerance) AND close > Lowest(low, P_hiddenLookback) AND volume > FlowAverage
Calculation: HiddenSeller = PivotHigh(high, P_pivotStrength, P_pivotStrength) is present AND its difference from Highest(high, P_hiddenLookback) is less than P_hiddenTolerance percent AND high >= Highest(high, P_hiddenLookback) * (1 - P_hiddenTolerance) AND close < Highest(high, P_hiddenLookback) AND volume > FlowAverage
Calculation: BullConfluenceScore = (BullTrend ? 1 : 0) + (BullT1 ? 1 : 0) + (BullT2 ? 1 : 0) + (close > VWAP(hlc3, session) ? 1 : 0) + (close > VWAP(hlc3, session) ? 1 : 0) + (BullVolumeConfirmation ? 1 : 0) + (BullSweep ? 1 : 0) + ((BullRetest(PremarketHigh) OR BullRetest(PriorTradingDayHigh) OR BullORBRetest OR BullEMAReclaim OR BullPullback) ? 1 : 0) + (HighRegime ? 1 : 0) + ((EntryTimeWindow AND NOT OpeningRestriction) ? 1 : 0)
Calculation: BearConfluenceScore = (BearTrend ? 1 : 0) + (BearT1 ? 1 : 0) + (BearT2 ? 1 : 0) + (close < VWAP(hlc3, session) ? 1 : 0) + (close < VWAP(hlc3, session) ? 1 : 0) + (BearVolumeConfirmation ? 1 : 0) + (BearSweep ? 1 : 0) + ((BearRetest(PremarketLow) OR BearRetest(PriorTradingDayLow) OR BearORBRetest OR BearEMAReclaim OR BearPullback) ? 1 : 0) + (HighRegime ? 1 : 0) + ((EntryTimeWindow AND NOT OpeningRestriction) ? 1 : 0)
Calculation: BullFlagBreakout = pole range over P_poleLength chart bars divided by its low exceeds P_poleMoveThreshold percent AND close > close P_poleLength bars ago AND flag range over P_patternLookback bars < pole range * P_flagRangeFraction AND close > flag midpoint AND BullTrend AND VolumeAboveAverage AND close > Highest(high, P_patternLookback) AND previous close <= previous bar's flag high
Calculation: BearFlagBreakout = pole range over P_poleLength chart bars divided by its low exceeds P_poleMoveThreshold percent AND close < close P_poleLength bars ago AND flag range over P_patternLookback bars < pole range * P_flagRangeFraction AND close < flag midpoint AND BearTrend AND VolumeAboveAverage AND close < Lowest(low, P_patternLookback) AND previous close >= previous bar's flag low
Calculation: BullDoubleBottom = abs(low - Lowest(low, P_doublePatternLookback)) / Lowest(low, P_doublePatternLookback) * 100 < P_doublePatternTolerance AND low > low on previous chart bar AND close > close on previous chart bar AND close > (Highest(high, P_doublePatternLookback) + Lowest(low, P_doublePatternLookback)) / 2 AND VolumeAboveAverage AND BullTrend
Calculation: BearDoubleTop = abs(high - Highest(high, P_doublePatternLookback)) / Highest(high, P_doublePatternLookback) * 100 < P_doublePatternTolerance AND high < high on previous chart bar AND close < close on previous chart bar AND close < (Highest(high, P_doublePatternLookback) + Lowest(low, P_doublePatternLookback)) / 2 AND VolumeAboveAverage AND BearTrend
Calculation: EMATouchRun = 1 when low <= EMA(close, P_fast) * (1 + P_emaTolerance) AND close > EMA(close, P_fast), or high >= EMA(close, P_fast) * (1 - P_emaTolerance) AND close < EMA(close, P_fast); otherwise 0 when close differs from EMA(close, P_fast); otherwise previous EMATouchRun + 1
Calculation: StalledCloseRun = 0 when close differs from close on the previous chart bar; otherwise previous StalledCloseRun + 1
Calculation: ExitStateEligible = NOT OpeningRestriction AND NOT (P_0DTEMode AND AfterOptionCutoff) AND RegimeEligible AND NOT BullOptionEntry AND NOT BearOptionEntry
Long: BullTrend
Short: BearTrend
Long: BullT1
Short: BearT1
Long: BullT2
Short: BearT2
Long: BullVolumeConfirmation
Short: BearVolumeConfirmation
Long: BullPDLSweep
Short: BearPDHSweep
Long: BullPWLSweep
Short: BearPWHSweep
Long: BullEMASweep
Short: BearEMASweep
Long: BullEqualLowSweep
Short: BearEqualHighSweep
Long: BullSweep
Short: BearSweep
Long: HiddenBuyer
Short: HiddenSeller
Long: SupportWall
Short: ResistanceWall
Long: BullLargePrint
Short: BearLargePrint
Long: BullFlip
Short: BearFlip
Long: HiddenBuyer AND SupportWall AND (BullLargePrint OR BullSweep)
Short: HiddenSeller AND ResistanceWall AND (BearLargePrint OR BearSweep)
Long: BullFlagBreakout
Short: BearFlagBreakout
Long: BullDoubleBottom
Short: BearDoubleTop
Long: PivotLow(low, P_zoneStrength, P_zoneStrength) is confirmed
Short: PivotHigh(high, P_zoneStrength, P_zoneStrength) is confirmed
Long: USSessionDirection = CALL
Short: USSessionDirection = PUT
Long: OpeningRangeSet AND close > OpeningRangeHigh
Short: OpeningRangeSet AND close < OpeningRangeLow
Long: close > AnchoredVWAP(hlc3, volume, T3 annual anchor)
Short: close < AnchoredVWAP(hlc3, volume, T3 annual anchor)
Long: crossover(close, AnchoredVWAP(hlc3, volume, T3 annual anchor))
Short: crossunder(close, AnchoredVWAP(hlc3, volume, T3 annual anchor))
Long: crossover(close, VWAP(hlc3, session))
Short: crossunder(close, VWAP(hlc3, session))
Long: close > AnchoredVWAP(hlc3, volume, T3 annual anchor) AND close > VWAP(hlc3, session)
Short: close < AnchoredVWAP(hlc3, volume, T3 annual anchor) AND close < VWAP(hlc3, session)
Long: close > PriorWeekHigh AND close on previous chart bar <= PriorWeekHigh AND VolumeAboveAverage
Short: close < PriorWeekLow AND close on previous chart bar >= PriorWeekLow AND VolumeAboveAverage
Long: BullTrend AND BullConfluenceScore >= P_highConfluence
Long: BullTrend AND BullConfluenceScore >= P_goodConfluence AND BullConfluenceScore < P_highConfluence
Short: BearTrend AND BearConfluenceScore >= P_highConfluence
Short: BearTrend AND BearConfluenceScore >= P_goodConfluence AND BearConfluenceScore < P_highConfluence
Option: buy call, BullOptionEntry
Option: buy put, BearOptionEntry
Exit: long, ExitStateEligible AND BullTrend AND (close < EMA(close, P_fast) OR (P_0DTEMode AND EMATouchRun >= P_bounceBars AND EMATouchRun > 0) OR StalledCloseRun >= P_stallBars)
Exit: short, ExitStateEligible AND BearTrend AND (close > EMA(close, P_fast) OR (P_0DTEMode AND EMATouchRun >= P_bounceBars AND EMATouchRun > 0) OR StalledCloseRun >= P_stallBars)