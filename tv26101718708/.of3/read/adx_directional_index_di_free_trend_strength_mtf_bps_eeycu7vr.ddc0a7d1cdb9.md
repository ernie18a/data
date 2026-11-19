Calculation: Chart ADX = SMA(DX, ADX smoothing period), where DX = if DI+ + DI− is nonzero then 100 × abs(DI+ − DI−) / (DI+ + DI−), otherwise 0
Calculation: For each of T1, T2, T3, T4, and T5, DMI = DMI(ADX period, ADX smoothing period, requested-timeframe values on chart bars with lookahead off; developing values in real time and last completed values historically)
Long: DI+(ADX period) crosses above DI−(ADX period) on chart bars
Short: DI+(ADX period) crosses below DI−(ADX period) on chart bars
Long: DI+(ADX period) > DI−(ADX period) on chart bars
Short: DI+(ADX period) ≤ DI−(ADX period) on chart bars
Long: Chart ADX > trend threshold AND DI+(ADX period) > DI−(ADX period) on chart bars
Short: Chart ADX > trend threshold AND DI+(ADX period) ≤ DI−(ADX period) on chart bars
Long: For each of T1, T2, T3, T4, and T5, DI+(ADX period, that timeframe) > DI−(ADX period, that timeframe)
Short: For each of T1, T2, T3, T4, and T5, DI+(ADX period, that timeframe) ≤ DI−(ADX period, that timeframe)
Long: For each of T1, T2, T3, T4, and T5, ADX(ADX period, ADX smoothing period, that timeframe) > trend threshold AND DI+(ADX period, that timeframe) > DI−(ADX period, that timeframe)
Short: For each of T1, T2, T3, T4, and T5, ADX(ADX period, ADX smoothing period, that timeframe) > trend threshold AND DI+(ADX period, that timeframe) ≤ DI−(ADX period, that timeframe)