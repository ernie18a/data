Calculation: BodyPercent = 100 * abs(close - open) / (high - low)
Calculation: StopDistance = stop ticks * tick size
Calculation: TargetDistance = StopDistance * reward-to-risk ratio
Calculation: ZoneHalfWidth = zone half-width * tick size
Calculation: PivotState = 0 if close[pivot lookback] > highest(close, pivot lookback), 1 if close[pivot lookback] < lowest(close, pivot lookback), otherwise PivotState[1]
Calculation: ResistanceTop = high[pivot lookback] evaluated on the most recent bar where PivotState becomes 0 + ZoneHalfWidth
Calculation: ResistanceBottom = high[pivot lookback] evaluated on the most recent bar where PivotState becomes 0 - ZoneHalfWidth
Calculation: SupportTop = low[pivot lookback] evaluated on the most recent bar where PivotState becomes 1 + ZoneHalfWidth
Calculation: SupportBottom = low[pivot lookback] evaluated on the most recent bar where PivotState becomes 1 - ZoneHalfWidth
Calculation: ResistanceTouch = low <= ResistanceTop AND high >= ResistanceBottom
Calculation: ResistanceFirstCloseAbove = earliest bar x from the most recent bar where PivotState becomes 0 through t with close(x) > ResistanceTop
Calculation: ResistanceFlipRetest = ResistanceFirstCloseAbove exists AND 1 <= bars since ResistanceFirstCloseAbove <= S/R retest window bars AND ResistanceTouch AND close > ResistanceBottom
Calculation: SupportTouch = low <= SupportTop AND high >= SupportBottom
Calculation: SupportFirstCloseBelow = earliest bar x from the most recent bar where PivotState becomes 1 through t with close(x) < SupportBottom
Calculation: SupportFlipRetest = SupportFirstCloseBelow exists AND 1 <= bars since SupportFirstCloseBelow <= S/R retest window bars AND SupportTouch AND close < SupportTop
Calculation: InTradingSession = (Session 1 enabled AND bar datetime in session timezone within Session 1 window) OR (Session 2 enabled AND bar datetime in session timezone within Session 2 window) OR (Session 3 enabled AND bar datetime in session timezone within Session 3 window) OR (Session 4 enabled AND bar datetime in session timezone within Session 4 window)
Calculation: LongEntryReady = position flat AND (close(T1, last completed bar) crosses above EMA(close, shorter lookback, T1, last completed bar) OR allow-continuation flag) AND close(T1, last completed bar) > EMA(close, shorter lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND (NOT trend-filter flag OR ADX(DI length, smoothing length) >= ADX threshold) AND (NOT impulse-filter flag OR (close > open AND BodyPercent >= min body percent)) AND InTradingSession AND (NOT S/R-flip-filter flag OR NOT ResistanceTouch OR ResistanceFlipRetest)
Calculation: ShortEntryReady = position flat AND (close(T1, last completed bar) crosses below EMA(close, shorter lookback, T1, last completed bar) OR allow-continuation flag) AND close(T1, last completed bar) < EMA(close, shorter lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND (NOT trend-filter flag OR ADX(DI length, smoothing length) >= ADX threshold) AND (NOT impulse-filter flag OR (close < open AND BodyPercent >= min body percent)) AND InTradingSession AND (NOT S/R-flip-filter flag OR NOT SupportTouch OR SupportFlipRetest)
Calculation: UpFVGRetestPending = there is a bar b among the latest max stored FVGs formations of either side with low(b) > high(b-2), where top = low(b) and bottom = high(b-2), such that: r is the first bar x with b < x < t where low(x) <= top AND high(x) >= bottom AND (NOT retest-depth flag OR (top - low(x)) / (top - bottom) * 100 <= max retest depth percent), and r exists; every bar x with b < x < t satisfies min(open(x), close(x)) >= bottom AND (NOT FVG-age flag OR x - b <= max FVG age bars); and no bar x with r < x < t satisfies LongEntryReady(x)
Calculation: DownFVGRetestPending = there is a bar b among the latest max stored FVGs formations of either side with high(b) < low(b-2), where top = low(b-2) and bottom = high(b), such that: r is the first bar x with b < x < t where low(x) <= top AND high(x) >= bottom AND (NOT retest-depth flag OR (high(x) - bottom) / (top - bottom) * 100 <= max retest depth percent), and r exists; every bar x with b < x < t satisfies max(open(x), close(x)) <= top AND (NOT FVG-age flag OR x - b <= max FVG age bars); and no bar x with r < x < t satisfies ShortEntryReady(x)
Calculation: LongArmed = position is long AND (LongArmed[1] OR high >= entry price + TargetDistance * arm share)
Calculation: ShortArmed = position is short AND (ShortArmed[1] OR low <= entry price - TargetDistance * arm share)
Long: LongEntryReady AND UpFVGRetestPending
Short: ShortEntryReady AND DownFVGRetestPending
Exit: long, high >= entry price + TargetDistance
Exit: long, LongArmed[1] AND low <= entry price + TargetDistance * lock share
Exit: long, NOT LongArmed[1] AND low <= entry price - StopDistance
Exit: short, low <= entry price - TargetDistance
Exit: short, ShortArmed[1] AND high >= entry price - TargetDistance * lock share
Exit: short, NOT ShortArmed[1] AND high >= entry price + StopDistance