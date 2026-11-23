Calculation: WT1 = WaveTrend(source, channel length, average length)
Calculation: WT2 = SMA(WT1, signal length)
Calculation: T1 WT1 = WaveTrend(source, channel length, average length) on T1 bars; chart bars take the last completed T1 bar, or the still-forming T1 bar when repaint allowed
Calculation: T1 WT2 = SMA(T1 WT1, signal length) on T1 bars; chart bars take the last completed T1 bar, or the still-forming T1 bar when repaint allowed
Calculation: OB level = zone mode selects static upper level, percentile nearest rank(WT1, lookback, upper percentile), or SMA(WT1, lookback) + stdev(WT1, lookback) * stdev multiplier
Calculation: OS level = zone mode selects static lower level, percentile nearest rank(WT1, lookback, lower percentile), or SMA(WT1, lookback) - stdev(WT1, lookback) * stdev multiplier
Calculation: WT pivot low = pivot low(WT1, pivot left bars, pivot right bars)
Calculation: WT pivot high = pivot high(WT1, pivot left bars, pivot right bars)
Calculation: regular bullish divergence = WT pivot low confirmed on this bar AND bars between this and previous WT pivot lows is at least minimum pivot gap AND at most maximum pivot gap AND low at this WT pivot low bar < low at previous WT pivot low bar AND WT pivot low > previous WT pivot low AND (NOT zone-only restriction OR WT pivot low <= OS level OR previous WT pivot low <= OS level)
Calculation: regular bearish divergence = WT pivot high confirmed on this bar AND bars between this and previous WT pivot highs is at least minimum pivot gap AND at most maximum pivot gap AND high at this WT pivot high bar > high at previous WT pivot high bar AND WT pivot high < previous WT pivot high AND (NOT zone-only restriction OR WT pivot high >= OB level OR previous WT pivot high >= OB level)
Long: WT1 crosses above WT2 AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 > T1 WT2)
Long: WT1 crosses above WT2 AND WT1 < OS level AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 > T1 WT2)
Long: WT1 crosses above WT2 AND WT1 < OS level AND (NOT MTF enabled OR T1 WT1 > T1 WT2)
Long: regular bullish divergence AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 > T1 WT2)
Long: regular bullish divergence
Long: WT pivot low confirmed on this bar AND bars between this and previous WT pivot lows is at least minimum pivot gap AND at most maximum pivot gap AND low at this WT pivot low bar > low at previous WT pivot low bar AND WT pivot low < previous WT pivot low AND (NOT zone-only restriction OR WT pivot low <= OS level OR previous WT pivot low <= OS level)
Long: WT1 > WT2
Long: MTF enabled AND T1 WT1 > T1 WT2
Long: regular bullish divergence occurred on any of the last recent-window length bars, including the current bar
Short: WT1 crosses below WT2 AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 < T1 WT2)
Short: WT1 crosses below WT2 AND WT1 > OB level AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 < T1 WT2)
Short: WT1 crosses below WT2 AND WT1 > OB level AND (NOT MTF enabled OR T1 WT1 < T1 WT2)
Short: regular bearish divergence AND (NOT MTF agreement required OR NOT MTF enabled OR T1 WT1 < T1 WT2)
Short: regular bearish divergence
Short: WT pivot high confirmed on this bar AND bars between this and previous WT pivot highs is at least minimum pivot gap AND at most maximum pivot gap AND high at this WT pivot high bar < high at previous WT pivot high bar AND WT pivot high > previous WT pivot high AND (NOT zone-only restriction OR WT pivot high >= OB level OR previous WT pivot high >= OB level)
Short: WT1 <= WT2
Short: MTF enabled AND T1 WT1 <= T1 WT2
Short: regular bearish divergence occurred on any of the last recent-window length bars, including the current bar AND NOT regular bullish divergence occurred on any of the last recent-window length bars, including the current bar