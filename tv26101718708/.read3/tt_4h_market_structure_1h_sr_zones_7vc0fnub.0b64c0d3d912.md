Calculation: Latest T1 swing high = most recent confirmed Pivot High(high, T1 swing lookback, T1 swing lookback) computed on T1 bars and sampled on chart bars
Calculation: Previous T1 swing high = confirmed Pivot High before the latest T1 swing high
Calculation: Latest T1 swing low = most recent confirmed Pivot Low(low, T1 swing lookback, T1 swing lookback) computed on T1 bars and sampled on chart bars
Calculation: Previous T1 swing low = confirmed Pivot Low before the latest T1 swing low
Calculation: Latest T2 resistance = most recent confirmed Pivot High(high, T2 swing lookback, T2 swing lookback) computed on T2 bars and sampled on chart bars
Calculation: Latest T2 support = most recent confirmed Pivot Low(low, T2 swing lookback, T2 swing lookback) computed on T2 bars and sampled on chart bars
Calculation: Zone bottom(price) = price × (1 − zone width / 2)
Calculation: Zone top(price) = price × (1 + zone width / 2)
Calculation: Market bias = neutral initially; set to the side of each emitted BOS or CHoCH and otherwise retain its prior value
Long: A newly confirmed T1 swing high is above the previous T1 swing high OR a newly confirmed T1 swing low is above the previous T1 swing low
Short: A newly confirmed T1 swing high is below the previous T1 swing high OR a newly confirmed T1 swing low is below the previous T1 swing low
Long: BOS enabled AND Latest T1 swing high exists AND close(T1, lookahead off, sampled on chart bars; last completed bar historically and still-forming bar in realtime) > Latest T1 swing high AND its prior chart-bar sample <= Latest T1 swing high
Short: BOS enabled AND Latest T1 swing low exists AND close(T1, lookahead off, sampled on chart bars; last completed bar historically and still-forming bar in realtime) < Latest T1 swing low AND its prior chart-bar sample >= Latest T1 swing low
Long: CHoCH enabled AND BOS disabled AND Market bias at the start of the chart bar is bearish AND Latest T1 swing high exists AND close(T1, lookahead off, sampled on chart bars; last completed bar historically and still-forming bar in realtime) > Latest T1 swing high AND its prior chart-bar sample <= Latest T1 swing high
Short: CHoCH enabled AND BOS disabled AND Market bias at the start of the chart bar is bullish AND Latest T1 swing low exists AND close(T1, lookahead off, sampled on chart bars; last completed bar historically and still-forming bar in realtime) < Latest T1 swing low AND its prior chart-bar sample >= Latest T1 swing low
Long: Chart-bar high >= Zone bottom(Latest T2 support) AND chart-bar low <= Zone top(Latest T2 support)
Short: Chart-bar high >= Zone bottom(Latest T2 resistance) AND chart-bar low <= Zone top(Latest T2 resistance)