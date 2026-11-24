Calculation: TrendBias(timeframe) = 1 if EMA(close, shortLen) > EMA(close, longLen) else -1, with shortLen < longLen; timeframe is chart, T1, or T2, where T1 and T2 EMAs use the last completed bar and are taken on chart bars
Calculation: VWAP = volume-weighted average of (high + low + close) / 3, reset at the start of each day
Calculation: LastSwingLow = most recent PivotLow(low, pivotLen, pivotLen) confirmed on a bar within trading hours (time-of-day between tradeStart and tradeEnd), held until the next such confirmation
Calculation: LastSwingHigh = most recent PivotHigh(high, pivotLen, pivotLen) confirmed on a bar within trading hours (time-of-day between tradeStart and tradeEnd), held until the next such confirmation
Calculation: PrevPivotHigh = value of the most recent PivotHigh(high, pivotLen, pivotLen) confirmed on any earlier bar, undefined if none
Calculation: PrevPivotLow = value of the most recent PivotLow(low, pivotLen, pivotLen) confirmed on any earlier bar, undefined if none
Calculation: LongSweep = low < LastSwingLow AND close > LastSwingLow AND close - low >= ATR(atrLen) * sweepAtrMin AND in market session AND no earlier LongSweep since LastSwingLow was last set AND (no earlier LongSweep OR the latest earlier LongSweep is at least sweepCooldown bars before this bar)
Calculation: ShortSweep = high > LastSwingHigh AND close < LastSwingHigh AND high - close >= ATR(atrLen) * sweepAtrMin AND in market session AND no earlier ShortSweep since LastSwingHigh was last set AND (no earlier ShortSweep OR the latest earlier ShortSweep is at least sweepCooldown bars before this bar)
Calculation: CompositeScore = round(emaWeight * (TrendBias(chart) + TrendBias(T1) + TrendBias(T2)) / 3 + rsiWeight * (RSI(close, rsiLen) - 50) / 50 + macdWeight * (1 if MACDHist(close, macdFast, macdSlow, macdSignal) > 0 else -1) + volWeight * (1 if volume > volHi * SMA(volume, volLen) else -1 if volume < volLo * SMA(volume, volLen) else 0))
Calculation: LevelConfluence(px) = count of levels L with abs(px - L) < px * confPct / 100, for L in VWAP, VWAP + SD, VWAP - SD (SD = volume-weighted standard deviation of (high + low + close) / 3 around VWAP), OpeningRangeHigh, OpeningRangeLow, PDH, PDL, session open price, classic pivot P, classic R1, classic S1, session low + (session high - session low) * f for f in fibA, fibB, fibC, EMA(close, longLen), SMA(close, smaLen); PDH and PDL are the high and low, and P, R1, S1 the classic pivot levels, of the last completed T2 bar, taken on chart bars
Calculation: HighConvictionLong = LongSweep AND CompositeScore > fireT5 AND LevelConfluence(low) >= fireConf
Calculation: HighConvictionShort = ShortSweep AND CompositeScore < -fireT5 AND LevelConfluence(high) >= fireConf
Calculation: ModerateLong = LongSweep AND NOT HighConvictionLong AND CompositeScore > 0 AND LevelConfluence(low) >= moderateConf
Calculation: ModerateShort = ShortSweep AND NOT HighConvictionShort AND CompositeScore < 0 AND LevelConfluence(high) >= moderateConf
Calculation: OpeningRangeHigh = highest high from session start through the first orbMinutes minutes of the session, undefined until that window closes
Calculation: OpeningRangeLow = lowest low from session start through the first orbMinutes minutes of the session, undefined until that window closes
Calculation: UptrendState = EMA(close, shortLen) > EMA(close, longLen) AND close > VWAP
Calculation: DowntrendState = EMA(close, shortLen) < EMA(close, longLen) AND close < VWAP
Calculation: NearPullbackLevel = abs(close - EMA(close, longLen)) < ATR(atrLen) * pbAtr OR abs(close - VWAP) < ATR(atrLen) * pbAtr OR abs(close - OpeningRangeHigh) < ATR(atrLen) * pbAtr OR abs(close - OpeningRangeLow) < ATR(atrLen) * pbAtr
Calculation: TrailStopLevel = PivotLow(low, trailLen, trailLen) if UptrendState AND PivotLow(low, trailLen, trailLen) is defined AND (TrailStopLevel[1] is undefined OR PivotLow(low, trailLen, trailLen) > TrailStopLevel[1]), else PivotHigh(high, trailLen, trailLen) if DowntrendState AND PivotHigh(high, trailLen, trailLen) is defined AND (TrailStopLevel[1] is undefined OR PivotHigh(high, trailLen, trailLen) < TrailStopLevel[1]), else TrailStopLevel[1]
Calculation: TrailBullState = true if TrailStopLevel was last set by its uptrend branch, false if last set by its downtrend branch
Long: LongSweep
Short: ShortSweep
Long: HighConvictionLong
Short: HighConvictionShort
Long: ModerateLong
Short: ModerateShort
Long: low <= VWAP AND close > VWAP
Short: high >= VWAP AND close < VWAP
Long: low <= VWAP AND close > VWAP AND NOT HighConvictionLong AND NOT ModerateLong AND CompositeScore > -vwapT5 AND close > open AND in market session
Short: high >= VWAP AND close < VWAP AND NOT HighConvictionShort AND NOT ModerateShort AND CompositeScore < vwapT5 AND close < open AND in market session
Long: BarsSince(LongSweep) = confirmBars AND close > low[confirmBars] AND close > open
Short: BarsSince(ShortSweep) = confirmBars AND close < high[confirmBars] AND close < open
Long: close > OpeningRangeHigh AND close[1] <= OpeningRangeHigh
Short: close < OpeningRangeLow AND close[1] >= OpeningRangeLow
Long: low <= OpeningRangeHigh AND close > OpeningRangeHigh
Short: high >= OpeningRangeLow AND close < OpeningRangeLow
Long: UptrendState AND NearPullbackLevel AND close > open AND in market session AND NOT HighConvictionLong AND NOT ModerateLong
Short: DowntrendState AND NearPullbackLevel AND close < open AND in market session AND NOT HighConvictionShort AND NOT ModerateShort
Long: TrailBullState
Short: TrailStopLevel is defined AND TrailBullState is false
Long: CompositeScore >= zoneT5
Short: CompositeScore <= -zoneT5
Long: close > open AND volume > 0
Short: close <= open OR volume = 0
Long: PivotHigh(high, pivotLen, pivotLen) is defined AND (PrevPivotHigh is undefined OR PivotHigh(high, pivotLen, pivotLen) > PrevPivotHigh)
Short: PivotHigh(high, pivotLen, pivotLen) is defined AND PrevPivotHigh is defined AND PivotHigh(high, pivotLen, pivotLen) <= PrevPivotHigh
Long: PivotLow(low, pivotLen, pivotLen) is defined AND PrevPivotLow is defined AND PivotLow(low, pivotLen, pivotLen) > PrevPivotLow
Short: PivotLow(low, pivotLen, pivotLen) is defined AND (PrevPivotLow is undefined OR PivotLow(low, pivotLen, pivotLen) <= PrevPivotLow)