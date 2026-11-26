Calculation: T1High = high(T1, last completed bar), on chart bars
Calculation: T1Low = low(T1, last completed bar), on chart bars
Calculation: MidnightOpen = open of the latest chart bar starting at midnight New York time
Calculation: InSession = bar time lies in a selected session window (DST-adjusted), or true when no session is selected
Calculation: NewWindow = a session window starts on this bar when every session is selected, otherwise this bar is the midnight bar
Calculation: LongLevel = max of open[k-1] and open[k-2], using only offsets >= 0, where k = nearest offset in 1..candle lookback with close > open; updated when close < T1Low AND close < MidnightOpen AND InSession AND such k exists AND (first-only switch is off OR no LongLevel update on or after the last NewWindow); otherwise unchanged
Calculation: LongLevelAge = bars since the bar whose open is LongLevel (older bar on ties)
Calculation: ShortLevel = min of open[k-1] and open[k-2], using only offsets >= 0, where k = nearest offset in 1..candle lookback with close < open; updated when close > T1High AND close > MidnightOpen AND InSession AND such k exists AND (first-only switch is off OR no ShortLevel update on or after the last NewWindow); otherwise unchanged
Calculation: ShortLevelAge = bars since the bar whose open is ShortLevel (older bar on ties)
Calculation: BullishSMT = ((L1 < L0 AND C1 > C0) OR (L1 > L0 AND C1 < C0)) AND bars since B1 < recency window AND B1 - B0 < spacing window AND two pivot lows exist; L1, B1 = chart low and bar of the last PivotLow(low, pivot half-window, pivot half-window); L0, B0 = same for the previous pivot low; C1, C0 = correlated-instrument low on chart bars at B1, B0
Calculation: BearishSMT = ((H1 > H0 AND C1 < C0) OR (H1 < H0 AND C1 > C0)) AND bars since B1 < recency window AND B1 - B0 < spacing window AND two pivot highs exist; H1, B1 = chart high and bar of the last PivotHigh(high, pivot half-window, pivot half-window); H0, B0 = same for the previous pivot high; C1, C0 = correlated-instrument high on chart bars at B1, B0
Long: close >= LongLevel AND LongLevelAge <= validity window, first such bar at or after the last LongLevel update
Long: BullishSMT AND close < T1Low AND close < MidnightOpen AND InSession
Short: close <= ShortLevel AND ShortLevelAge <= validity window, first such bar at or after the last ShortLevel update
Short: BearishSMT AND close > T1High AND close > MidnightOpen AND InSession