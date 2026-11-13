Calculation: ADX = standard Average Directional Index (DMI-based, Wilder smoothing) on chart-timeframe bars
Calculation: ProfitPct = (close - entry price) / entry price, evaluated on each completed bar
Calculation: TrailStop = running maximum since entry of StepLevel, where StepLevel = entry price * B if ProfitPct >= T2; else entry price if ProfitPct >= T1; else entry price * S (T1 < T2, S < 1 < B). StepLevel is updated at each bar close and TrailStop applies from the next bar on; it never decreases
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) (previous bar fast <= slow, current bar fast > slow) AND ADX >= threshold AND no position is open
Exit: long, high >= entry price * TP (TP > 1, TP > B) OR low <= TrailStop