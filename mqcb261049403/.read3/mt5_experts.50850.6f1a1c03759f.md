Calculation: LowerLevel = (open(T1, last completed bar) + high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 4 - fraction parameter × (high(T1, last completed bar) - low(T1, last completed bar)), sampled on chart bars
Long: low[1] < LowerLevel AND close[1] > LowerLevel
Short: low[1] > LowerLevel AND close[1] < LowerLevel