Calculation: OpeningRangeHigh = highest high of the session's bars within the first range length minutes after session open
Calculation: OpeningRangeLow = lowest low of the session's bars within the first range length minutes after session open
Calculation: RangeDirection = up if the close of the first bar at or after the end of the range window is above the session's first open, down if it is below
Calculation: LongBreak = close > OpeningRangeHigh AND (NOT confirmation enabled OR close[1] > OpeningRangeHigh) AND (NOT range-direction filter enabled OR RangeDirection = up)
Calculation: ShortBreak = close < OpeningRangeLow AND (NOT confirmation enabled OR close[1] < OpeningRangeLow) AND (NOT range-direction filter enabled OR RangeDirection = down)
Calculation: FirstBreak = long or short according to which of LongBreak or ShortBreak holds on the first bar of the session where either holds; none before that bar
Calculation: FailedBreak = fade enabled AND ((FirstBreak = long AND some close at or after the first break's bar is below OpeningRangeHigh) OR (FirstBreak = short AND some close at or after the first break's bar is above OpeningRangeLow))
Calculation: RetestHold = retest enabled AND, on some bar of the session at or before this bar, NOT FailedBreak AND ((FirstBreak = long AND low <= OpeningRangeHigh AND close > OpeningRangeHigh) OR (FirstBreak = short AND high >= OpeningRangeLow AND close < OpeningRangeLow))
Calculation: BreakStop = stop level set on the first break's bar: if FirstBreak = long, the stop mode selects OpeningRangeLow, the midpoint of the opening range, or close - stop ATR multiple * ATR(ATR length); if FirstBreak = short, it selects OpeningRangeHigh, the midpoint, or close + stop ATR multiple * ATR(ATR length)
Calculation: BreakTarget1 = target level set on the first break's bar: if FirstBreak = long, the target basis gives OpeningRangeHigh + target-1 multiple * (OpeningRangeHigh - OpeningRangeLow) for range multiples or close + target-1 multiple * |close - BreakStop| for R multiples; if FirstBreak = short, it gives OpeningRangeLow - target-1 multiple * (OpeningRangeHigh - OpeningRangeLow) or close - target-1 multiple * |close - BreakStop|
Calculation: FailureExtreme = over the bars from the first break's bar through the first bar where FailedBreak holds, the highest high if FirstBreak = long, otherwise the lowest low
Calculation: PriorHigh(T) = high of the last completed bar of timeframe T, taken on chart bars; T1 is shorter than T2
Calculation: PriorLow(T) = low of the last completed bar of timeframe T, taken on chart bars
Calculation: UpperSweep(L) = high - L >= sweep wick multiple * ATR(ATR length) AND close < L
Calculation: LowerSweep(L) = L - low >= sweep wick multiple * ATR(ATR length) AND close > L
Long: LongBreak AND FirstBreak[1] = none
Short: ShortBreak AND FirstBreak[1] = none
Long: FailedBreak AND NOT FailedBreak[1] AND FirstBreak = short
Short: FailedBreak AND NOT FailedBreak[1] AND FirstBreak = long
Long: RetestHold AND NOT RetestHold[1] AND FirstBreak = long
Short: RetestHold AND NOT RetestHold[1] AND FirstBreak = short
Long: LowerSweep(PriorLow(T1)) AND liquidity-sweep detection enabled
Long: LowerSweep(PriorLow(T2)) AND liquidity-sweep detection enabled
Short: UpperSweep(PriorHigh(T1)) AND liquidity-sweep detection enabled
Short: UpperSweep(PriorHigh(T2)) AND liquidity-sweep detection enabled
Exit: long, FirstBreak = long AND high >= BreakTarget1
Exit: long, FirstBreak = long AND low <= BreakStop
Exit: long, FirstBreak = short AND FailedBreak AND high >= OpeningRangeHigh
Exit: long, FirstBreak = short AND FailedBreak AND low <= FailureExtreme
Exit: short, FirstBreak = short AND low <= BreakTarget1
Exit: short, FirstBreak = short AND high >= BreakStop
Exit: short, FirstBreak = long AND FailedBreak AND low <= OpeningRangeLow
Exit: short, FirstBreak = long AND FailedBreak AND high >= FailureExtreme
Exit: long, session of the bar differs from session of the previous bar
Exit: short, session of the bar differs from session of the previous bar