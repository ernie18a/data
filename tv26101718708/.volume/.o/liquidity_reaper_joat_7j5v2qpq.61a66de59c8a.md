Calculation: Confirmed swing high/low = a high/low greater than/less than the highs/lows of the configured number of bars on both sides; confirm after the bars on the right have completed
Calculation: Live liquidity pools = confirmed swing highs/lows, each removed when price trades above/below its level; retain at most the configured number per side, removing the oldest first
Calculation: Pending sweep = when high > a live swing-high pool or low < a live swing-low pool, record its level, raid bar, raid-bar range, and wick extreme; update the extreme through each pending bar and expire after the configured confirmation window; eligible on bars 1 through that window after the raid
Calculation: Rejection wick = for a high-side sweep, (highest high since raid − pool level) / raid-bar range; for a low-side sweep, (pool level − lowest low since raid) / raid-bar range
Calculation: Volume expansion = current volume ≥ its moving average × configured multiplier
Long: pending low-side sweep is 1 to the configured confirmation-window bars old AND close > swept level AND close > open AND low-side rejection wick ≥ configured minimum AND volume expansion
Short: pending high-side sweep is 1 to the configured confirmation-window bars old AND close < swept level AND close < open AND high-side rejection wick ≥ configured minimum AND volume expansion
Calculation: Risk distance = configured ATR × stop multiplier, or entry price × stop percentage, according to the selected stop mode
Calculation: Long stop = entry price − risk distance; long final target = entry price + risk distance × the farthest enabled configured risk/reward target (TP1–TP3)
Calculation: Short stop = entry price + risk distance; short final target = entry price − risk distance × the farthest enabled configured risk/reward target (TP1–TP3)
Exit: long, a bar after entry AND (low ≤ long stop OR high ≥ long final target)
Exit: short, a bar after entry AND (high ≥ short stop OR low ≤ short final target)