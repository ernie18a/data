Calculation: slope(x, n) = (x - x[n]) / n
Short: crossunder(MA(P1, P2, P3), MA(P4, P5, P6)) AND (not P8 OR (slope(MA(P1, P2, P3), P7) < -P9 AND slope(MA(P4, P5, P6), P7) < -P10)) AND (not P11 OR bar time within session P12)
Exit: short, crossover(MA(P1, P2, P3), MA(P4, P5, P6)) OR (P11 AND P13 AND NOT bar time within session P12 AND previous bar time within session P12)