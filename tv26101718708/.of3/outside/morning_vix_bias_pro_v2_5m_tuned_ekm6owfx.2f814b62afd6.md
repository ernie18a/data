Calculation: Volatility bias = EMA(P1 × Z-score(bar-to-bar change in VIX index, P4) + P2 × Z-score(bar-to-bar change in front-month VIX futures, P4) + P3 × Z-score(abs(bar-to-bar change in S&P 500 index), P4), P5)
Long: Volatility bias > P6
Short: Volatility bias < P6
Exit: Long, Z-score(VIX index, P7) > P8 AND change in VIX index over P9 bars < change in VIX index over P10 bars AND bar-to-bar change in absolute bar-to-bar change in S&P 500 index < P11-bar SMA of that change