Calculation: SessionBar = 0 if bar time is in neither LONDON_ENTRY_WINDOW nor NY_ENTRY_WINDOW (in TZ); 1 if bar time is in one of them and the previous bar is not in that same window; otherwise SessionBar[1] + 1
Calculation: OpeningRangeHigh = MAX(high) over bars of the current session with SessionBar <= OR_BARS
Calculation: OpeningRangeLow = MIN(low) over bars of the current session with SessionBar <= OR_BARS
Calculation: InsideRange = SessionBar > OR_BARS AND OpeningRangeLow < close < OpeningRangeHigh
Calculation: CloseLocation = (close - low) / (high - low)
Calculation: LongBreakout = SessionBar > OR_BARS AND close > OpeningRangeHigh AND close > open AND CloseLocation >= BREAKOUT_CLOSE_STRENGTH AND close - open >= MIN_BODY_ATR * ATR(ATR_LEN) AND (NOT USE_VWAP_FILTER OR close > VWAP(HLC3))
Calculation: ShortBreakout = SessionBar > OR_BARS AND close < OpeningRangeLow AND close < open AND CloseLocation <= 1 - BREAKOUT_CLOSE_STRENGTH AND open - close >= MIN_BODY_ATR * ATR(ATR_LEN) AND (NOT USE_VWAP_FILTER OR close < VWAP(HLC3))
Calculation: EquityPnL = closed net profit + open profit
Calculation: PeakEquityPnL = MAX(PeakEquityPnL[1], EquityPnL)
Calculation: DrawdownFromPeak = PeakEquityPnL - EquityPnL
Calculation: EvalLatch = EvalLatch[1] OR EquityPnL >= PROFIT_TARGET OR DrawdownFromPeak >= TRAILING_DRAW_LIMIT - DRAW_SAFETY_BUFFER
Calculation: DrawRoom = TRAILING_DRAW_LIMIT - DrawdownFromPeak
Calculation: TradingAllowed = NOT EvalLatch AND DrawRoom > MAX_RISK_PER_TRADE + DRAW_SAFETY_BUFFER
Calculation: LongEnabled = no LongStore on any bar after the latest reset bar and before the current bar, where a reset bar has SessionBar <= 1 OR (InsideRange AND position flat)
Calculation: ShortEnabled = no ShortStore on any bar after the latest reset bar and before the current bar, where a reset bar has SessionBar <= 1 OR (InsideRange AND position flat)
Calculation: LongStore = LongBreakout AND position flat AND TradingAllowed AND LongEnabled
Calculation: ShortStore = ShortBreakout AND position flat AND TradingAllowed AND ShortEnabled
Calculation: BarsSinceStore = bars since the latest LongStore or ShortStore, 0 on that bar
Calculation: LongStopLevel = OpeningRangeHigh[DELAY_BARS] - ATR(ATR_LEN) * STOP_BUFFER_ATR
Calculation: ShortStopLevel = OpeningRangeLow[DELAY_BARS] + ATR(ATR_LEN) * STOP_BUFFER_ATR
Calculation: LongStopDistance = close - LongStopLevel
Calculation: ShortStopDistance = ShortStopLevel - close
Calculation: LongContracts = floor(MIN(RISK_PER_TRADE, MAX_RISK_PER_TRADE) / (LongStopDistance * POINT_VALUE)) if LongStopDistance > 0, else 0
Calculation: ShortContracts = floor(MIN(RISK_PER_TRADE, MAX_RISK_PER_TRADE) / (ShortStopDistance * POINT_VALUE)) if ShortStopDistance > 0, else 0
Calculation: LongTargetDistance = MIN(LongStopDistance * TARGET_RR, MAX_PROFIT_PER_TRADE / (LongContracts * POINT_VALUE))
Calculation: ShortTargetDistance = MIN(ShortStopDistance * TARGET_RR, MAX_PROFIT_PER_TRADE / (ShortContracts * POINT_VALUE))
Calculation: LongStopOriginal = LongStopLevel on the most recent bar where the Long condition holds
Calculation: LongTarget = close + LongTargetDistance on the most recent bar where the Long condition holds
Calculation: ShortStopOriginal = ShortStopLevel on the most recent bar where the Short condition holds
Calculation: ShortTarget = close - ShortTargetDistance on the most recent bar where the Short condition holds
Calculation: LongHigh = MAX(high) over bars after the most recent bar where the Long condition holds, through the current bar
Calculation: ShortLow = MIN(low) over bars after the most recent bar where the Short condition holds, through the current bar
Calculation: LongR = EntryPrice - LongStopOriginal
Calculation: ShortR = ShortStopOriginal - EntryPrice
Calculation: LongLiveStop = MAX over LongStopOriginal and each of these candidates whose condition holds: EntryPrice + BE_OFFSET_TICKS * TICK_SIZE if LongHigh >= EntryPrice + BE_TRIGGER_R * LongR; EntryPrice + LOCK1_LEVEL_R * LongR if LongHigh >= EntryPrice + LOCK1_TRIGGER_R * LongR; EntryPrice + LOCK2_LEVEL_R * LongR if LongHigh >= EntryPrice + LOCK2_TRIGGER_R * LongR; EntryPrice + DOLLAR_LOCK_i / (POINT_VALUE * POSITION_QTY) for i in 1..3 if USE_DOLLAR_LOCK AND (LongHigh - EntryPrice) * POINT_VALUE * POSITION_QTY >= DOLLAR_TRIGGER_i
Calculation: ShortLiveStop = MIN over ShortStopOriginal and each of these candidates whose condition holds: EntryPrice - BE_OFFSET_TICKS * TICK_SIZE if ShortLow <= EntryPrice - BE_TRIGGER_R * ShortR; EntryPrice - LOCK1_LEVEL_R * ShortR if ShortLow <= EntryPrice - LOCK1_TRIGGER_R * ShortR; EntryPrice - LOCK2_LEVEL_R * ShortR if ShortLow <= EntryPrice - LOCK2_TRIGGER_R * ShortR; EntryPrice - DOLLAR_LOCK_i / (POINT_VALUE * POSITION_QTY) for i in 1..3 if USE_DOLLAR_LOCK AND (EntryPrice - ShortLow) * POINT_VALUE * POSITION_QTY >= DOLLAR_TRIGGER_i
Long: BarsSinceStore = DELAY_BARS AND LongStore[DELAY_BARS] AND SessionBar >= 1 AND position flat AND TradingAllowed AND LongStopDistance >= MIN_STOP_POINTS AND LongStopDistance <= MAX_STOP_POINTS AND LongContracts >= 1 AND LongContracts * LongStopDistance * POINT_VALUE < DrawRoom - DRAW_SAFETY_BUFFER AND close > OpeningRangeHigh[DELAY_BARS] AND close <= close[DELAY_BARS] + (close[DELAY_BARS] - LongStopLevel) * MAX_CHASE_R AND LongTargetDistance >= LongStopDistance * MIN_TARGET_RR
Short: BarsSinceStore = DELAY_BARS AND ShortStore[DELAY_BARS] AND SessionBar >= 1 AND position flat AND TradingAllowed AND ShortStopDistance >= MIN_STOP_POINTS AND ShortStopDistance <= MAX_STOP_POINTS AND ShortContracts >= 1 AND ShortContracts * ShortStopDistance * POINT_VALUE < DrawRoom - DRAW_SAFETY_BUFFER AND close < OpeningRangeLow[DELAY_BARS] AND close >= close[DELAY_BARS] - (ShortStopLevel - close[DELAY_BARS]) * MAX_CHASE_R AND ShortTargetDistance >= ShortStopDistance * MIN_TARGET_RR
Exit: long, low <= LongLiveStop[1]
Exit: long, high >= LongTarget
Exit: long, bar outside LONDON_MANAGE_WINDOW AND outside NY_MANAGE_WINDOW
Exit: long, EvalLatch
Exit: short, high >= ShortLiveStop[1]
Exit: short, low <= ShortTarget
Exit: short, bar outside LONDON_MANAGE_WINDOW AND outside NY_MANAGE_WINDOW
Exit: short, EvalLatch