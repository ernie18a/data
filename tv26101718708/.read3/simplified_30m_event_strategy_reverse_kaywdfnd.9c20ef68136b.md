Calculation: latest pivot high = most recent non-na PivotHigh(T1 high sampled on chart bars, left pivot lookback in chart bars, right pivot lookback in chart bars), using the current forming T1 bar in realtime and the latest completed T1 bar otherwise
Calculation: latest pivot low = most recent non-na PivotLow(T1 low sampled on chart bars, left pivot lookback in chart bars, right pivot lookback in chart bars), using the current forming T1 bar in realtime and the latest completed T1 bar otherwise
Calculation: volume delta = volume when close > open, -volume when close < open, and 0 otherwise
Long: latest pivot high and latest pivot low exist AND latest pivot high - latest pivot low >= minimum pivot range AND close > latest pivot low AND volume delta < 0
Short: latest pivot high and latest pivot low exist AND latest pivot high - latest pivot low >= minimum pivot range AND close < latest pivot high AND volume delta > 0
Exit: long, long position has been held for at least exit bar count chart bars
Exit: short, short position has been held for at least exit bar count chart bars