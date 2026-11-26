Calculation: Smoothed DPO = MA(DPO(applied price, lookback 1, averaging method 1, phase 1), lookback 2, smoothing method 2, phase 2)
Long: Smoothed DPO > 0 AND Smoothed DPO != Smoothed DPO[1]
Short: Smoothed DPO < 0 AND Smoothed DPO != Smoothed DPO[1]
Long: On chart bars, Smoothed DPO(T1, still-forming bar) > 0 AND Smoothed DPO(T1, still-forming bar) != Smoothed DPO(T1, previous bar)
Short: On chart bars, Smoothed DPO(T1, still-forming bar) < 0 AND Smoothed DPO(T1, still-forming bar) != Smoothed DPO(T1, previous bar)