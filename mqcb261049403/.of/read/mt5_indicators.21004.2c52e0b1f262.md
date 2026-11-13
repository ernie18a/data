Calculation: R = EMA(RSI(price, n), s), where RSI uses Wilder smoothing (alpha=1/n) and s is a shorter smoothing length than n
Calculation: W = EMA(EMA(|R - R[1]|, n), n), using the same n as the RSI period
Calculation: TrailLevel(m) = recursive trailing line of R with band width m*W. Start each bar with L = L[1]. If R < L: L = R + m*W, and if R[1] < L[1] and L > L[1] then L = L[1]. Then, if R > L: L = R - m*W, and if R[1] > L[1] and L < L[1] then L = L[1].
Calculation: Fast = TrailLevel(m_fast), Slow = TrailLevel(m_slow), with m_slow > m_fast. All series may optionally be computed on a higher timeframe than the chart, using the value of the still-forming higher-timeframe bar.
Long: R > Fast AND R > Slow
Short: R < Fast AND R < Slow