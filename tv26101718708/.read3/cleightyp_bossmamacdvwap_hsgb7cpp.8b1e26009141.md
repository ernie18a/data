Calculation: Lookback = IF NOT AutoAdjustLookback THEN PivotLookback ELSE IF chart timeframe >= T1 THEN max(PivotLookback, LookbackFloorT1) ELSE IF chart timeframe >= T2 THEN max(PivotLookback, LookbackFloorT2) ELSE IF chart timeframe >= T3 THEN max(PivotLookback, LookbackFloorT3) ELSE PivotLookback
Calculation: StructureStart = IF ResetStructureDaily THEN first bar of the current T1 period ELSE first bar of the data
Calculation: LastPivotHigh = most recent non-na PivotHigh(high, Lookback, Lookback) value confirmed at or after StructureStart
Calculation: LastPivotLow = most recent non-na PivotLow(low, Lookback, Lookback) value confirmed at or after StructureStart
Calculation: LongReach = IF EnterOnTick THEN high >= LastPivotHigh ELSE close > LastPivotHigh
Calculation: ShortReach = IF EnterOnTick THEN low <= LastPivotLow ELSE close < LastPivotLow
Calculation: LongArmed = LastPivotHigh exists AND no bar from the confirmation bar of LastPivotHigh through the previous bar has LongReach
Calculation: ShortArmed = LastPivotLow exists AND no bar from the confirmation bar of LastPivotLow through the previous bar has ShortReach
Calculation: PriorBreak = direction of the latest bar before the current bar, at or after StructureStart, on which LongArmed AND LongReach holds (+1) or ShortArmed AND ShortReach holds (-1); 0 if none
Calculation: Slope(length) = Momentum(SMA(close, length), 1)
Calculation: UpSlopeCount = count of the first SlopeSmaCount of (FastLength, MidLength, SlowLength) with Slope(length) > 0
Calculation: DownSlopeCount = count of the first SlopeSmaCount of (FastLength, MidLength, SlowLength) with Slope(length) < 0
Calculation: BodySize = abs(close - open)
Calculation: WickSize = max(high - low - BodySize, 0)
Calculation: VwapA = VWAP(OHLC4) reset on the first bar at or after VwapAnchorTimeA each day, in VwapTimezoneA
Calculation: VwapB = VWAP(OHLC4) reset on the first bar at or after VwapAnchorTimeB each day, in VwapTimezoneB
Calculation: NewDay = current bar is the first bar of a new T1 period
Calculation: TradesToday = number of trades opened from flat since the first bar of the current T1 period
Calculation: LongEntryPrice = IF EnterOnTick THEN LastPivotHigh ELSE close
Calculation: ShortEntryPrice = IF EnterOnTick THEN LastPivotLow ELSE close
Calculation: LongStop = (IF StopType = SwingStop THEN LastPivotLow ELSE IF StopType = CandleStop THEN low ELSE LongEntryPrice * (1 - StopPercent / 100)) - StopBufferPoints - LongEntryPrice * StopBufferPercent / 100, set on the bar of the long entry decision and held until the position closes
Calculation: ShortStop = (IF StopType = SwingStop THEN LastPivotHigh ELSE IF StopType = CandleStop THEN high ELSE ShortEntryPrice * (1 + StopPercent / 100)) + StopBufferPoints + ShortEntryPrice * StopBufferPercent / 100, set on the bar of the short entry decision and held until the position closes
Calculation: LongTarget = LongEntryPrice + (LongEntryPrice - LongStop) * (IF UseSeparateRR THEN RRLong ELSE RRBoth), set on the bar of the long entry decision and held until the position closes
Calculation: ShortTarget = ShortEntryPrice - (ShortStop - ShortEntryPrice) * (IF UseSeparateRR THEN RRShort ELSE RRBoth), set on the bar of the short entry decision and held until the position closes
Calculation: LongEntryPivot = LastPivotHigh on the latest earlier bar, since the first bar of the current T1 period, on which LongSetup held; none if no such bar
Calculation: ShortEntryPivot = LastPivotLow on the latest earlier bar, since the first bar of the current T1 period, on which ShortSetup held; none if no such bar
Calculation: LongSetup = LongArmed AND (EnterOnTick OR NOT UseStrongCandleFilter OR (close > open AND BodySize >= WickSize * (1 + BodyOverWickPercent / 100))) AND (NOT UseSmaFilter OR (NOT PriceVsSmaFilter AND UpSlopeCount >= MinSlopeCount) OR (PriceVsSmaFilter AND close > SMA(close, FastLength) AND close > SMA(close, MidLength) AND close > SMA(close, SlowLength))) AND (NOT UseSmaStackFilter OR (SMA(close, FastLength) > SMA(close, MidLength) AND SMA(close, MidLength) > SMA(close, SlowLength))) AND (NOT UseSmaDivergeFilter OR (Slope(FastLength) > Slope(MidLength) AND Slope(MidLength) > Slope(SlowLength))) AND (NOT FilterVwapA OR close > VwapA) AND (NOT FilterVwapB OR close > VwapB) AND (PriorBreak != -1 OR NOT BosOnly OR ChochOnly) AND (PriorBreak = -1 OR NOT ChochOnly OR BosOnly) AND (NOT LimitTradesPerDay OR TradesToday < MaxTradesPerDay) AND PositionSide != Long AND (LongEntryPivot is none OR abs(LastPivotHigh - LongEntryPivot) > TickSize) AND LongEntryPrice - LongStop > 0
Calculation: ShortSetup = ShortArmed AND (EnterOnTick OR NOT UseStrongCandleFilter OR (close < open AND BodySize >= WickSize * (1 + BodyOverWickPercent / 100))) AND (NOT UseSmaFilter OR (NOT PriceVsSmaFilter AND DownSlopeCount >= MinSlopeCount) OR (PriceVsSmaFilter AND close < SMA(close, FastLength) AND close < SMA(close, MidLength) AND close < SMA(close, SlowLength))) AND (NOT UseSmaStackFilter OR (SMA(close, FastLength) < SMA(close, MidLength) AND SMA(close, MidLength) < SMA(close, SlowLength))) AND (NOT UseSmaDivergeFilter OR (Slope(FastLength) < Slope(MidLength) AND Slope(MidLength) < Slope(SlowLength))) AND (NOT FilterVwapA OR close < VwapA) AND (NOT FilterVwapB OR close < VwapB) AND (PriorBreak != 1 OR NOT BosOnly OR ChochOnly) AND (PriorBreak = 1 OR NOT ChochOnly OR BosOnly) AND (NOT LimitTradesPerDay OR TradesToday < MaxTradesPerDay) AND PositionSide != Short AND (ShortEntryPivot is none OR abs(LastPivotLow - ShortEntryPivot) > TickSize) AND ShortStop - ShortEntryPrice > 0
Long: EnterOnTick AND LongReach AND LongSetup[1]
Long: NOT EnterOnTick AND LongReach AND LongSetup
Short: EnterOnTick AND ShortReach AND ShortSetup[1]
Short: NOT EnterOnTick AND ShortReach AND ShortSetup
Exit: Long, low <= LongStop OR high >= LongTarget OR (CloseAtEndOfDay AND NewDay)
Exit: Short, high >= ShortStop OR low <= ShortTarget OR (CloseAtEndOfDay AND NewDay)