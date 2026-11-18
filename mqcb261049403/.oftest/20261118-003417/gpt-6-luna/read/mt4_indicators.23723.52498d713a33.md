Calculation: Pivot = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: S1 = 2 * Pivot - high(T1, last completed bar)
Calculation: S3 = low(T1, last completed bar) - 2 * (high(T1, last completed bar) - Pivot)
Long: chart-bar close > Pivot
Short: chart-bar close > S1 AND chart-bar close < Pivot OR chart-bar close <= S3