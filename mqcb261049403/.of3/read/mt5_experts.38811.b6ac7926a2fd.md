Calculation: r = RSI(close, RSI lookback) on T1 bars at the selected signal bar (current forming or last completed)
Calculation: m = MA(r, MA lookback) on T1 bars at the selected signal bar
Long: (normal signal direction AND r crosses above m AND r and m are both below the threshold) OR (reversed signal direction AND r crosses below m AND r and m are both above the threshold)
Short: (normal signal direction AND r crosses below m AND r and m are both above the threshold) OR (reversed signal direction AND r crosses above m AND r and m are both below the threshold)