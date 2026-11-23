Calculation: SeasonalReturn(Tx, k) = 100 * (last close - first close) / first close over the T1 bars in the same calendar month (Tx = T2) or week of year (Tx = T3) as the current bar, k years earlier; defined if such bars exist
Calculation: PositiveShare(Tx, N) = 100 * count(k in 1..N: SeasonalReturn(Tx, k) > 0) / count(k in 1..N: SeasonalReturn(Tx, k) defined); undefined if the denominator is 0
Calculation: MonthComponent = (sum over i in 1..4 with PositiveShare(T2, Ni) defined of Wi * PositiveShare(T2, Ni)) / (sum over the same i of Wi), or V if no such i; N1 < N2 < N3 < N4
Calculation: WeekComponent = PositiveShare(T3, N4) if defined, else V
Calculation: CompositeScore = A * MonthComponent + B * WeekComponent
Calculation: NewMonth = month(T1 bar) != month(T1 bar[1])
Calculation: NewWeek = weekofyear(T1 bar) != weekofyear(T1 bar[1])
Long: CompositeScore(T1, last completed bar) >= K
Short: CompositeScore(T1, last completed bar) < K
Long: NewMonth(T1, last completed bar) AND PositiveShare(T2, N4, T1, last completed bar) = 100
Long: NewWeek(T1, last completed bar) AND PositiveShare(T3, N4, T1, last completed bar) = 100
Long: (NewMonth(T1, last completed bar) AND PositiveShare(T2, N2, T1, last completed bar) = 100) OR (NewWeek(T1, last completed bar) AND PositiveShare(T3, N2, T1, last completed bar) = 100)