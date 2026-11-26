Calculation: ORBHigh = max(high) over bars whose time is inside the opening-range window of the current day
Calculation: ORBLow = min(low) over bars whose time is inside the opening-range window of the current day
Calculation: ORBMid = (ORBHigh + ORBLow) / 2
Calculation: UpBreak = close crosses above ORBHigh AND bar time is at or after the opening-range window end on the current day
Calculation: DownBreak = close crosses below ORBLow AND bar time is at or after the opening-range window end on the current day
Calculation: UpPending = UpBreak occurred on one of the RetestTimeout bars before the current bar on the current day AND close was above ORBHigh on every bar from that UpBreak bar through the previous bar
Calculation: DownPending = DownBreak occurred on one of the RetestTimeout bars before the current bar on the current day AND close was below ORBLow on every bar from that DownBreak bar through the previous bar
Calculation: RetestLevel(side) = ORBMid if EntryMode = EM3, otherwise ORBHigh if side is Long or ORBLow if side is Short
Calculation: StopLevel(side) = ORBMid if StopMethod = SM1; ORBLow if side is Long and StopMethod = SM2; ORBHigh if side is Short and StopMethod = SM2; EntryPrice - sign * StopDistance if StopMethod = SM3, where sign = +1 for Long and -1 for Short
Calculation: Target(side, k) = EntryPrice + sign * abs(EntryPrice - StopLevel(side)) * RR_k, where sign = +1 for Long and -1 for Short
Calculation: SwingBias(T, L) = on bars of T, Bullish if newest confirmed PivotHigh(high, L, L) > prior confirmed PivotHigh AND newest confirmed PivotLow(low, L, L) > prior confirmed PivotLow; Bearish if newest PivotHigh < prior PivotHigh AND newest PivotLow < prior PivotLow; otherwise Neutral; chart bars take the value of the last completed T bar
Calculation: Threshold = running mean of (high - low) / low over all bars so far if AutoThreshold is on, otherwise FVGThreshold / 100
Long: TradeSignalsEnabled AND EntryMode = EM1 AND UpBreak AND no entry earlier today
Long: TradeSignalsEnabled AND EntryMode != EM1 AND UpPending AND low <= RetestLevel(Long) AND close > ORBHigh AND no entry earlier today
Short: TradeSignalsEnabled AND EntryMode = EM1 AND DownBreak AND no entry earlier today
Short: TradeSignalsEnabled AND EntryMode != EM1 AND DownPending AND high >= RetestLevel(Short) AND close < ORBLow AND no entry earlier today
Long: low > high[2] AND close[1] > high[2] AND (low - high[2]) / high[2] > Threshold
Short: high < low[2] AND close[1] < low[2] AND (low[2] - high) / high > Threshold
Long: SwingBias(T1, L) = Bullish
Long: SwingBias(T2, L) = Bullish
Short: SwingBias(T1, L) = Bearish
Short: SwingBias(T2, L) = Bearish
Exit: Long, low <= StopLevel(Long)
Exit: Long, high >= Target(Long, 1)
Exit: Long, high >= Target(Long, 2)
Exit: Long, high >= Target(Long, 3)
Exit: Long, MoveToBEEnabled AND low <= EntryPrice AND highest high over bars after entry and before the current bar >= Target(Long, 1)
Exit: Short, high >= StopLevel(Short)
Exit: Short, low <= Target(Short, 1)
Exit: Short, low <= Target(Short, 2)
Exit: Short, low <= Target(Short, 3)
Exit: Short, MoveToBEEnabled AND high >= EntryPrice AND lowest low over bars after entry and before the current bar <= Target(Short, 1)