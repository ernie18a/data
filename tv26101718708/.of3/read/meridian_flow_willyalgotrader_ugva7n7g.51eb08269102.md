Calculation: BreakPrice(x) = x or close, per break-source parameter
Calculation: SwingHigh = latest PivotHigh(swing lookback, swing lookback) value, carried forward
Calculation: SwingLow = latest PivotLow(swing lookback, swing lookback) value, carried forward
Calculation: Warm = bar index >= max(2 * swing lookback, warmup bars)
Calculation: UpRaw = BreakPrice(high) > SwingHigh AND no UpBreak from SwingHigh confirmation bar to previous bar
Calculation: DownRaw = BreakPrice(low) < SwingLow AND no DownBreak from SwingLow confirmation bar to previous bar
Calculation: UpBreak = UpRaw AND NOT DownRaw AND Warm
Calculation: DownBreak = DownRaw AND NOT UpRaw AND Warm
Calculation: TrendState = 1 on UpBreak, -1 on DownBreak, otherwise TrendState[1]; 0 before any break
Calculation: StopDistance = ATR(SL length) * SL multiplier
Calculation: RLevel(m) = entry + side * m * StopDistance, with StopDistance at entry bar, side = 1 for long and -1 for short
Calculation: StopLevel = entry if break-even enabled AND RLevel(TP1 multiple) touched on a bar after the entry bar and before this bar, else RLevel(-1)
Long: UpBreak AND ((BOS signal enabled AND TrendState[1] >= 0) OR (CHoCH signal enabled AND TrendState[1] < 0)) AND (HTF filter disabled OR close >= EMA(close, HTF EMA length, T1, last completed bar)) AND position side[1] = flat AND StopDistance > 0
Short: DownBreak AND ((BOS signal enabled AND TrendState[1] <= 0) OR (CHoCH signal enabled AND TrendState[1] > 0)) AND (HTF filter disabled OR close <= EMA(close, HTF EMA length, T1, last completed bar)) AND position side[1] = flat AND StopDistance > 0
Exit: long, position side[1] = long AND (low <= StopLevel OR high >= RLevel(TP3 multiple))
Exit: short, position side[1] = short AND (high >= StopLevel OR low <= RLevel(TP3 multiple))