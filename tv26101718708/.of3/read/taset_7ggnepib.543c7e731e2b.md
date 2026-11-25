Calculation: PivotHighLevel(src, lb, rb, n) = ValueWhen(PivotHigh(src, lb, rb) is confirmed, src[rb], n)
Calculation: PivotLowLevel(src, lb, rb, n) = ValueWhen(PivotLow(src, lb, rb) is confirmed, src[rb], n)
Calculation: HighSrc = if PivotSource is Close then close else high
Calculation: LowSrc = if PivotSource is Close then close else low
Calculation: RegRes(n) = PivotHighLevel(HighSrc, LeftBars, LongerRightBars, n)
Calculation: RegSup(n) = PivotLowLevel(LowSrc, LeftBars, LongerRightBars, n)
Calculation: ProximityOK(lvl) = abs(close - lvl) / lvl * 100 < MinLevelSpacePct
Calculation: LevelSpacingOK = RegRes(0) > RegSup(0) AND (RegRes(0) - RegSup(0)) / RegSup(0) * 100 > MinLevelSpacePct
Calculation: RawShort = ((high > RegRes(0) AND close < RegRes(0)) OR ProximityOK(PivotHighLevel(HighSrc, LeftBars, ShorterRightBars, 0)) OR ProximityOK(RegRes(0)) OR ProximityOK(RegRes(1)) OR ProximityOK(RegRes(2))) AND LevelSpacingOK AND RSI(close, RsiPeriod) >= RsiNearOverbought AND RSI(close, RsiPeriod) < RSI(close, RsiPeriod)[1]
Calculation: RawLong = ((low < RegSup(0) AND close > RegSup(0)) OR ProximityOK(PivotLowLevel(LowSrc, LeftBars, ShorterRightBars, 0)) OR ProximityOK(RegSup(0)) OR ProximityOK(RegSup(1)) OR ProximityOK(RegSup(2))) AND LevelSpacingOK AND RSI(close, RsiPeriod) <= RsiOversold AND RSI(close, RsiPeriod) > RSI(close, RsiPeriod)[1]
Long: RawLong AND NOT RawLong[1]
Short: RawShort AND NOT RawShort[1]
Long: PivotLow(low, DivPivotBars, DivPivotBars) is confirmed AND PivotLowLevel(low, DivPivotBars, DivPivotBars, 0) < PivotLowLevel(low, DivPivotBars, DivPivotBars, 1) AND PivotLowLevel(RSI(close, RsiPeriod), DivPivotBars, DivPivotBars, 0) > PivotLowLevel(RSI(close, RsiPeriod), DivPivotBars, DivPivotBars, 1)
Short: PivotHigh(high, DivPivotBars, DivPivotBars) is confirmed AND PivotHighLevel(high, DivPivotBars, DivPivotBars, 0) > PivotHighLevel(high, DivPivotBars, DivPivotBars, 1) AND PivotHighLevel(RSI(close, RsiPeriod), DivPivotBars, DivPivotBars, 0) < PivotHighLevel(RSI(close, RsiPeriod), DivPivotBars, DivPivotBars, 1)
Calculation: RegSlope = LinRegSlope(close, RegLength)
Long: RegSlope[1] <= 0 AND RegSlope > 0
Short: RegSlope[1] >= 0 AND RegSlope < 0
Calculation: StructLeg(S) = 0 if high[S] > Highest(high, S), 1 if low[S] < Lowest(low, S), otherwise StructLeg(S)[1]
Calculation: StructHigh(S) = high[S] on bars where StructLeg(S) changes from 1 to 0, otherwise StructHigh(S)[1]
Calculation: StructLow(S) = low[S] on bars where StructLeg(S) changes from 0 to 1, otherwise StructLow(S)[1]
Calculation: BullOBLow(S) = highest low of unbroken bullish order blocks of size S; a block forms on the first bar close crosses above a StructHigh(S) level, with block low = lowest low from the bar S bars before that level's leg change through the prior bar; a block is broken on a bar whose low is below the block low
Calculation: BearOBHigh(S) = lowest high of unbroken bearish order blocks of size S; a block forms on the first bar close crosses below a StructLow(S) level, with block high = highest high from the bar S bars before that level's leg change through the prior bar; a block is broken on a bar whose high is above the block high
Short: low < BullOBLow(ShorterOBBars)
Long: high > BearOBHigh(ShorterOBBars)
Short: low < BullOBLow(LongerOBBars)
Long: high > BearOBHigh(LongerOBBars)
Calculation: SetupState = Waiting on the first bar of a new T1 bar when no setup is open (none, or the previous setup is Closed); on later bars while Waiting, SellSwept if low < low of the last completed T1 bar at setup start, else BuySwept if high > high of that last completed T1 bar; SellSwept on the prior bar and high > Highest(high, TsMssBars)[1], or BuySwept on the prior bar and low < Lowest(low, TsMssBars)[1], becomes Entered; Entered becomes Closed on an exit
Calculation: LongStop = Lowest(low, TsMssBars) - ATR(TsAtrPeriod) * StopAtrMultiple, evaluated on the bar where a long entry occurs
Calculation: ShortStop = Highest(high, TsMssBars) + ATR(TsAtrPeriod) * StopAtrMultiple, evaluated on the bar where a short entry occurs
Long: SetupState[1] = SellSwept AND high > Highest(high, TsMssBars)[1]
Short: SetupState[1] = BuySwept AND low < Lowest(low, TsMssBars)[1]
Long: SetupState = SellSwept AND SetupState[1] = Waiting
Short: SetupState = BuySwept AND SetupState[1] = Waiting
Exit: Long, high >= entry price + abs(entry price - LongStop) * RiskReward OR low <= LongStop
Exit: Short, low <= entry price - abs(entry price - ShortStop) * RiskReward OR high >= ShortStop
Calculation: TrailSrc = if UseHeikinAshi then HeikinAshiClose else close
Calculation: TrailKey = max(TrailKeyFloor, TrailSensitivity * TrailKeyScale)
Calculation: TrailStop = AtrTrailingStop(TrailSrc, TrailKey, TrailAtrPeriod)
Calculation: TrailDir = 1 if TrailSrc[1] < TrailStop[1] AND TrailSrc > TrailStop[1], -1 if TrailSrc[1] > TrailStop[1] AND TrailSrc < TrailStop[1], otherwise TrailDir[1]
Long: TrailSrc crosses above TrailStop
Short: TrailSrc crosses below TrailStop
Long: TrailDir = 1 AND close >= TrailStop + StopProximityAtr * ATR(TrailAtrPeriod)
Short: TrailDir = -1 AND close <= TrailStop - StopProximityAtr * ATR(TrailAtrPeriod)