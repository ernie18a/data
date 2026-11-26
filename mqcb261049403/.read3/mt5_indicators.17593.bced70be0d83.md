Calculation: NRTR = seed trend=0 and price=level=close on the first bar; on each bar let R=mean(abs(high−low), lookback) over the current and preceding bars and k=R/10^(fixed reference-symbol quote digits−chart-symbol quote digits−adjustment). If trend≥0, set price=max(previous price, close), level=max(previous level, price×(1−k)), then if close<level reset price=close, level=price×(1+k), trend=−1. Otherwise set price=min(previous price, close), level=min(previous level, price×(1+k)), then if close>level reset price=close, level=price×(1−k), trend=+1.
Long: NRTR trend > 0
Short: NRTR trend < 0
Long: NRTR trend crosses above 0
Short: NRTR trend crosses below 0
Long: NRTR trend > 0 AND (previous bar's trend ≤ 0 OR high > the highest high since the latest transition to positive trend, through the previous bar)
Short: NRTR trend < 0 AND (previous bar's trend ≥ 0 OR low < the lowest low since the latest transition to negative trend, through the previous bar)
Long: on chart bars, the up-ZigZag value copied from T1 is nonzero; it is calculated on T1 bars using the T1 bar containing each chart bar, including while that bar is still forming
Short: on chart bars, the down-ZigZag value copied from T1 is nonzero; it is calculated on T1 bars using the T1 bar containing each chart bar, including while that bar is still forming