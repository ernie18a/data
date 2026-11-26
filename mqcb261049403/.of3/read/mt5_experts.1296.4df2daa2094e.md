Calculation: H = MACD histogram(applied price, fast MA type, fast lookback, slow MA type, slow lookback) on T1 bars, using completed bars
Calculation: S = moving average of H (signal MA type, signal lookback) on T1 bars, using completed bars
Calculation: N = NonLag moving average(dot applied price, dot deviation) on chart bars
Calculation: D = +1 if N - N[1] > dot filter threshold; -1 if N[1] - N > dot filter threshold; otherwise D[1]
Long: D = +1
Short: D = -1
Long: H on the latest completed T1 bar > 0
Short: H on the latest completed T1 bar < 0
Long: H on the latest completed T1 bar > S one T1 bar earlier
Short: H on the latest completed T1 bar < S one T1 bar earlier
Long: H at the selected signal-bar offset > 0 AND H one T1 bar earlier <= 0
Short: H at the selected signal-bar offset < 0 AND H one T1 bar earlier >= 0
Long: H at the selected signal-bar offset > H one T1 bar earlier AND H two T1 bars earlier > H one T1 bar earlier
Short: H at the selected signal-bar offset < H one T1 bar earlier AND H two T1 bars earlier < H one T1 bar earlier
Long: S at the selected signal-bar offset > S one T1 bar earlier AND S two T1 bars earlier > S one T1 bar earlier
Short: S at the selected signal-bar offset < S one T1 bar earlier AND S two T1 bars earlier < S one T1 bar earlier
Long: H at the selected signal-bar offset > S at the selected signal-bar offset AND H one T1 bar earlier <= S one T1 bar earlier
Short: H at the selected signal-bar offset < S at the selected signal-bar offset AND H one T1 bar earlier >= S one T1 bar earlier
Exit: short, H at the selected signal-bar offset > 0 OR H at the selected signal-bar offset > H one T1 bar earlier OR S at the selected signal-bar offset > S one T1 bar earlier OR H at the selected signal-bar offset > S at the selected signal-bar offset
Exit: long, H at the selected signal-bar offset < 0 OR H at the selected signal-bar offset < H one T1 bar earlier OR S at the selected signal-bar offset < S one T1 bar earlier OR H at the selected signal-bar offset < S at the selected signal-bar offset