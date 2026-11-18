Calculation: normalized HA gap = 100 × (Heikin-Ashi close − close) / close, using the still-forming T1 bar and evaluated on chart bars
Calculation: relative HA difference = (future Heikin-Ashi close − future close) − (cash Heikin-Ashi close − cash close), using still-forming T1 bars and evaluated on chart bars
Calculation: displayed gap = the selected series' normalized HA gap, or the selected future series' normalized HA gap − the cash series' normalized HA gap
Long: Heikin-Ashi close(T1, still-forming bar) > close(T1, still-forming bar)
Short: Heikin-Ashi close(T1, still-forming bar) < close(T1, still-forming bar)
Long: future Heikin-Ashi close(T1, still-forming bar) > future close(T1, still-forming bar) AND cash Heikin-Ashi close(T1, still-forming bar) > cash close(T1, still-forming bar) AND relative HA difference > 0
Short: future Heikin-Ashi close(T1, still-forming bar) < future close(T1, still-forming bar) AND cash Heikin-Ashi close(T1, still-forming bar) < cash close(T1, still-forming bar) AND relative HA difference < 0
Long: displayed gap > mild-bullish threshold AND displayed gap <= strong-bullish threshold
Long: displayed gap > strong-bullish threshold
Short: displayed gap >= strong-bearish threshold AND displayed gap < mild-bearish threshold
Short: displayed gap < strong-bearish threshold