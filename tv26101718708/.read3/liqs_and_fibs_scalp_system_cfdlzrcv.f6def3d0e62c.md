Calculation: HtfTrend = 1 if T1 close > latest PivotHigh(T1 high, q, q) that is not yet broken; -1 if T1 close < latest PivotLow(T1 low, q, q) that is not yet broken; otherwise HtfTrend[1]; runs on T1 bars, chart bars read the last completed T1 bar
Calculation: BreakUp = close > latest PivotHigh(high, p, p) that is not yet broken
Calculation: BreakDown = close < latest PivotLow(low, p, p) that is not yet broken
Calculation: StructureState = 1 if BreakUp; -1 if BreakDown; otherwise StructureState[1]
Calculation: BullChoch = BreakUp AND StructureState[1] == -1
Calculation: BearChoch = BreakDown AND StructureState[1] == 1
Calculation: SetupFib(r) = A + (B - A) * r, where for the latest BullChoch or BearChoch, A and B are the lowest low and highest high (BullChoch) or the highest high and lowest low (BearChoch) over bars from the broken pivot's bar through that CHoCH bar, fixed at that bar
Calculation: BullSetup = the latest CHoCH is BullChoch AND, on its bar, HtfTrend == 1 AND close >= VWAP
Calculation: BearSetup = the latest CHoCH is BearChoch AND, on its bar, HtfTrend == -1 AND close <= VWAP
Calculation: BullZoneTouch = BullSetup AND low <= max(SetupFib(r_a), SetupFib(r_b)) AND high >= min(SetupFib(r_a), SetupFib(r_b))
Calculation: BearZoneTouch = BearSetup AND low <= max(SetupFib(r_a), SetupFib(r_b)) AND high >= min(SetupFib(r_a), SetupFib(r_b))
Calculation: LowReclaim = for some L among the lows of the last n completed T1 bars, this bar is the first bar with close > L at or after the first bar with low < L
Calculation: HighReclaim = for some H among the highs of the last n completed T1 bars, this bar is the first bar with close < H at or after the first bar with high > H
Calculation: BullPinbar = min(open, close) - low > k * abs(close - open) AND min(open, close) - low > m * ATR(N)
Calculation: BearPinbar = high - max(open, close) > k * abs(close - open) AND high - max(open, close) > m * ATR(N)
Long: BreakUp
Long: BullChoch AND HtfTrend == 1
Long: BullZoneTouch AND NOT BullZoneTouch[1]
Long: LowReclaim AND BullPinbar
Short: BreakDown
Short: BearChoch AND HtfTrend == -1
Short: BearZoneTouch AND NOT BearZoneTouch[1]
Short: HighReclaim AND BearPinbar
Exit: long, low <= SetupFib(r_stop) OR high >= SetupFib(r_tgt1) OR high >= SetupFib(r_tgt2) OR high >= SetupFib(r_tgt3) OR high >= SetupFib(r_tgt4) OR high >= SetupFib(r_tgt5) OR high >= SetupFib(r_tgt6)
Exit: short, high >= SetupFib(r_stop) OR low <= SetupFib(r_tgt1) OR low <= SetupFib(r_tgt2) OR low <= SetupFib(r_tgt3) OR low <= SetupFib(r_tgt4) OR low <= SetupFib(r_tgt5) OR low <= SetupFib(r_tgt6)