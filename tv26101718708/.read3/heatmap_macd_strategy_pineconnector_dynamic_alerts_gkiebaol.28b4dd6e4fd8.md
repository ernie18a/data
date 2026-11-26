Calculation: AllBull = MACD histogram(source, fast length, slow length, signal length) > 0 for every timeframe T1 to T5, each using its last completed bar
Calculation: AllBear = MACD histogram(source, fast length, slow length, signal length) < 0 for every timeframe T1 to T5, each using its last completed bar
Calculation: HighestHighSinceEntry = highest high from entry through current bar
Calculation: LowestLowSinceEntry = lowest low from entry through current bar
Calculation: HighestCloseSinceEntry = highest close from entry through current bar
Calculation: LowestCloseSinceEntry = lowest close from entry through current bar
Long: AllBull == true AND AllBull[1] == false AND position side is not long
Long: MACD histogram(source, fast length, slow length, signal length, T1, last completed bar) > 0 AND MACD histogram(source, fast length, slow length, signal length, T1, last completed bar)[1] < 0
Long: MACD histogram(source, fast length, slow length, signal length, T2, last completed bar) > 0 AND MACD histogram(source, fast length, slow length, signal length, T2, last completed bar)[1] < 0
Long: MACD histogram(source, fast length, slow length, signal length, T3, last completed bar) > 0 AND MACD histogram(source, fast length, slow length, signal length, T3, last completed bar)[1] < 0
Long: MACD histogram(source, fast length, slow length, signal length, T4, last completed bar) > 0 AND MACD histogram(source, fast length, slow length, signal length, T4, last completed bar)[1] < 0
Long: MACD histogram(source, fast length, slow length, signal length, T5, last completed bar) > 0 AND MACD histogram(source, fast length, slow length, signal length, T5, last completed bar)[1] < 0
Short: AllBear == true AND AllBear[1] == false AND position side is not short
Short: MACD histogram(source, fast length, slow length, signal length, T1, last completed bar) < 0 AND MACD histogram(source, fast length, slow length, signal length, T1, last completed bar)[1] > 0
Short: MACD histogram(source, fast length, slow length, signal length, T2, last completed bar) < 0 AND MACD histogram(source, fast length, slow length, signal length, T2, last completed bar)[1] > 0
Short: MACD histogram(source, fast length, slow length, signal length, T3, last completed bar) < 0 AND MACD histogram(source, fast length, slow length, signal length, T3, last completed bar)[1] > 0
Short: MACD histogram(source, fast length, slow length, signal length, T4, last completed bar) < 0 AND MACD histogram(source, fast length, slow length, signal length, T4, last completed bar)[1] > 0
Short: MACD histogram(source, fast length, slow length, signal length, T5, last completed bar) < 0 AND MACD histogram(source, fast length, slow length, signal length, T5, last completed bar)[1] > 0
Exit: long, AllBull[1] == true AND AllBull == false
Exit: short, AllBear[1] == true AND AllBear == false
Exit: long, low <= entry price - stop-loss pips * pip size
Exit: short, high >= entry price + stop-loss pips * pip size
Exit: long, high >= entry price + TP1 pips * pip size
Exit: long, high >= entry price + TP2 pips * pip size
Exit: short, low <= entry price - TP1 pips * pip size
Exit: short, low <= entry price - TP2 pips * pip size
Exit: long, low <= HighestHighSinceEntry - trailing-stop pips * pip size
Exit: short, high >= LowestLowSinceEntry + trailing-stop pips * pip size
Exit: long, low <= entry price + breakeven offset pips * pip size AND HighestCloseSinceEntry >= entry price + breakeven trigger pips * pip size
Exit: short, high >= entry price - breakeven offset pips * pip size AND LowestCloseSinceEntry <= entry price - breakeven trigger pips * pip size