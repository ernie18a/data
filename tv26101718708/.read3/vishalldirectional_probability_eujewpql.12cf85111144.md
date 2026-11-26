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
Calculation: futures-cash Heikin Ashi close spread = (Heikin Ashi close of the corresponding index future on T1 − normal close of the corresponding index future on T1) − (Heikin Ashi close of the corresponding cash index on T1 − normal close of the corresponding cash index on T1)
Calculation: normalized Heikin Ashi strength(symbol) = 100 × (Heikin Ashi close(symbol, T1) − normal close(symbol, T1)) / normal close(symbol, T1)
Calculation: futures-cash normalized strength spread = normalized Heikin Ashi strength of the corresponding index future − normalized Heikin Ashi strength of the corresponding cash index
Calculation: chart-selected external strength = Bank index futures-cash normalized strength spread if the chart ticker contains BANKNIFTY; otherwise finance index futures-cash normalized strength spread if it contains FINNIFTY; otherwise the matching sector proxy's normalized Heikin Ashi strength if it contains AUTO, REALTY, FMCG, PHARMA, ENERGY, METAL, or IT; otherwise Nifty 50 futures-cash normalized strength spread
Long: corresponding index future Heikin Ashi close on T1 > its normal close on T1 AND corresponding cash index Heikin Ashi close on T1 > its normal close on T1 AND futures-cash Heikin Ashi close spread is positive
Short: corresponding index future Heikin Ashi close on T1 < its normal close on T1 AND corresponding cash index Heikin Ashi close on T1 < its normal close on T1 AND futures-cash Heikin Ashi close spread is negative
Long: chart-selected external strength > bullish cutoff
Short: chart-selected external strength < bearish cutoff