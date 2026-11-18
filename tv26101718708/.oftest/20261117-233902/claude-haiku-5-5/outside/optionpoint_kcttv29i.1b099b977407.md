Calculation: MA(src, len, type) = EMA, SMA or WMA of src over len bars, as selected by type
Calculation: Slope(x, n) = (x - x[n]) / n
Calculation: InSession(k) = bar k bars back has its time within session window P12
Short: crossunder(MA(P3, P1, P5), MA(P4, P2, P6)) AND (not P10 OR (Slope(MA(P3, P1, P5), P7) < -P8 AND Slope(MA(P4, P2, P6), P7) < -P9)) AND (not P11 OR InSession(0))
Exit: short, crossover(MA(P3, P1, P5), MA(P4, P2, P6))
Exit: short, P11 AND P13 AND not InSession(0) AND InSession(1)