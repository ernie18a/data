Calculation: PatternPivots = sequence of PivotHigh(close, P, P) and PivotLow(close, P, P) pivots alternating in type; a new pivot of the same type as the last entry replaces it only if it is at or above it (highs) or at or below it (lows), otherwise it is ignored; a new pivot of the other type is appended
Calculation: WFormed = a pivot was appended or replaced in PatternPivots on this bar AND the last three entries of PatternPivots, oldest to newest, are low, high, low AND ABS(first - third) <= SHOULDER_TOL AND second - (first + third) / 2 >= MIN_DEPTH
Calculation: MFormed = a pivot was appended or replaced in PatternPivots on this bar AND the last three entries of PatternPivots, oldest to newest, are high, low, high AND ABS(first - third) <= SHOULDER_TOL AND (first + third) / 2 - second >= MIN_DEPTH
Calculation: WPendingNeck = middle entry of the latest WFormed pattern, from its formation through the first bar on or after formation where close > middle entry + BREAK_BUF (that bar included); none otherwise
Long: close > WPendingNeck + BREAK_BUF
Calculation: WRetestLevel = WPendingNeck at the latest bar where close > WPendingNeck + BREAK_BUF, for the MAX_WAIT bars after that bar; none from any later bar where WFormed occurs, and none after the first bar where low <= WRetestLevel + RETEST_TOL AND close > WRetestLevel
Long: low <= WRetestLevel + RETEST_TOL AND close > WRetestLevel
Long: WFormed
Calculation: MPendingNeck = middle entry of the latest MFormed pattern, from its formation through the first bar on or after formation where close < middle entry - BREAK_BUF (that bar included); none otherwise
Short: close < MPendingNeck - BREAK_BUF
Calculation: MRetestLevel = MPendingNeck at the latest bar where close < MPendingNeck - BREAK_BUF, for the MAX_WAIT bars after that bar; none from any later bar where MFormed occurs, and none after the first bar where high >= MRetestLevel - RETEST_TOL AND close < MRetestLevel
Short: high >= MRetestLevel - RETEST_TOL AND close < MRetestLevel
Short: MFormed
Calculation: RisingTL = value at the current bar of the line from L to the latest pivot low, extended linearly, where L is the lowest of the TL_LOOKBACK pivot lows immediately preceding the latest one that lie below it (TL_MODE recent: only the immediately preceding pivot low, if below); updated when a new pivot low is stored and such an L exists, otherwise kept; pivot lows = PivotLow(source TL_SRC, TL_LEFT, TL_RIGHT) on T1 bars, one per pivot bar, read on chart bars as the last completed T1 bar
Calculation: FallingTL = value at the current bar of the line from U to the latest pivot high, extended linearly, where U is the highest of the TL_LOOKBACK pivot highs immediately preceding the latest one that lie above it (TL_MODE recent: only the immediately preceding pivot high, if above); updated when a new pivot high is stored and such a U exists, otherwise kept; pivot highs = PivotHigh(source TL_SRC, TL_LEFT, TL_RIGHT) on T1 bars, one per pivot bar, read on chart bars as the last completed T1 bar
Short: close crosses under RisingTL - TL_BUF
Long: close crosses over FallingTL + TL_BUF